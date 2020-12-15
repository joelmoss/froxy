# frozen_string_literal: true

require 'open3'
require 'rack/utils'

# Proxies files to esbuild.
module Froxy
  class Proxy
    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      path_info = req.path_info

      return unless (path = clean_path(path_info))

      if (req.get? || req.head?) && /\.(js|css)$/i.match?(path)
        output = build(path, '--sourcemap')

        if output
          req.path_info = path

          response = Rack::Response.new(output)
          response.content_type = content_type_for(path)

          return response.finish
        end
      end

      @app.call req.env
    end

    private

    def build(path, *options)
      full_path = Rails.root.join(path.delete_prefix('/').b)

      return false unless file_readable?(full_path)

      cmd = ['esbuild'].concat(options)
      cmd << full_path.relative_path_from(Rails.root)

      stdout, stderr, status = run(cmd)

      if status.success?
        Rails.logger.info "[froxy] built #{path}"
        Rails.logger.error stderr.to_s unless stderr.empty?

        stdout
      else
        non_empty_streams = [stdout, stderr].delete_if(&:empty?)
        Rails.logger.error "[froxy] build failed:\n#{non_empty_streams.join("\n\n")}"

        false
      end
    end

    def content_type_for(path)
      ::Rack::Mime.mime_type(::File.extname(path), nil) || 'text/plain'
    end

    def run(cmd)
      Open3.capture3(cmd.join(' '), chdir: Rails.root)
    end

    def file_readable?(path)
      file_stat = File.stat(path.to_s)
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
