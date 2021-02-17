# frozen_string_literal: true

require 'open3'
require 'rack/utils'

# Proxies files to esbuild.
module Froxy
  class Proxy
    CLI = 'bin/froxy'

    def initialize(app)
      @app = app
      @file_server = Rack::Files.new(Rails.root)
    end

    def call(env)
      req = Rack::Request.new(env)
      path_info = req.path_info

      # Let images through.
      if (req.get? || req.head?) && /\.(png|gif|jpe?g|svg|ico|webp|avif)$/i.match?(path_info)
        return @file_server.call(env)
      end

      # Let esbuild handle JS and CSS.
      if (req.get? || req.head?) && /\.(js|css)$/i.match?(path_info)
        return unless (path = clean_path(path_info))

        return [404, {}, []] unless file_readable?(path)

        return @file_server.call(env) unless Rails.application.config.froxy.use_esbuild

        if (output = build(path))
          return output.finish if output.is_a?(Rack::Response)

          # output is a JSON object of the esbuild metafile.
          # pp output
          # pp output['outputs']["public/froxy/build/#{path}"]

          req.path_info = "public/froxy/build/#{path}"
          return @file_server.call(env)
        end
      end

      @app.call req.env
    end

    private

    # Build the file from the given `path` using ESbuild. Returns a Rack::Response.
    def build(path)
      stdout, stderr, status = Open3.capture3([CLI, Rails.root, path].join(' '))

      if status.success?
        Rails.logger.info "[froxy] built #{path}"
        raise "[froxy] build failed: #{stderr}" unless stderr.empty?

        return true
        return JSON.parse(stdout)
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
