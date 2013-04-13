class User
  include Shield::Model

  def self.[](id)
    User.new(1001) unless id.to_s.empty?
  end

  def self.fetch(username)
    User.new(1001) if username == "quentin"
  end

  attr :id

  def initialize(id)
    @id = id
  end

  def crypted_password
    @crypted_password ||= Shield::Password.encrypt("password")
  end
end
