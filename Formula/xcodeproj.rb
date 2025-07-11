class Xcodeproj < Formula
  desc "Command-line tool for manipulating Xcode project files"
  homepage "https://github.com/ainame/xcodeproj-cli"
  url "https://github.com/ainame/xcodeproj-cli/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "cce97ba6679e515954a111a2bf14bf0e3b4c8d97ff57fb50d0a5cbcabafdb82a"
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