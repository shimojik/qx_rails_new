class Creation < ApplicationRecord
  include UidModule
  belongs_to :user
end
