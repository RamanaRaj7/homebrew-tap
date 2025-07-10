class Wifiwatcher < Formula
  desc "Monitor Wi-Fi network changes and execute scripts"
  homepage "https://github.com/ramanaraj7/wifiwatcher"
  url "https://github.com/ramanaraj7/wifiwatcher/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "7d4b88541aaa5c9b9a444f354f1d189fe1893ceab3e4d4924245d7690d007bcd"
  license "MIT"
  
  depends_on :macos

  def install
    bin.install "wifiwatcher"
    
    # Create log directory
    (var/"log").mkpath
  end

  service do
    run [opt_bin/"wifiwatcher", "--monitor"]
    keep_alive true
    log_path var/"log/wifiwatcher.log"
    error_log_path var/"log/wifiwatcher.log"
  end

  def caveats
    <<~EOS
      To complete setup, run:
        wifiwatcher --setup
      
      This creates:
      - ~/.wifiwatcher configuration file
      - Example scripts in ~/scripts/
      
      To start the service:
        brew services start wifiwatcher
      
      To stop the service:
        brew services stop wifiwatcher
    EOS
  end

  test do
    system "#{bin}/wifiwatcher", "--version"
  end
end 