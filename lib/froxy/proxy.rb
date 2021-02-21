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

    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      path_info = req.path_info

      # Let images through.
      if (req.get? || req.head?) && IMAGE_TYPES.match?(path_info)
        return Rack::Files.new(Rails.root).call(env)
      end

      # Let esbuild handle JS and CSS.
      if (req.get? || req.head?) && /\.(js|jsx|css)$/i.match?(path_info)
        return unless (path = clean_path(path_info))

        return [404, {}, []] unless file_readable?(path)

        unless Rails.application.config.froxy.use_esbuild
          return Rack::Files.new(Rails.root).call(env)
        end

        if (output = build(path))
          # Output is the file contents.
          return output.finish if output.is_a?(Rack::Response)

          # Output is the path to the esbuild metafile. Parse it and return the first output file,
          # which should be the requested file.
          return output_file_from_metadata(env, req, output)
        end
      end

      @app.call req.env
    end

    private

    def output_file_from_metadata(env, request, path)
      metadata = FastJsonparser.load(Rails.root.join(path).to_s)

      request.path_info = metadata[:outputs].keys.first.to_s.delete_prefix(BUILD_PATH.to_s)
      Rack::Files.new(Rails.root.join(BUILD_PATH)).call(env)
    end

    # Build the file from the given `path` using ESbuild. Returns a Rack::Response.
    def build(path)
      stdout, stderr, status = Open3.capture3(CLI, Rails.root.to_s, path)

      if status.success?
        Rails.logger.info "[froxy] built #{path}"
        raise "[froxy] build failed: #{stderr}" unless stderr.empty?
      else
        non_empty_streams = [stdout, stderr].delete_if(&:empty?)
        raise "[froxy] build failed:\n#{non_empty_streams.join("\n\n")}"
      end

      stdout
    end

    # Only needed if we return file contents from CLI.
    def response_from_build(path, body)
      response = Rack::Response.new(body)
      response.content_type = content_type_for(path)
      response
    end

    def content_type_for(path)
      Rack::Mime.mime_type(::File.extname(path), nil) || 'text/plain'
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
