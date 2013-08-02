require 'logger'

class PSD
  module Logger
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_accessor :debug

      def logger
        return @logger if @logger

        if debug || ENV['PSD_DEBUG']
          @logger = ::Logger.new(debug_output)
          @logger.formatter = proc do |severity, datetime, progname, msg|
            "#{severity}: #{msg}\n"
          end
        else
          @logger = DisabledLogger.new
        end

        return @logger
      end

      def debug_output
        if ENV['PSD_DEBUG']
          ENV['PSD_DEBUG'] == 'STDOUT' ? STDOUT : ENV['PSD_DEBUG']
        end

        STDOUT
      end
    end
  end

  class DisabledLogger
    def method_missing(method, *args, &block)
      # silence
    end
  end
end