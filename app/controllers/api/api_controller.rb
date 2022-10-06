class Api::ApiController < ActionController::Base
  before_filter :authenticate_user!

  rescue_from Exception do |e|
    render json: "ERROR:" + e.message, status: 500
  end

  def notify(user_id, data, channelName = 'messages')
    message = {:channel => '/' + channelName + '/' + user_id, :data => data, :ext => { :auth_token => FAYE_TOKEN } }
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

  def default_serializer_options
    { root: false }
  end
  
  def filter_params(*param_list)
    filtered_params = {}
    param_list.each do |param|
      if param.is_a? Hash
        param.each {|key, value| filtered_params[value] = params[key]}
      else
        filtered_params[param] = params[param]
      end
    end
    filtered_params
  end
end