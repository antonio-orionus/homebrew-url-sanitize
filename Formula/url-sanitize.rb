require "json"

class UrlSanitize < Formula
  desc "Remove tracking parameters and unwrap tracking redirects from URLs"
  homepage "https://github.com/antonio-orionus/url-sanitize"
  version "2.0.0"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-aarch64-apple-darwin.tar.gz"
      sha256 "3be28887672dec0e61c408187a3025deb94eab1b8a9f984ea2f094a5b73d155e"
    elsif Hardware::CPU.intel?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-x86_64-apple-darwin.tar.gz"
      sha256 "a0cda82fb523f2487559f496b76a1b5364f9bd44f685627973d49a541c822fd3"
    else
      odie "unsupported macOS architecture"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "eda9a0050c5598938ef02cae1fb263c8d5ad348ebc5158794c2848f024a9a7f9"
    elsif Hardware::CPU.intel?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "a666a86dea9adda228b4fa85a5ce204459bbcf9d234be6619f5663fed548111a"
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
