#!/usr/bin/env zsh

# Thanks to:
# Mathias Bynens https://mths.be/macos
# Freek Van der Herten https://github.com/freekmurze/dotfiles

echo 'Running setup/macos-defaults.sh ...'

# Machine-specific values are asked for at run time, defaulting to what the
# machine already has. Preset COMPUTER_NAME or TIMEZONE in the environment to
# skip the prompt (useful for unattended runs).

if [[ -z "${COMPUTER_NAME:-}" ]]; then
  CURRENT_NAME=$(scutil --get ComputerName 2>/dev/null || hostname -s)
  read "COMPUTER_NAME?Computer name [${CURRENT_NAME}]: "
  COMPUTER_NAME="${COMPUTER_NAME:-$CURRENT_NAME}"
fi

# See `systemsetup -listtimezones` for valid values
if [[ -z "${TIMEZONE:-}" ]]; then
  CURRENT_TZ=$(readlink /etc/localtime | sed 's#.*/zoneinfo/##')
  read "TIMEZONE?Timezone [${CURRENT_TZ}]: "
  TIMEZONE="${TIMEZONE:-$CURRENT_TZ}"
fi

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Settings" to quit' 2>/dev/null

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until this script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "${COMPUTER_NAME}"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${COMPUTER_NAME}"

USERNAME=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
sudo /usr/sbin/scutil --set HostName "${USERNAME}"
sudo /usr/sbin/scutil --set LocalHostName "${USERNAME}"
dscacheutil -flushcache

# Set language and text formats
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
defaults write NSGlobalDomain AppleLanguages -array "en"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=CAD"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Set the timezone; see `systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "${TIMEZONE}" > /dev/null

# Animate opening applications: false = NO 2022-07
defaults write com.apple.dock launchanim -bool false

# Automatically hide and show the Dock 2022-07
defaults write com.apple.dock "autohide" -bool true

# Delay before the hidden Dock reappears (seconds)
defaults write com.apple.dock "autohide-delay" -float "0.5"

# Remove the animation when hiding/showing the Dock 2022-07
defaults write com.apple.dock "autohide-time-modifier" -float 0

# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable Resume system-wide
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Enable key repeat on hold
defaults write -g ApplePressAndHoldEnabled -bool false

# Accessibility > Display > Reduce transparency
# (needs Full Disk Access for the terminal, otherwise the write is ignored)
defaults write com.apple.universalaccess reduceTransparency -bool true

###############################################################################
# Keyboard                                                                    #
###############################################################################

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Fastest key repeat and shortest delay before repeat starts
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 35

# Canadian keyboard layout
defaults write com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID -string "com.apple.keylayout.Canadian"

###############################################################################
# Trackpad                                                                    #
###############################################################################

# Same settings for the built-in and Bluetooth trackpads. Tap to click off,
# three finger drag off, two finger secondary click, all swipe gestures on.
for domain in com.apple.AppleMultitouchTrackpad com.apple.driver.AppleBluetoothMultitouch.trackpad; do
  defaults write "$domain" Clicking -bool false
  defaults write "$domain" TrackpadThreeFingerDrag -bool false
  defaults write "$domain" TrackpadRightClick -bool true
  defaults write "$domain" TrackpadCornerSecondaryClick -int 0
  defaults write "$domain" TrackpadThreeFingerTapGesture -int 0
  defaults write "$domain" TrackpadThreeFingerHorizSwipeGesture -int 2
  defaults write "$domain" TrackpadThreeFingerVertSwipeGesture -int 2
  defaults write "$domain" TrackpadFourFingerHorizSwipeGesture -int 2
  defaults write "$domain" TrackpadFourFingerVertSwipeGesture -int 2
  defaults write "$domain" TrackpadFourFingerPinchGesture -int 2
  defaults write "$domain" TrackpadFiveFingerPinchGesture -int 2
  defaults write "$domain" TrackpadTwoFingerDoubleTapGesture -int 1
  defaults write "$domain" TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3
  defaults write "$domain" TrackpadPinch -int 1
  defaults write "$domain" TrackpadRotate -int 1
  defaults write "$domain" TrackpadHorizScroll -int 1
  defaults write "$domain" TrackpadScroll -bool true
  defaults write "$domain" TrackpadMomentumScroll -bool true
done

# The trackpad gesture settings are also mirrored per host
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerDragGesture -int 0
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

###############################################################################
# Safari (needs Full Disk Access for the terminal)                            #
###############################################################################

# Do not autofill anything
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

# Do not open "safe" files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Show the Develop menu
defaults write com.apple.Safari IncludeDevelopMenu -bool true

# New tabs open empty, keep history for a very long time, normal width tabs
defaults write com.apple.Safari NewTabBehavior -int 1
defaults write com.apple.Safari HistoryAgeInDaysLimit -int 365000
defaults write com.apple.Safari EnableNarrowTabs -bool false

###############################################################################
# Desktop, Spaces and menu bar                                                #
###############################################################################

# Hide desktop icons and widgets behind the wallpaper (click wallpaper to show)
defaults write com.apple.WindowManager HideDesktop -bool true
defaults write com.apple.WindowManager StandardHideWidgets -bool false
defaults write com.apple.WindowManager StageManagerHideWidgets -bool false

# Displays have separate Spaces turned off (Spaces span displays)
defaults write com.apple.spaces spans-displays -bool true

# Switching to an application does not switch to a Space with its windows
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool false

# Menu bar clock shows the day of the week
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true

# Hide the Siri menu bar item
defaults write com.apple.Siri StatusMenuVisible -bool false

###############################################################################
# Finder                                                                      #
###############################################################################

# Disable window animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool false

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Use column view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `Nlsv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Show the ~/Library folder
sudo chflags nohidden ~/Library

# Show the ~/Users folder
sudo chflags nohidden /Users

# Show the /Volumes folder
sudo chflags nohidden /Volumes

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

# Show hidden files:
defaults write com.apple.finder AppleShowAllFiles YES;

###############################################################################
# Screenshots                                                                 #
###############################################################################

# Set default screenshot location
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Exclude date and time in screenshot filenames
defaults write com.apple.screencapture "include-date" -bool false

# Change the default screenshot file name
defaults write com.apple.screencapture "name" -string "${USERNAME}-screenshot"

# Save screenshots in lossless (bigger) PNG format
# rather than default JPG (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Prevent applications from bouncing in Dock
defaults write com.apple.dock no-bouncing -bool true

# Set the icon size of Dock items to 48 pixels
defaults write com.apple.dock "tilesize" -int 48

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

###############################################################################
# Miscellaneous                                                            #
###############################################################################

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###############################################################################
# Activity Monitor                                                            #
###############################################################################

# Visualize CPU usage in the Activity Monitor Dock icon 2022-07
defaults write com.apple.ActivityMonitor IconType -int 5

###############################################################################
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility                   #
###############################################################################

# Use plain text mode for new TextEdit documents 2022-07
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit 2022-07
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

###############################################################################
# Photos
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in 2022-07
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Sharing
###############################################################################

# Remote Login (SSH), keys only, this user only.
# The public keys allowed in come from the private dotfiles. Remote Login is
# only switched on once at least one key is installed, so there is never a
# window where sshd is up without a key to accept.
# The drop-in sorts before Apple's 100-macos.conf because sshd keeps the first
# value it sees for each option.

SSH_KEYS="$HOME/.dotfiles-custom/ssh/authorized_keys"

if [[ -f "$SSH_KEYS" ]] && grep -qE '^(ssh|ecdsa)-' "$SSH_KEYS"; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  touch "$HOME/.ssh/authorized_keys"
  chmod 600 "$HOME/.ssh/authorized_keys"

  grep -E '^(ssh|ecdsa)-' "$SSH_KEYS" | while read -r key; do
    grep -qxF "$key" "$HOME/.ssh/authorized_keys" || echo "$key" >> "$HOME/.ssh/authorized_keys"
  done

  sudo tee /etc/ssh/sshd_config.d/010-dotfiles.conf > /dev/null <<EOF
# Managed by ~/.dotfiles/setup/macos-defaults.sh
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
AllowUsers ${USERNAME}
EOF

  sudo systemsetup -setremotelogin on
else
  echo "No keys in ${SSH_KEYS}, leaving Remote Login untouched"
fi

###############################################################################
# Sleep and Hibernation
###############################################################################

# Set external drives to never sleep only on Desktops
if [[ "$(sysctl -n hw.model | grep "Book")" == "" ]];
then 
	sudo pmset -c disksleep 0;
fi

###############################################################################
# iTerm2                                                                      #
###############################################################################

# Do not prompt when quitting iTerm2
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

###############################################################################
# Restart the apps whose defaults were changed above so they reload them     #
###############################################################################

for app in "Activity Monitor" "cfprefsd" "Dock" "Finder" "SystemUIServer" "TextEdit" "Safari" "ControlCenter"; do
	killall "${app}" > /dev/null 2>&1
done
