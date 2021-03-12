# frozen_string_literal: true

require 'open3'
require 'rack/utils'
require 'active_support/benchmarkable'

# Proxies files to esbuild.
module Froxy
  class Builder
    include ActiveSupport::Benchmarkable

    CLIS = {
      esbuild: File.expand_path('../../bin/esbuild.js', __dir__),
      postcss: File.expand_path('../../bin/postcss.js', __dir__)
    }
    BUILD_PATH = Rails.root.join('public/froxy/build').freeze
    FALLTHRU_TYPES = /\.(png|gif|jpeg|jpg|svg|ico|webp|avif)$/i.freeze
    SOURCEMAP_TYPES = /\.(js|css)\.map$/i.freeze
    BUILDABLE_TYPES = /\.(js|jsx|css)$/i.freeze
    BUILDABLE_POSTCSS_TYPES = /\.css$/i.freeze
    BUILDABLE_ESBUILD_TYPES = /\.(js|jsx)$/i.freeze
    FILE_EXT_MAP = {
      '.jsx' => '.js'
    }.freeze

    def initialize
      @root_fs = Rack::Files.new(Rails.root)
      @build_fs = Rack::Files.new(BUILD_PATH)
    end

    def attempt(env)
      request = Rack::Request.new(env)

      (request.get? || request.head?) && serve(request)
    end

    private

    def serve(request)
      # Let FALLTHRU_TYPES through to the root file system. Usually things like images and fonts.
      return @root_fs.call(request.env) if FALLTHRU_TYPES.match?(request.path_info)

      # Let JS|CSS sourcemaps through to the build file system - esbuild/postcss should have already
      # built them.
      return @build_fs.call(request.env) if SOURCEMAP_TYPES.match?(request.path_info)

      # Ignore non buildable files.
      return unless BUILDABLE_TYPES.match?(request.path_info)

      # Return if path is not clean or readable.
      return unless (path = clean_path(request.path_info))

      case path
      when BUILDABLE_POSTCSS_TYPES then build_with_postcss request, path
      when BUILDABLE_ESBUILD_TYPES then build_with_esbuild request, path
      end
    end

    def build_with_esbuild(request, path)
      return unless file_readable?(path)
      return @root_fs.call(request.env) unless Rails.application.config.froxy.use_esbuild

      path_to_file(*build(request, path, :esbuild))
    end

    # Build the given `path` with PostCSS.
    #
    # If the request is for a CSS file, and a referer is given which matches the request scheme
    # and host, and is JS, then we can assume that the request is from a JS import (ES Module).
    # We then treat this as a CSS module, and build the requested CSS through the postcss builder,
    # but as JS. This is done by appending `.js` to the path so that the builder will return a JS
    # module.
    def build_with_postcss(request, path)
      return unless file_readable?(path)
      return @root_fs.call(request.env) unless Rails.application.config.froxy.use_postcss

      response = build(request, imported_from_js?(request) ? "#{path}.js" : path, :postcss)
      path_to_response(*response).finish
    end

    # Returns true if the `request` has been imported as a JS module.
    def imported_from_js?(request)
      return false unless request.referer

      referer = URI(request.referer)
      referer.scheme == request.scheme && referer.host == request.host &&
        referer.path.end_with?('.js')
    end

    def build(request, path, cmd)
      benchmark logging_message(request, cmd) do
        stdout, stderr, status = Open3.capture3(CLIS[cmd], Rails.root.to_s, path)

        if status.success?
          raise "[froxy] build failed: #{stderr}" unless stderr.empty?
        else
          non_empty_streams = [stdout, stderr].delete_if(&:empty?)
          raise "[froxy] build failed:\n#{non_empty_streams.join("\n\n")}"
        end

        [request, path, stdout]
      end
    end

    def path_to_response(_request, path, stdout)
      response = Rack::Response.new(stdout)
      response.content_type = content_type_for(path)
      response
    end

    def content_type_for(path)
      ::Rack::Mime.mime_type(::File.extname(path), nil) || 'text/plain'
    end

    # rubocop:disable Style/FormatStringToken
    def logging_message(request, cmd)
      format '[froxy] Built /%s with %s for %s at %s', request.path_info, cmd, request.ip,
             Time.now.to_default_s
    end
    # rubocop:enable Style/FormatStringToken

    def path_to_file(request, path, _stdout)
      ext = Pathname.new(path).extname
      request.path_info = path.sub(/#{ext}$/, FILE_EXT_MAP[ext]) if FILE_EXT_MAP.key?(ext)

      @build_fs.call request.env
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

    def logger
      Rails.logger
    end
  end
end
