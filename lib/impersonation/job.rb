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
