class User < ActiveRecord::Base
  ## Attributes
  attr_accessible :email, :first_name, :last_name, :password, :password_confirmation
  
  ## Relationships
  
  ## Validations 
  has_secure_password
  
  validates :email,
    :presence => true, :uniqueness => true, :format => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    
  validates :first_name, :last_name,
    :presence => true
end
