class CreateRegions < ActiveRecord::Migration[7.0]
  def up
    create_table :regions do |t|
      t.string :name
      t.string :short_code
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end

    locations.each do |country_item|
      country = Country.create!(name: country_item[:countryName], short_code: country_item[:countryShortCode])
      country_item[:regions].each do |region_item|
        Region.create!(name: region_item[:name], short_code: region_item[:shortCode], country: country)
      end
    end
  end

  def down
    drop_table :regions
  end

  private

  def locations
    path = Rails.root.join('lib', 'data', 'locations.rb')
    raise "File #{path} not found" unless File.exist?(path)

    require path
    COUNTRIES_AND_REGIONS
  end

end
