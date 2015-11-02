describe "Impersonation" do
  include Rack::Test::Methods
  def app
    @app ||= Impersonation
  end

  describe "post test /ping" do
    it 'should work' do
      get '/'
      expect(last_response).to be_ok
    end

    it 'should return a pong' do
      header 'X_GITHUB_EVENT', 'ping'
      post "/",{}, { HTTP_X_GITHUB_EVENT: "ping" }
      expect(last_response).to be_ok
      expect(last_response.body).to match(/pong/)
    end
  end

  #describe "A push with new commits" do
  #  it 'should check to see if all commiters on the commits match the pusher' do
  #    post "/", {}, { HTTP_X_GITHUB_EVENT: "push" }
  #  end

  #  it 'should flag the commits as failing the impersonation status' do
  #    pending
  #  end

  #  it 'should delete the commits that failed status' do
  #    pending
  #  end
  #end

  #describe "A push with new commits in a pull request" do
  #  it 'should check to see if all the NEW commits have commiters matching the pusher' do
  #    pending
  #  end

  #  it 'should flag the whole PR as suspect' do
  #    pending
  #  end
  #end
end
