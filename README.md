(Dis)proof of concept MCollective connector plugin for AWS SQS/SNS
============================

## WARNING: idea and implementation are both flawed ##

I wanted to see whether it would be possible to use MCollective in AWS
without a real message broker (eg, ActiveMQ), to avoid an additional
dependency in a small environment.  Amazon offers Simple Queue Service
and Simple Notification Service for use along these lines.

Work in this repo stopped at the point I decided that SQS/SNS did
not implement the semantics needed to be useful as a broker for
MCollective.
