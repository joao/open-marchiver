# Be sure to restart your server when you modify this file.

# Rails.application.config.assets.enabled = true

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Rails.application.config.assets.paths << Rails.root.join("vendor", "assets", "fonts")




# Precompile additional assets
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
#Rails.application.config.assets.precompile += %w( search.js )
#Rails.application.config.assets.precompile += %w( jquery.js jquery_ujs.js )

# Need to add this as I'm not loading everything in application.js
# Loading only what's needed in a single controller
#
# Viewer
Rails.application.config.assets.precompile += %w( viewer.js viewer.css )
# Corrector
Rails.application.config.assets.precompile += %w( corrector.js corrector.css )
# Devise auth
Rails.application.config.assets.precompile += ['devise/*']


# Boostrap Support if installed via bower bootstrap-sass
# Bower asset paths
# Rails.root.join('vendor', 'assets', 'bower_components').to_s.tap do |bower_path|
#   Rails.application.config.sass.load_paths << bower_path
#   Rails.application.config.assets.paths << bower_path
# end
# # Precompile Bootstrap fonts
# Rails.application.config.assets.precompile << %r(bootstrap-sass/assets/fonts/bootstrap/[\w-]+\.(?:eot|svg|ttf|woff2?)$)
# # Minimum Sass number precision required by bootstrap-sass
# ::Sass::Script::Value::Number.precision = [8, ::Sass::Script::Value::Number.precision].max