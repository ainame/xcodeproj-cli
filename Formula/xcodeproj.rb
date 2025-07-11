class Xcodeproj < Formula
  desc "Command-line tool for manipulating Xcode project files"
  homepage "https://github.com/ainame/xcodeproj-cli"
  url "https://github.com/ainame/xcodeproj-cli/releases/download/v0.1.3/xcodeproj-v0.1.3-macos-universal.tar.gz"
  sha256 "e523bf9d3ba52fc1a1ece482413badeda45e43fe45ea5efbcecb1a7ed2f4d75d"
  license "MIT"
  head "https://github.com/ainame/xcodeproj-cli.git", branch: "main"

  depends_on :macos

  def install
    bin.install "xcodeproj"
  end
end
