class MacWatcher < Formula
  desc "Monitor Mac activity with email alerts when system wakes from sleep"
  homepage "https://github.com/ramanaraj7/mac-watcher"
  url "https://github.com/ramanaraj7/mac-watcher/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "a53d8bf8a8c3c18471b5a08bc1991bd3561ab398c7a409c8a170b8023c891228" # SHA256 of the GitHub release file
  license "MIT"
  
  depends_on "sleepwatcher"
  depends_on "jq"
  depends_on "imagesnap"
  # CoreLocationCLI is a cask and will be installed automatically by the setup script
  
  def install
    bin.install "bin/mac-watcher"
    
    share_dir = share/"mac-watcher"
    share_dir.install "share/mac-watcher/config.sh"
    share_dir.install "share/mac-watcher/monitor.sh"
    share_dir.install "share/mac-watcher/setup.sh"
    
    chmod 0755, share_dir/"config.sh"
    chmod 0755, share_dir/"monitor.sh"
    chmod 0755, share_dir/"setup.sh"
  end

  def post_install
    puts "Installing dependencies..."
    system "#{bin}/mac-watcher", "--dependencies"
  end
  
  # Standard pre_uninstall hook
  def pre_uninstall
    require "fileutils"
    
    # Stop sleepwatcher service if it's running
    system "brew", "services", "stop", "sleepwatcher" rescue nil
    
    # Remove configuration files - expand HOME variable to ensure it works
    home = ENV["HOME"]
    FileUtils.rm_f("#{home}/.wakeup")
    FileUtils.rm_f("#{home}/.config/monitor.conf")
    FileUtils.rm_rf("#{home}/.config/mac-watcher")
    
    # Remove any lingering symlinks
    FileUtils.rm_f("/usr/local/bin/mac-watcher")
    
    # Add logging for debugging
    puts "Mac-Watcher: pre_uninstall complete - removed configuration files"
    puts "Checked and removed: #{home}/.wakeup, #{home}/.config/monitor.conf"
  end
  
  # Add a more robust uninstall hook as a backup
  def post_uninstall
    require "fileutils"
    
    # This is a backup to ensure cleanup happens
    home = ENV["HOME"]
    
    # Clean up all possible files and directories
    [
      "#{home}/.wakeup",
      "#{home}/.config/monitor.conf",
      "#{home}/.config/mac-watcher",
      "/usr/local/bin/mac-watcher"
    ].each do |path|
      if File.directory?(path)
        FileUtils.rm_rf(path)
      elsif File.exist?(path)
        FileUtils.rm_f(path)
      end
    end
    
    # Create a cleanup script to run as the user
    cleanup_script = "#{Dir.tmpdir}/mac-watcher-cleanup.sh"
    File.open(cleanup_script, "w") do |f|
      f.puts "#!/bin/bash"
      f.puts "rm -f ~/.wakeup ~/.config/monitor.conf"
      f.puts "rm -rf ~/.config/mac-watcher"
    end
    
    FileUtils.chmod(0755, cleanup_script)
    system cleanup_script
    FileUtils.rm_f(cleanup_script)
    
    # Stop sleepwatcher service if it's running and not needed
    system "pgrep -x sleepwatcher >/dev/null && brew services stop sleepwatcher || true"
    
    puts "Mac-Watcher: post_uninstall complete - cleaned up all files"
  end

  def caveats
    <<~EOS
      To complete setup, please run:
        mac-watcher --setup
        mac-watcher --config (optional, to customize settings)
      
      Then start the sleepwatcher service:
        brew services start sleepwatcher
      
      To test functionality without waiting for a wake event:
        mac-watcher --test
      
      Required dependencies were automatically installed:
        - sleepwatcher (for wake detection)
        - jq (for JSON processing)
        - imagesnap (for webcam capture)
        - CoreLocationCLI (for location tracking) - attempted auto-install
      
      The setup process creates:
        - ~/.wakeup (wake detection script)
        - ~/.config/monitor.conf (default configuration)
      
      For more information, run:
        mac-watcher --instructions
      
      To completely uninstall and remove all configuration files:
        brew uninstall ramanaraj7/tap/mac-watcher
        
      If you need to manually clean up any files after uninstall:
        rm -f ~/.wakeup ~/.config/monitor.conf
        rm -rf ~/.config/mac-watcher
    EOS
  end
  
  test do
    system "#{bin}/mac-watcher", "--help"
  end
end 