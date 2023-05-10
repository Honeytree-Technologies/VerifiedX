web: bin/rails server -p 3000
worker: bundle exec sidekiq -t 25
js: THEME="mastodon" yarn build --watch
mastodon-css: yarn mastodon:build:css --watch
mastodon-mailer-css: yarn mastodon:build:mailer:css --watch
