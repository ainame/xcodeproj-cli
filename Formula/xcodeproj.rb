class Xcodeproj < Formula
  desc "Command-line tool for manipulating Xcode project files"
  homepage "https://github.com/ainame/xcodeproj-cli"
  url "https://github.com/ainame/xcodeproj-cli/releases/download/v0.1.1/xcodeproj-v0.1.1-macos-universal.tar.gz"
  sha256 "c07c9231a02a01c32831a864c60e299f4e9fdf3659ee3a611d202dc00a23594c"
  license "MIT"
  head "https://github.com/ainame/xcodeproj-cli.git", branch: "main"

  depends_on :macos

  def install
    bin.install "xcodeproj"
  end

  test do
    # Test help output
    assert_match "USAGE: xcodeproj", shell_output("#{bin}/xcodeproj --help")
    
    # Test creating a project
    system bin/"xcodeproj", "create", "TestProject", "--organization-name", "Test Org", "--bundle-identifier", "com.test.app"
    assert_predicate testpath/"TestProject.xcodeproj", :exist?
    
    # Test listing targets
    output = shell_output("#{bin}/xcodeproj list-targets TestProject.xcodeproj")
    assert_match "TestProject", output
  end
end