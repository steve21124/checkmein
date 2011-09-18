module CMI
  class User < Ohm::Model; include Ohm::Typecast; end
  ASE::require_part %w{user}
end
