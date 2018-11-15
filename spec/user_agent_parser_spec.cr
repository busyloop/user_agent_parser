require "./spec_helper"

describe UserAgent do
  it "identifies Android Webview" do
    ua_str = "Mozilla/5.0 (Linux; Android 7.0; SM-G892A Build/NRD90M; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/60.0.3112.107 Mobile Safari/537.36"

    ua = UserAgent.new(ua_str)

    ua.user_agent.not_nil!.should eq(ua_str)
    ua.family.not_nil!.should eq("Chrome Mobile WebView")
    ua.device.not_nil!.brand.should eq("Samsung")
    ua.device.not_nil!.model.should eq("SM-G892A")
    ua.device.not_nil!.name.should eq("Samsung SM-G892A")
    ua.os.not_nil!.family.should eq("Android")
    ua.os.not_nil!.version.to_s.should eq("7.0.0")
    ua.version.not_nil!.to_s.should eq("60.0.3112")
  end

  it "identifies Chrome" do
    ua_str = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36"
    ua = UserAgent.new(ua_str)

    ua.user_agent.not_nil!.should eq(ua_str)
    ua.family.not_nil!.should eq("Chrome")
    ua.device.should be_nil
    ua.os.not_nil!.family.should eq("Mac OS X")
    ua.os.not_nil!.version.to_s.should eq("10.14.1")
    ua.version.not_nil!.to_s.should eq("70.0.3538")
  end

  it "identifies curl" do
    ua_str = "curl/7.54.0"
    ua = UserAgent.new(ua_str)

    ua.user_agent.not_nil!.should eq(ua_str)
    ua.family.not_nil!.should eq("curl")
    ua.device.should be_nil
    ua.os.should be_nil
    ua.version.not_nil!.to_s.should eq("7.54.0")
  end
end
