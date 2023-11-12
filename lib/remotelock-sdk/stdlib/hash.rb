# frozen_string_literal: true

require_relative 'string'

# Extensions to stdlib Hash
#
class Hash
  # Convert a tag hash into a string. No validation is performed here.
  #
  def to_rl_tag
    map do |k, v|
      format('%<key>s="%<value>s"', key: k, value: v.tagescape)
    end.join(' ')
  end

  # Drop any key-value pairs where the value is not truthy
  #
  def cleanse
    select { |_k, v| v }
  end
end
