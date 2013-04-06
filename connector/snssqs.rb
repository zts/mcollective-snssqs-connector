require 'aws-sdk'

module MCollective
  module Connector
    class Snssqs<Base
      def initialize
        Log.info("Initializing SNS-SQS connector...")
        config_path = File.expand_path("~/.aws.yml")
        AWS.config(YAML.load(File.read(config_path)))
      end

      def connect
        Log.info("connect method called...")

        if @sqs
          Log.debug("Already connected...")
          return
        end
        
        @sqs = AWS::SQS.new
        queue_opts = { :message_retention_period => 60 }
        # queue naming constraints: Maximum 80 characters;
        # alphanumeric characters, hyphens (-), and underscores (_)
        # are allowed.
        name = Config.instance.identity.gsub(/\./, '_')
        Log.info("creating queue for #{Config.instance.identity} as #{name}...")
        @sqs.queues.create(name, options = queue_opts)
      end

      def subscribe(agent, type, collective)
        Log.info("subscribe called with agent/type/collective #{agent}/#{type}/#{collective}")
      end

      def unsubscribe(agent, type, collective)
        Log.info("unsubscribe called with agent/type/collective #{agent}/#{type}/#{collective}")
      end

      def publish(msg)
        Log.info("publish called for agent/type/collective #{msg.agent}/#{msg.type}/#{msg.collective} (requestid: #{msg.requestid})")
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
