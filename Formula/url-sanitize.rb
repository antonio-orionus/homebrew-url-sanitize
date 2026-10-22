require "json"

class UrlSanitize < Formula
  desc "Remove tracking parameters and unwrap tracking redirects from URLs"
  homepage "https://github.com/antonio-orionus/url-sanitize"
  version "2.0.4"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-aarch64-apple-darwin.tar.gz"
      sha256 "62eadec5c2fd55b587f4bae5e3198f023cdd0a3cd5065f15fde4ba1751f59088"
    elsif Hardware::CPU.intel?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-x86_64-apple-darwin.tar.gz"
      sha256 "cbcc9054521abbf13e079f2654a059d1d7aef06d81e9b8edb097c34308131edb"
    else
      odie "unsupported macOS architecture"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "4c581e9b28ccb78122aa61e8b71ca759a66c5416dde0f04eef6b7f8f2f76c39f"
    elsif Hardware::CPU.intel?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "0cbb2e075faac4054f52d4c61b9ce4e723a326485602547130f5f3f97bd4a7c5"
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
