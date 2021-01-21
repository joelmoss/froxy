# frozen_string_literal: true

require 'open3'
require 'rack/utils'

# Proxies files to esbuild.
module Froxy
  class Proxy
    ESBUILD = ['esbuild', '--color=false', '--error-limit=1'].freeze
    ESBUILD_BUNDLE_OPTS = ['--bundle', '--format=esm'].freeze

    def initialize(app)
      @app = app
      @file_server = Rack::Files.new(Rails.root)
    end

    def call(env)
      req = Rack::Request.new(env)
      path_info = req.path_info

      if (req.get? || req.head?) && /\.(js|css)$/i.match?(path_info)
        return unless (path = clean_path(path_info))
        return [404, {}, []] unless file_readable?(path)

        if !Froxy.esbuild
          req.path_info = path
          return @file_server.call(env)
        elsif (output = build(path, '--sourcemap')).is_a?(Rack::Response)
          req.path_info = path
          return output.finish
        end
      end

      @app.call req.env
    end

    private

    # Build the file from the given path using ESbuild. Returns the Rack::Response.
    def build(path, *options)
      cmd = ESBUILD + options
      cmd << path.delete_prefix('/')

      stdout, stderr, status = run(cmd)

      if status.success?
        Rails.logger.info "[froxy] built #{path}"
        raise "[froxy] build failed: #{stderr}" unless stderr.empty?

        response_from_build path, stdout
      else
        non_empty_streams = [stdout, stderr].delete_if(&:empty?)
        raise "[froxy] build failed:\n#{non_empty_streams.join("\n\n")}"
      end
    end

    def response_from_build(path, body)
      response = Rack::Response.new(body)
      response.content_type = content_type_for(path)
      response
    end

    def content_type_for(path)
      ::Rack::Mime.mime_type(::File.extname(path), nil) || 'text/plain'
    end

    def run(cmd)
      Open3.capture3(cmd.join(' '), chdir: Rails.root)
    end

    def file_readable?(path)
      path = Rails.root.join(path.delete_prefix('/').b).to_s
      file_stat = File.stat(path)
    rescue SystemCallError
      false
    else
      file_stat.file? && file_stat.readable?
    end

    def clean_path(path_info)
      path = Rack::Utils.unescape_path path_info.chomp('/')
      Rack::Utils.clean_path_info path if Rack::Utils.valid_path? path
    end
  end
end
