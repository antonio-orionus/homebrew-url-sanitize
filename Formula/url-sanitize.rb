require "json"

class UrlSanitize < Formula
  desc "Remove tracking parameters and unwrap tracking redirects from URLs"
  homepage "https://github.com/antonio-orionus/url-sanitize"
  version "2.1.2"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-aarch64-apple-darwin.tar.gz"
      sha256 "6034d1111fc9699186927b9809e3364da3075060437cf3f904f968476c906cae"
    elsif Hardware::CPU.intel?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-x86_64-apple-darwin.tar.gz"
      sha256 "16a056e676ca784ce1267555dff241ead4893c609bf62cd6c78d3b7c7bf9ee9a"
    else
      odie "unsupported macOS architecture"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "f548b67f249e4011bbcdc04f2466b5f8fa5dca405c578dc127e791f3600f3474"
    elsif Hardware::CPU.intel?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "86a7598a821e4ef4a61007ebc2949c096f43d2408bfbe444fc3662f19ed42601"
    else
      odie "unsupported Linux architecture"
    end
  else
    odie "unsupported operating system"
  end

  def install
    bin.install "url-sanitize"
  end

  test do
    test_url = "https://example.com/article?utm_source=newsletter&id=123"
    cleaned_url = "https://example.com/article?id=123"

    version_output = shell_output("#{bin}/url-sanitize --version")
    assert_match version.to_s, version_output
    assert_match(/catalog [0-9a-f]{64}(?::[0-9a-f]{64})*/, version_output)

    assert_equal cleaned_url, pipe_output("#{bin}/url-sanitize -", "#{test_url}\n").strip

    json_output = pipe_output("#{bin}/url-sanitize --json -", "#{test_url}\n")
    parsed = JSON.parse(json_output)
    assert_equal "cleaned", parsed["kind"]
    assert_equal cleaned_url, parsed["url"]
    assert_includes parsed["strippedParams"], "utm_source"
  end
end
