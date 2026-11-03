require "json"

class UrlSanitize < Formula
  desc "Remove tracking parameters and unwrap tracking redirects from URLs"
  homepage "https://github.com/antonio-orionus/url-sanitize"
  version "2.0.8"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-aarch64-apple-darwin.tar.gz"
      sha256 "eeb84337b71a9bd0ee36d3d9e7b1b0f81992e3c1dbf281362b6406157fabd753"
    elsif Hardware::CPU.intel?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-x86_64-apple-darwin.tar.gz"
      sha256 "46d90784227b765a1198140b9dc6d7385dd22215c29521d24a18ae6d23470d0d"
    else
      odie "unsupported macOS architecture"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c70dc89800cefe04573dfae5cd3cb6e81dc90b20cfa669dcb312e850d1cba7a2"
    elsif Hardware::CPU.intel?
      url "https://github.com/antonio-orionus/url-sanitize/releases/download/v#{version}/url-sanitize-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "f2d1ff2281176458d7b1b09010d9a0b6277d2b81a30757c548f59c62c36d3977"
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
