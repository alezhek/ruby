module Pubnub
  module Formatter
    # Formats channels as array of channels as strings
    def format_channels(channels, should_encode = true)
      channel_array = case channels.class.to_s
                        when 'String'
                          channels.split(',')
                        when 'Array'
                          channels.map { |channel| channel.to_s }
                        when 'NilClass'
                          []
                        else
                          [channels.to_s]
                      end

      channel_array = channel_array.map { |channel| encode_channel(channel) } if should_encode
      channel_array
    end

    def format_channel_group(channel_group, should_encode = true)
      channel_group_array = case channel_group.class.to_s
                              when 'String'
                                channel_group.split(',')
                              when 'Array'
                                channel_group.map { |channel| channel.to_s }
                              when 'NilClass'
                                []
                              else
                                [channel_group.to_s]
                            end

      channel_group_array = channel_group_array.map { |channel| encode_channel(channel) } if should_encode
      channel_group_array
    end

    def encode_channel(channel)
      URI.encode_www_form_component(channel).gsub('+', '%20')
    end

    def format_message(message)
      if @cipher_key
        pc = Pubnub::Crypto.new(@cipher_key)
        begin
          message = pc.encrypt(message)
          URI.escape(message.to_json)
        rescue => error
          @error_callback.call 'bug'
        end
      else
        URI.encode_www_form_component(message.to_json).gsub('+', '%20')
      end
    end

    def params_hash_to_url_params(hash)
      params = String.new
      hash.each do |key, value|
        params << "#{key}=#{value}&"
      end
      params.chop! if params[-1] == '&'
      params
    end

    def channels_for_url(channels)
      channel = channels.join('%2C')
      channel = '%2C' if channel.empty?
      channel
    end

  end
end