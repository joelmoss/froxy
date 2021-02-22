# frozen_string_literal: true

require 'open3'
require 'rack/utils'
require 'fast_jsonparser'

# Proxies files to esbuild.
module Froxy
  class Proxy
    BUILD_PATH = 'public/froxy/build'
    CLI = File.expand_path('../../bin/froxy', __dir__)
    IMAGE_TYPES = /\.(png|gif|jpeg|jpg|svg|ico|webp|avif)$/i.freeze
    FILE_EXT_MAP = {
      '.jsx' => '.js'
    }.freeze

    def initialize(app)
      @app = app
      @file_server = Rack::Files.new(Rails.root)
      @build_file_server = Rack::Files.new(Rails.root.join(BUILD_PATH))
    end

    def call(env)
      req = Rack::Request.new(env)
      path_info = req.path_info

      if req.get? || req.head?
        # Let images through.
        return @file_server.call(env) if IMAGE_TYPES.match?(path_info)

        # Let JS sourcemaps through.
        return @build_file_server.call(env) if /\.js\.map$/i.match?(path_info)

        # Let esbuild handle JS and CSS.
        if /\.(js|jsx|css)$/i.match?(path_info)
          return unless (path = clean_path(path_info))
          return [404, {}, []] unless file_readable?(path)
          return @file_server.call(env) unless Rails.application.config.froxy.use_esbuild

          return build env, req, path
        end
      end

      @app.call req.env
    end

    private

    def path_to_file(env, request, path)
      ext = Pathname.new(path).extname
      request.path_info = path.sub(/#{ext}$/, FILE_EXT_MAP[ext]) if FILE_EXT_MAP.key?(ext)

      @build_file_server.call env
    end

    # Build the file from the given `path` using ESbuild. Returns a Rack::Response.
    def build(env, request, path)
      stdout, stderr, status = Open3.capture3(CLI, Rails.root.to_s, path)

      if status.success?
        Rails.logger.info "[froxy] built #{path}"
        raise "[froxy] build failed: #{stderr}" unless stderr.empty?
      else
        non_empty_streams = [stdout, stderr].delete_if(&:empty?)
        raise "[froxy] build failed:\n#{non_empty_streams.join("\n\n")}"
      end

      path_to_file env, request, path
    end

    def file_readable?(path)
      file_stat = File.stat(Rails.root.join(path.delete_prefix('/').b).to_s)
    rescue SystemCallError
      false
    else
      file_stat.file? && file_stat.readable?
    end

    def clean_path(path_info)
      path = Rack::Utils.unescape_path path_info.chomp('/').delete_prefix('/')
      Rack::Utils.clean_path_info path if Rack::Utils.valid_path? path
    end
  end
end
