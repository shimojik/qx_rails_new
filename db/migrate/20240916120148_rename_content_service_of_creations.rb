class RenameContentServiceOfCreations < ActiveRecord::Migration[7.1]
  def change
    rename_column :creations, :content_service, :assistant_service
  end
end
