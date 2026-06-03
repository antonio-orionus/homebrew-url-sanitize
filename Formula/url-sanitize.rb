require "json"

class UrlSanitize < Formula
  desc "Remove tracking parameters and unwrap tracking redirects from URLs"
  homepage "https://github.com/antonio-orionus/url-sanitize"
  version "2.0.1"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-aarch64-apple-darwin.tar.gz"
      sha256 "3a30c6688b004ec9f3d36df779f085eede24f26750f6230e02acb9a146a9e41c"
    elsif Hardware::CPU.intel?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-x86_64-apple-darwin.tar.gz"
      sha256 "fe2f553c6ed373d8ed0ad0115a3194d2e2023df50eccb2c681bc1046b4e45bbb"
    else
      odie "unsupported macOS architecture"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "40b719ceedbfef17e51027622088350278845cd831a9819d0f412b3f18012a4a"
    elsif Hardware::CPU.intel?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "f2c2d3ccc5effa61b9a18b41df0c0013fdc7351ae7754e970e834110164e0506"
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
