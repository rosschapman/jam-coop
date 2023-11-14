# frozen_string_literal: true

class NullUser
  def admin?
    false
  end

  def artists
    []
  end
end