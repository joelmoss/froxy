# frozen_string_literal: true

require 'open3'
require 'rack/utils'

# Proxies files to esbuild.
module Froxy
  class Proxy
    ESBUILD = ['esbuild', '--color=false', '--error-limit=1'].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      path_info = req.path_info

      if (req.get? || req.head?) && /\.(js|css)$/i.match?(path_info)
        return unless (path = clean_path(path_info))

        if (output = build(path, '--sourcemap')).is_a?(Rack::Response)
          req.path_info = path
          return output.finish
        end

        return [404, {}, []] if output == :not_found
      end

      @app.call req.env
    end

    private

    def build(path, *options)
      return :not_found unless file_readable?(path)

      cmd = ESBUILD + options
      cmd << path.delete_prefix('/')

      stdout, stderr, status = run(cmd)

      if status.success?
        Rails.logger.info "[froxy] built #{path}"
        raise "[froxy] build failed: #{stderr}" unless stderr.empty?

        build_response path, stdout
      else
        non_empty_streams = [stdout, stderr].delete_if(&:empty?)
        raise "[froxy] build failed:\n#{non_empty_streams.join("\n\n")}"
      end
    end

    def build_response(path, body)
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
      path = ::Rack::Utils.unescape_path path_info.chomp('/')
      ::Rack::Utils.clean_path_info path if ::Rack::Utils.valid_path? path
    end
  end
end
