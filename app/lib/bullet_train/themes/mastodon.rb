module BulletTrain
  module Themes
    module Mastodon
      class Theme < BulletTrain::Themes::Light::Theme
        def directory_order
          ["mastodon"] + super
        end
      end
    end
  end
end
