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