require 'aws-sdk'

module MCollective
  module Connector
    class Snssqs<Base
      def initialize
        Log.info("Initializing SNS-SQS connector...")
        config_path = File.expand_path("~/.aws.yml")
        AWS.config(YAML.load(File.read(config_path)))

        @subscriptions = []
      end

      def connect
        Log.info("connect method called...")

        if @sqs
          Log.debug("Already connected...")
          return
        end

        @sqs = AWS::SQS.new
        @sns = AWS::SNS.new
        
        queue_opts = { :message_retention_period => 60 }
        # queue naming constraints: Maximum 80 characters;
        # alphanumeric characters, hyphens (-), and underscores (_)
        # are allowed.
        name = Config.instance.identity.gsub(/\./, '_')
        Log.info("creating queue for #{Config.instance.identity} as #{name}...")
        @queue = @sqs.queues.create(name, options = queue_opts)
      end

      def subscribe(agent, type, collective)
        Log.info("subscribe called with agent/type/collective #{agent}/#{type}/#{collective}")
        return unless agent == 'discovery'

        sns_topic = make_sns_target(agent, type, collective)

        if @subscriptions.include?(sns_topic)
          Log.info("Already subscribed to #{sns_topic}")
        else
          Log.info("Creating SNS topic for #{sns_topic}")
          topic = @sns.topics.create(sns_topic)
          Log.info("Subscribing SQS queue #{@queue} to SNS topic #{sns_topic}")
          topic.subscribe(@queue)
          @subscriptions << sns_topic
        end
      end

      def unsubscribe(agent, type, collective)
        Log.info("unsubscribe called with agent/type/collective #{agent}/#{type}/#{collective}")
      end

      def publish(msg)
        Log.info("publish called for agent/type/collective #{msg.agent}/#{msg.type}/#{msg.collective} (requestid: #{msg.requestid})")

        sns_topic = make_sns_target(msg.agent, msg.type, msg.collective)

        topic = @sns.topics.create(sns_topic)
        topic.publish(msg.payload)
        Log.info("Published #{msg.requestid} to SNS #{sns_topic}")
      end
      
      def receive()
        Log.info("Looking for a message from SQS...")
        sqs_msg = @queue.receive_message({:wait_time_seconds => 20})
        sns_msg = sqs_msg.as_sns_message
        Log.info("msg from SNS is: " + sns_msg.body)
        sqs_msg.delete
        Log.info("Got one, attempting to return a Message...")
        Message.new(sns_msg.body, sns_msg)
      end

      def disconnect
        Log.info("Disconnecting from SNS-SQS...")
      end

      def make_sns_target(agent, type, collective)
        # raise("Unknown target type #{type}") unless [:directed, :broadcast, :reply, :request, :direct_request].include?(type)
        # raise("Unknown collective '#{collective}' known collectives are '#{@config.collectives.join ', '}'") unless @config.collectives.include?(collective)

        case type
        when :reply
          suffix = :reply
        when :broadcast
          suffix = :command
        when :request
          suffix = :command
        else
          suffix = :unknown_type
        end

        [collective, agent, suffix].join('_')
      end
    end
  end
end

## Discovery flow (maybe)
# server starts, subscribes to discovery/broadcast
# client starts, sends message to discovery/broadcast
# server receives message
# server sends reply to ...
