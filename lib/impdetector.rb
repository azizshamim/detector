require 'sinatra'
require 'digest/hmac'
require 'octokit'

class ImpDetector < Sinatra::Application
  class Job
    def initialize(repo,pr)
      @client = Octokit::Client.new :access_token => ENV['GITHUB_ACCESS_TOKEN']
      @repo = repo
      @pr = pr
    end

    def work
      sha = @client.pull_request(@repo, @pr).head.sha
      puts "Checking out #{sha} from #{@repo}, for ##{@pr}\n"
      impersonated? ? update(sha,'failure') : update(sha, 'success')
    end

    private
    def impersonated?
      !@client.pull_request_commits(@repo, @pr).find_index do |commit|
        puts "checking commit #{commit.sha}\n"
        commit.committer.email != commit.author.email
      end.nil?
    end

    def update(sha,status)
      puts "sending #{status} for #{sha}\n"
      opts = {
        :context => "impdetector",
        :description => "Detects impersonation in commits"
      }
      @client.create_status(@repo, sha, status, opts)
    end
  end

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

  post "/", :x_github_event => /push/ do
    halt 403 unless validate!
    body = JSON.parse(@request_payload)

    repo = body['repository']['full_name']
  end

  post "/" do
    halt 404
  end
end
