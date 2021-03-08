# Turns API calls to always UTC, leaving the APP the freedom to use local timezone
module ActiveSupport
    class TimeWithZone
      def as_json(options = nil)
        utc
      end
    end
end