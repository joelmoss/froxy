require 'open3'

module Froxy
  class Proxy
    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      path = req.path_info

      # Handle *.css files at /froxy
      if (req.get? || req.head?) && path.start_with?('/froxy') && path.end_with?('.css')
        req.path_info = esbuild(path)
      end

      @app.call req.env
    end

    private

    def esbuild(path)
      path.delete_prefix!('/froxy/')

      src_path = Rails.root.join(path)
      build_path = Rails.root.join('public', 'froxy', path)

      cmd = ['esbuild']
      cmd << "--outfile=#{build_path}"
      cmd << src_path

      # TODO: handle errors
      Open3.capture3(cmd.join(' '), chdir: Rails.root)

      File.join 'froxy', path
    end
  end
end
