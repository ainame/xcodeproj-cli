class Xcodeproj < Formula
  desc "Command-line tool for manipulating Xcode project files"
  homepage "https://github.com/ainame/xcodeproj-cli"
  url "https://github.com/ainame/xcodeproj-cli/releases/download/v0.1.2/xcodeproj-v0.1.2-macos-universal.tar.gz"
  sha256 "c20e08f42c8568e4dabc71784fc0fbbb205846377fd8515fc81bd302f761a72a"
  license "MIT"
  head "https://github.com/ainame/xcodeproj-cli.git", branch: "main"

  depends_on :macos

  def install
    bin.install "xcodeproj"
  end
end
