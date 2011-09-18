module CMI class User
  
  attribute(:uid, String); index(:uid)      # 4sq user ID
  attribute(:token, String); index(:token)  # 4sq access token (OAuth)
  
  def validate
    assert_present(:uid)
    assert_present(:token)
    assert_unique(:uid)
  end
  
  class << self
    
    def get(uid)
      (r = find(uid: uid)).size > 1 ? r : r.first
    end

  end
  
end end
