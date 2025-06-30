class Xcodeproj < Formula
  desc "Command-line tool for manipulating Xcode project files"
  homepage "https://github.com/ainame/xcodeproj_cli"
  url "https://github.com/ainame/xcodeproj_cli/archive/v0.0.1.tar.gz"
  sha256 "REPLACE_WITH_ACTUAL_SHA256_OF_RELEASE"
  license "MIT"
  head "https://github.com/ainame/xcodeproj_cli.git", branch: "main"

  depends_on xcode: ["14.0", :build]
  depends_on :macos

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/xcodeproj"
  end

  test do
    # Test version output
    assert_match "0.0.1", shell_output("#{bin}/xcodeproj --version")
    
    # Test help output
    assert_match "A tool for manipulating Xcode project files", shell_output("#{bin}/xcodeproj --help")
    
    # Test creating a project
    system bin/"xcodeproj", "create", "TestProject", "--organization-name", "Test Org", "--bundle-identifier", "com.test.app"
    assert_predicate testpath/"TestProject.xcodeproj", :exist?
    
    # Test listing targets
    output = shell_output("#{bin}/xcodeproj list-targets TestProject.xcodeproj")
    assert_match "TestProject", output
    
    # Cleanup
    rm_rf "TestProject.xcodeproj"
  end
end