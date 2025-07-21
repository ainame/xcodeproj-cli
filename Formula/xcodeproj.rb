class Xcodeproj < Formula
  desc "Command-line tool for manipulating Xcode project files"
  homepage "https://github.com/ainame/xcodeproj-cli"
  url "https://github.com/ainame/xcodeproj-cli/releases/download/0.2.2/xcodeproj-0.2.2-macos-universal.tar.gz"
  sha256 "f1f375adf0b10733866d448bf1bed139a9b75e3310e89ccdc5d44fca8e68ba69"
  license "MIT"
  head "https://github.com/ainame/xcodeproj-cli.git", branch: "main"

  depends_on :macos

  def install
    bin.install "xcodeproj"
  end
end
