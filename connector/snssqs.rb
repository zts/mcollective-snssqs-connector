require 'aws-sdk'

module MCollective
  module Connector
    class Snssqs<Base
      def initialize
        Log.info("Initializing SNS-SQS connector...")
        config_path = File.expand_path("~/.aws.yml")
        AWS.config(YAML.load(File.read(config_path)))

        @sqs = AWS::SQS.new
      end

      def connect
        Log.info("connect method called...")
      end

      def subscribe(agent, type, collective)
        Log.info("subscribe called with agent/type/collective #{agent}/#{type}/#{collective}")
      end

      def receive()
        Log.info("Looking for a message from SQS...")
        sleep 60
      end

      def disconnect
        Log.info("Disconnecting from SNS-SQS...")
      end
    end
  end
end
