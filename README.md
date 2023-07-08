# mikrotik-juanfi-ezsetup v5.0
Beginners easy JuanFi setup/config script for your mikrotik with just simple command. All the needed mikrotik settings/configs for JuanFi!

How to install:
- Edit file "config.txt"
- Provide the needed information
- Save this file after editing
- Drag and Drop all files to winbox terminal
- Execute each command on winbox terminal:
  - :import  installer
  - $install juanfi_nodemcu
  - $install juanfi_income
  - $install juanfi_hsup
  - $install end
- or Install all in 3 command:
  - :import installer
  - $install juanfi
  - $install end
- or Uninstall !WARNING Use at your own risk!:
  - :import uninstall

Provide the needed information: (config.txt)
- NodeMAC      = nodemcu mac address. (!VERY IMPORTANT!)
- NodeEndIP    = nodemcu IP ending. (default is 2)
- NodeUserName = nodemcu username on mikrotik. (default is "pisonet")
- NodeUserPass = nodemcu password on mikrotik. (default is "abc123")

- HSUPName     = hotspot user profile name.
- HSUPRxTx     = hotspot user profile speed limit.

- isTelegram   = enable/disable telegram. (default is disabled)
- TGBotToken   = telegram bot token. (needed if telegram enabled)
- TGrpChatID   = telegram chat group. (needed if telegram enabled)

Author:
- Chloe Renae & Edmar Lozada

Facebook Contact:
- https://www.facebook.com/chloe.renae.9
