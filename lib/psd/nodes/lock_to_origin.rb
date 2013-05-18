class PSD::Node
  module LockToOrigin
    def lock_to_origin
      translate(-left - 1, -top - 1)
    end
  end
end