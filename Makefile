
# Online servers
DEV_SERVER = dev.marchiver.com
PRODUCTION_SERVER = production.marchiver.com
DEMO_SERVER = demo.marchiver.com

# Development helpers
run:
	bundle exec rails server

jobs:
	bundle exec rails jobs:work

gem_install:
	bundle install

bower_update:
	rails bower:update:prune


# Production helpers
passenger_restart:
	bundle update
	rails bower:update:prune
	RAILS_ENV=production rails db:migrate
	RAILS_ENV=production bundle exec rake assets:precompile
	pkill -9 -f delayed_job
	RAILS_ENV=production bin/delayed_job -n 1 start
	passenger-config restart-app --name /home/marchiver/marchiver/public

passenger_status:
	passenger-status

production_assets_precompile:
	RAILS_ENV=production bundle exec rake assets:precompile


production_console:
	RAILS_ENV=production bundle exec rails c

production_dj_start:
	RAILS_ENV=production bin/delayed_job -n 1 start

production_dj_stop:
	pkill -9 -f delayed_job


# Easy deploy to production by running:
# make deploy_production
# then run make passenger_restart at the app's root folder

deploy_production:
	rsync -ar --delete --progress . -e ssh marchiver@$(PRODUCTION_SERVER):/home/marchiver/marchiver --exclude='/.git' --filter="dir-merge,- .gitignore" --include='config/application.yml'

dry-deploy_production:
	rsync -arn --delete --progress . -e ssh marchiver@$(PRODUCTION_SERVER):/home/marchiver/marchiver --exclude='/.git' --filter="dir-merge,- .gitignore" --include='config/application.yml'

