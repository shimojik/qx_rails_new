module UidModule
  extend ActiveSupport::Concern
  included do
    after_create :insert_uid
    def insert_uid
      self.attributes = {uid: SecureRandom.hex(4) + self.id.to_s + SecureRandom.hex(4)}
      self.save(validate: false)
    end

    def to_param
      uid
    end
  end
end
