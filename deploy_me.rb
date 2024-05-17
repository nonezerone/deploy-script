# frozen_string_literal: true

require 'open3'

OSX_PLATFORM = (/darwin/ =~ RUBY_PLATFORM) != nil

def proceed?(input)
  case input
  when /y|yes|Yes|Y/ then true
  when /n|no|No|N/ then false
  else
    puts 'Invalid input. Skipping'
    false
  end
end

def setup_initial_osx_settings
  puts 'Enter computer name:'
  localhost_name = gets.chomp

  `sudo -v`
  `sudo spctl --master-disable`
  `sudo scutil --set ComputerName #{localhost_name}`
  `sudo scutil --set HostName #{localhost_name}`
  `sudo scutil --set LocalHostName #{localhost_name}`
  `sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string #{localhost_name}`

  `defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true`
  `defaults write com.apple.Safari AutoOpenSafeDownloads -bool false`
  `defaults write com.apple.SafariTechnologyPreview AutoOpenSafeDownloads -bool false`

  `mkdir -p ~/Screenshots/`
  `sudo defaults write com.apple.screencapture location ~/Screenshots/`
  `defaults write com.apple.screencapture location ~/Screenshots/`

  `defaults write com.apple.LaunchServices LSQuarantine -bool false`

  `defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false`
  `defaults write NSGlobalDomain KeyRepeat -int 1`
  `defaults write NSGlobalDomain InitialKeyRepeat -int 20`
  `defaults write NSGlobalDomain AppleShowAllExtensions -bool true`

  `defaults write com.apple.finder AppleShowAllFiles -bool true`
  `defaults write com.apple.finder ShowStatusBar -bool true`
  `defaults write com.apple.finder ShowPathbar -bool true`
  `defaults write com.apple.finder _FXShowPosixPathInTitle -bool true`
  `defaults write com.apple.finder _FXSortFoldersFirst -bool true`
  `defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"`
  `defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false`

  `defaults write NSGlobalDomain com.apple.springing.enabled -bool true`
  `defaults write NSGlobalDomain com.apple.springing.delay -float 0.2`

  `defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true`
  `defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true`

  `defaults write com.apple.dock autohide-time-modifier -int 0;killall Dock`

  `sudo chown root ~/Library/Preferences/ByHost/com.apple.loginwindow*`
  `sudo chmod 000 ~/Library/Preferences/ByHost/com.apple.loginwindow*`
  `defaults write com.apple.loginwindow TALLogoutSavesState -bool false`
end

def restore_brew_packages
  stdout, stderr, status = Open3.capture3("/opt/homebrew/bin/brew bundle")
end

unless OSX_PLATFORM.nil?
  Dir.chdir(Dir.home)

  config_repo_url = 'https://github.com/nonezerone/dots.git'

  `git clone --separate-git-dir=$HOME/.dots #{config_repo_url} $HOME/dots-tmp`
  `cp -a $HOME/dots-tmp/. $HOME`
  `git config --global alias.dots '!git --git-dir=$HOME/.dots/ --work-tree=$HOME'`
  `git dots config status.showUntrackedFiles no`
  `rm -r $HOME/dots-tmp`

  if OSX_PLATFORM
    puts 'Set up initial OSX settings? [y/n]'
    settings_input = gets.chomp

    puts 'Restore all brew packages from Brewfile? [y/n]'
    restoration_input = gets.chomp

    setup_initial_osx_settings if proceed?(settings_input)
    restore_brew_packages if proceed?(restoration_input)
  end
end
