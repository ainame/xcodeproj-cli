class Xcodeproj < Formula
  desc "Command-line tool for manipulating Xcode project files"
  homepage "https://github.com/ainame/xcodeproj-cli"
  url "https://github.com/ainame/xcodeproj-cli/releases/download/0.2.1/xcodeproj-0.2.1-macos-universal.tar.gz"
  sha256 "caf8210447ce60ead48495f673cbec8a324ec4b4e9906fdae589c04c98cad9f3"
  license "MIT"
  head "https://github.com/ainame/xcodeproj-cli.git", branch: "main"

  depends_on :macos

  def install
    bin.install "xcodeproj"
  end
end
