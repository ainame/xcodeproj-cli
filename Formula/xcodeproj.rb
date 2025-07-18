class Xcodeproj < Formula
  desc "Command-line tool for manipulating Xcode project files"
  homepage "https://github.com/ainame/xcodeproj-cli"
  url "https://github.com/ainame/xcodeproj-cli/releases/download/0.2.0/xcodeproj-0.2.0-macos-universal.tar.gz"
  sha256 "ccfcf69045b9c4777e74a9a7b7600e3805df2816952394834912e1a3bb2b39a5"
  license "MIT"
  head "https://github.com/ainame/xcodeproj-cli.git", branch: "main"

  depends_on :macos

  def install
    bin.install "xcodeproj"
  end
end
