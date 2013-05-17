class PSD::Node
  module LockToOrigin
    def lock_to_origin
      translate(-left, -top)
    end
  end
end