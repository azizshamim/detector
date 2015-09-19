require 'sinatra'
require 'digest/hmac'
require File.expand_path('../job.rb', __FILE__)

class ImpDetector < Sinatra::Application
  before do
    request.body.rewind
    @request_payload = request.body.read
  end

  def validate!
    false if request.env['HTTP_X_HUB_SIGNATURE'].nil?

    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.hexdigest(digest, ENV['SECRET_KEY'], @request_payload)
    "sha1=#{hmac.to_s}" == request.env['HTTP_X_HUB_SIGNATURE']
  end

  set(:x_github_event) do |event|
    condition do
      event === request.env['HTTP_X_GITHUB_EVENT']
    end
  end

  post "/", :x_github_event => /ping/ do
    [200, "pong"]
  end

  post "/", :x_github_event => /pull_request/ do
    halt 403 unless validate!

    body = JSON.parse(@request_payload)
    pr = body['number']
    repo = body['repository']['full_name']

    i = ImpDetector::Job.new(repo, pr)
    result = i.work
    [201, result.inspect]
  end

  post "/" do
    halt 404
  end
end
