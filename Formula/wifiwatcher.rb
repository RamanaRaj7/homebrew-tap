class Wifiwatcher < Formula
  desc "Monitor Wi-Fi network changes and execute scripts"
  homepage "https://github.com/ramanaraj7/wifiwatcher"
  url "https://github.com/ramanaraj7/wifiwatcher/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "b910c5a462b97aa1dcf38a46ea8d4b62ed9acc2093552d6137b85d84471b72ac"
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