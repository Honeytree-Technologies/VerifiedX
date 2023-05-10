class AddFieldsToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :email, :string
    add_column :people, :phone_number, :string
    add_column :people, :first_name, :string
    add_column :people, :last_name, :string
    add_column :people, :country, :string
    add_column :people, :region, :string
    add_column :people, :job_title, :string
    add_column :people, :organisation, :string
    add_column :people, :organisation_type, :string
    add_column :people, :website_url, :string
    add_column :people, :blog_url, :string
  end
end
