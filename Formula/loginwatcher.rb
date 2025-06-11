class Loginwatcher < Formula
  desc "Monitor macOS login attempts and execute custom scripts on success or failure"
  homepage "https://github.com/RamanaRaj7/loginwatcher"
  url "https://github.com/RamanaRaj7/loginwatcher/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "841b12481c5cdbc2510c11b06c757a72e6fb063d5e014ffac64fddc9a70aa7dc"
  license "MIT"

  depends_on :macos

  def install
    # Install the binary directly
    bin.install "bin/loginwatcher"
    prefix.install "share"
    
    # Create a symlink to the original binary as .bin
    (bin/"loginwatcher.bin").make_symlink(bin/"loginwatcher")
    
    # Replace the original binary with the CLI wrapper script
    rm bin/"loginwatcher"
    (bin/"loginwatcher").write <<~EOS
      #!/bin/bash
      exec "#{prefix}/share/loginwatcher/loginwatcher-cli.sh" "$@"
    EOS
    chmod 0755, bin/"loginwatcher"
  end

  service do
    # Point directly to the binary copy we made
    run [opt_bin/"loginwatcher.bin"]
    keep_alive true
    log_path "/tmp/loginwatcher.log"
    error_log_path "/tmp/loginwatcher.err"
    plist_name "homebrew.mxcl.loginwatcher"
  end

  def caveats
    <<~EOS
      To set up loginwatcher, run:
        loginwatcher --setup
      
      To start the service, run:
        brew services start loginwatcher
      
      For more information, run:
        loginwatcher --instructions
    EOS
  end

  test do
    assert_match "Loginwatcher version", shell_output("#{bin}/loginwatcher --version")
  end
end 