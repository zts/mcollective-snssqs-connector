require 'aws-sdk'

module MCollective
  module Connector
    class Snssqs<Base
      def initialize
        Log.info("Initializing SNS-SQS connector...")
      end

      def connect
        Log.info("connect method called...")
      end
    end
  end
end
