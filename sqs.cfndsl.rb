CloudFormation do

  queues.each do |queue|
    SQS_Queue(queue['name']) do
      QueueName FnJoin("-", [Ref('EnvironmentName'), queue['name']]) unless (queue.has_key?('generated_name')) && (queue['generated_name'])
      VisibilityTimeout queue['visibility_timeout'] if queue.has_key?('visibility_timeout')
      DelaySeconds queue['delay_seconds'] if queue.has_key?('delay_seconds')
      MaximumMessageSize queue['maximum_message_size'] if queue.has_key?('maximum_message_size')
      MessageRetentionPeriod queue['message_retention_period'] if queue.has_key?('message_retention_period')
      ReceiveMessageWaitTimeSeconds queue['receive_message_wait_time_seconds'] if queue.has_key?('receive_message_wait_time_seconds')

      if queue.has_key?('redrive_policy')
        RedrivePolicy ({
          deadLetterTargetArn: Ref(queue['redrive_policy']['queue']),
          maxReceiveCount: queue['redrive_policy']['count']
        })
      end

      if (queue.has_key?('fifo_queue')) && (queue['fifo_queue'])
        FifoQueue true
        ContentBasedDeduplication queue['content_based_deduplication'] if queue.has_key?('content_based_deduplication')
      end

    end

    Output("QueueUrl") {
      Value(Ref(queue['name']))
      Export FnSub("${EnvironmentName}-#{component_name}-#{queue['name']}Url")
    }

    Output("QueueName") {
      Value(FnGetAtt(queue['name'], 'QueueName'))
      Export FnSub("${EnvironmentName}-#{component_name}-#{queue['name']}Name")
    }
    Output('QueueArn', FnGetAtt(queue['name'], 'Arn'))

  end if (defined? queues) && (!queues.nil?)

end
