

RSpec.describe Mp3ToYoutube do
  @upload = Mp3ToYoutube::Mp3Uploader.new
  it "has a version number" do
    @upload.hello('Yassir').should eql "Author"
  end
end
