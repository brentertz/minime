%w(rubygems compass sinatra ./lib/partials haml sinatra/flash ./models dm-core uri).each  {|lib| require lib}
# NOTE: compass must be loaded before sinatra.  haml must be loaded after sinatra
# NOTE: To debug, insert a breakpoint by adding: require 'ruby-debug/debugger'

module Minime
  class App < Sinatra::Base
    # Configuration
    configure do
      set :app_file, __FILE__
      Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
      set :sass, Compass.sass_engine_options
      set :sass_dir, '../public/stylesheets/sass'
      set :haml, :format => :html5
      set :logging, true
      set :sessions, true # enable so can flash
      register Sinatra::Flash
    end
    configure :development do
      set :show_exceptions, false
      set :raise_errors, false
      DataMapper::Logger.new($stdout, :debug) # Logger must be configured before db connection
      DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/db.sqlite")
      DataMapper.auto_upgrade!
    end
    configure :production, :test do
      DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite:///#{Dir.pwd}/db.sqlite")
      DataMapper.auto_upgrade!
    end

    # Helpers
    helpers Sinatra::Partials
    helpers do
      # Sinatra stores sass files in the views dir, but I prefer to store them elsewhere
      def scss(template, *args)
        template = :"#{settings.sass_dir}/#{template}" if template.is_a? Symbol
          super(template, *args)
      end

      def base_url
        @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
      end

      def short_url(link)
        "#{base_url}/#{link.slug}"
      end

      def remote_ip(env)
        if addr = env['HTTP_X_FORWARDED_FOR']
          addr.split(',').first.strip # Get the 1st entry which is most likely the actual client IP and not a proxy
        else
          env['REMOTE_ADDR']
        end
      end
    end

    # Home page
    get '/' do
      haml :index
    end

    # Shorten link
    post '/' do
      custom = (params[:custom].empty?) ? nil : params[:custom]
      @link = Link.shorten(params[:url], custom)
      haml :index
    end

    # Record visit and redirect to original URL
    get '/:slug' do
      link = Link.first(:slug => params[:slug])
      raise 'This link is not defined yet' unless link
      link.visits << Visit.create(:ip => remote_ip(env))
      link.save
      redirect link.url, 301
    end

    # Simple API
    get '/api/create/*' do
      url = params[:splat][0]
      url = URI.unescape(url)
      begin
        @link = Link.shorten(url)
        "#{short_url(@link)}" unless @link.nil?
      rescue Exception => e
        e.message
      end
    end     

    # Handle stylesheet requests
    get '/stylesheets/:name.css' do
      content_type 'text/css', :charset => 'utf-8'
      scss(:"#{params[:name]}", Compass.sass_engine_options)
    end

    # Error handlers
    not_found do
      "This is nowhere to be found."
    end
    error do
      flash.now[:error] = env['sinatra.error']
      haml :index
    end

    # Start the server if ruby file executed directly
    run! if :app_file == $0
  end
end