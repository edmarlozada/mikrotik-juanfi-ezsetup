# ==============================
# Mikrotik JuanFi Hotspot User Profile
# by: Chloe Renae & Edmar Lozada
# ==============================
/{put "Mikrotik JuanFi Hotspot User Profile"

local cfg [[parse [/system script get "cfg-juanfi" source]]]
local HSUPName   ($cfg->"HSUPName")
local HSUPRxTx   ($cfg->"HSUPRxTx")
local isTelegram ($cfg->"isTelegram")
local TGBotToken ($cfg->"TGBotToken")
local TGrpChatID ($cfg->"TGrpChatID")
local HSFilePath ($cfg->"HSFilePath")

# ------------------------------
# Do not edit below this point!
# ------------------------------
local hsupinfo ("$HSUPName"."_43")
put "($hsupinfo) Creating user profile..."
local hsupPName $hsupinfo
local hsupSpeed $HSUPRxTx
local hsupFresh "1m"
local hsupShare 1
if ([/ip hotspot user profile find name=$hsupPName]="") do={
      /ip hotspot user profile  add name=$hsupPName }
/ip hotspot user profile set  [find name=$hsupPName] \
    !idle-timeout \
    !keepalive-timeout \
    rate-limit=$hsupSpeed \
    shared-users=$hsupShare \
    status-autorefresh=$hsupFresh \
    queue-type=hotspot-default \
    mac-cookie-timeout=1d
/ip hotspot user profile set [find name=$hsupPName] add-mac-cookie=no
/ip hotspot user profile set [find name=$hsupPName] on-login="" on-logout=""
if ([/file find name="$HSFilePath/data"]="") do={
  do { /tool fetch dst-path=("$HSFilePath/data/.") url="https://127.0.0.1/" } on-error={ }
  put "($hsupinfo) /file => name=[$HSFilePath/data]"
}
put "($hsupinfo) /ip hotspot user profile => name=[$hsupPName] rate-limit=[$hsupSpeed]"

# ==============================
# Hotspot User Profile onLogin
# ------------------------------
put "($hsupinfo) Setting onLogin..."
/{local sOnLogin ("# $hsupinfo_onLogin #
### enable telegram notification, change from 0 to 1 if you want to enable telegram
:local isTelegram $isTelegram;
###replace telegram token
:local iTBotToken \"$TGBotToken\";
###replace telegram chat id / group id
:local iTGrChatID \"$TGrpChatID\";
### hotspot folder for HEX put flash/hotspot for haplite put hotspot only
:local HSFilePath \"$HSFilePath\"
:if ([file find name=\"hotspot\"]!=\"\") do={:set HSFilePath \"hotspot\"}

# check AddUser or ExtUser
local aUsr [/ip hotspot user get \$username]
local iUsrEMail (\$aUsr->\"email\")
if ((\$iUsrEMail=\"new@gmail.com\") or (\$iUsrEMail=\"extend@gmail.com\")) do={
  local eReplaceChr do={
    local iRet
    for i from=0 to=([len \$1]-1) do={
      local x [pick \$1 \$i]
      if (\$x = \$2) do={ set x \$3 }
      set iRet (\$iRet . \$x)
    }; return \$iRet
  }
# Get User Data
  local mac \$\"mac-address\"
  local iFNameMac [\$eReplaceChr \$mac \":\" \"\"]
  local iUserNote (\$aUsr->\"comment\")
  local aUserNote [toarray \$iUserNote]
  local iValidity [totime (\$aUserNote->0)]
  local iSalesAmt [tonum (\$aUserNote->1)]
  local iExtTCode (\$aUserNote->2)
  local iVendoNme (\$aUserNote->3)
  local iUserTime (\$aUsr->\"limit-uptime\")
  local iUsrExist [/system scheduler find name=\$user]
if ((\$iUserTime>0) and (\$iValidity>=0)) do={
  local iInterval
  local iDateBeg [/system clock get date]
  local iTimeBeg [/system clock get time]
  /ip hotspot user set \$user email=\"\"
  /ip hotspot user set \$user comment=\"\"
# EXTEND USER
  if (\$iUsrExist!=\"\") do={
    log info \"( \$user ) =====[ EXT USER ]=====\"
    set iInterval [/system scheduler get \$user interval]
    if ((\$iValidity != 0s) and ((\$iValidity + \$iInterval) < \$iUserTime)) do={
      set iInterval \$iUserTime
    } else={
      set iInterval (\$iValidity + \$iInterval)
    }
    log info \"( \$user ) <<<<< iUserTime=[\$iUserTime] iValidity=[\$iValidity] iInterval=[\$iInterval] >>>>>\"
    /system scheduler set \$user interval=\$iInterval
  }
# ADD USER
  if (\$iUsrExist=\"\") do={
    log info \"( \$user ) =====[ ADD USER ]=====\"
    set iInterval \$iValidity
    if ((\$iValidity != 0s) and (\$iValidity < \$iUserTime)) do={
      set iInterval \$iUserTime
    }
    log info \"( \$user ) <<<<< iUserTime=[\$iUserTime] iValidity=[\$iValidity] iInterval=[\$iInterval] >>>>>\"
    do {
      /system scheduler add name=\$user interval=\$iInterval \\
      start-date=\$iDateBeg start-time=\$iTimeBeg disable=no \\
      policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \\
      on-event=(\"/ip hotspot active remove [find user=\$user]\\r\\n\".\\
                \"/ip hotspot cookie remove [find user=\$user]\\r\\n\".\\
                \"/system scheduler remove [find name=\$user]\\r\\n\".\\
                \"/ip hotspot user remove [find name=\$user]\\r\\n\".\\
                \"do {/file remove \\\"\$HSFilePath/data/\$iFNameMac.txt\\\"} on-error={}\\r\\n\")
    } on-error={ log error \"( \$user ) /system scheduler add => ERROR ADD!\" }
    local x 10;while ((\$x>0) and ([/system scheduler find name=\$user]=\"\")) do={set x (\$x-1);delay 1s}
  }
# Create/Save Data File
  local iValidUntil [/system scheduler get \$user next-run]
  if ([/file find name=\"\$HSFilePath\"]=\"\") do={ log error \"( \$user ) INTERNAL ERROR! Invalid HSFilePath! => HSFilePath=[\$HSFilePath]\" }
  if ([/file find name=\"\$HSFilePath\"]!=\"\") do={
    if ([/file find name=\"\$HSFilePath/data\"]=\"\") do={
      do { /tool fetch dst-path=(\"\$HSFilePath/data/.\") url=\"https://127.0.0.1/\" } on-error={ }
      local x 10;while ((\$x>0) and ([/file find name=\"\$HSFilePath/data\"]=\"\")) do={set x (\$x-1);delay 1s}
    }
    if ([/system scheduler find name=\$user]!=\"\") do={
      /file print file=\"\$HSFilePath/data/\$iFNameMac.txt\" where name=\"dummyfile\"
      local x 10;while ((\$x>0) and ([/file find name=\"\$HSFilePath/data/\$iFNameMac.txt\"]=\"\")) do={set x (\$x-1);delay 1s}
      /file set \"\$HSFilePath/data/\$iFNameMac\" contents=\"\$user#\$iValidUntil\"
    }
  }
# Create/Update Today Income
  local iDailySales
  if ([/system script find name=todayincome]=\"\") do={/system script add name=todayincome source=\"0\" comment=\"( juanfi ) Daily Income\"}
  local iSaveAmt [tonum [/system script get todayincome source]]
  set iDailySales (\$iSalesAmt + \$iSaveAmt)
  /system script set todayincome source=\"\$iDailySales\"
# Create/Update Monthly Income
  local iMonthSales
  if ([/system script find name=monthlyincome]=\"\") do={/system script add name=monthlyincome source=\"0\" comment=\"( juanfi ) Monthly Income\"}
  local iSaveAmt [tonum [/system script get monthlyincome source]]
  set iMonthSales ( \$iSalesAmt + \$iSaveAmt )
  /system script set monthlyincome source=\"\$iMonthSales\"
# Telegram
  if (\$isTelegram=1) do={
    local iUActive [/ip hotspot active print count-only]
    local iMessage (\"<<======New Sales======>>%0A\".\\
                    \"Date: \$iDateBeg \$iTimeBeg %0A\".\\
                    \"Vendo: \$iVendoNme %0A\".\\
                    \"Voucher: \$user %0A\".\\
                    \"IP: \$address %0A\".\\
                    \"MAC: \$mac %0A\".\\
                    \"Amount: \$iSalesAmt %0A\".\\
                    \"Extended: \$iExtTCode %0A\".\\
                    \"Total Time: \$iUserTime %0A %0A\".\\
                    \"Today Sales: \$iDailySales %0A\".\\
                    \"Monthly Sales: \$iMonthSales %0A\".\\
                    \"Active Users: \$iUActive %0A\".\\
                    \"Valid Until: \$iValidUntil %0A\".\\
                    \"<<=====================>>\")
    local iMessage [\$eReplaceChr (\$iMessage) \" \" \"%20\"]
    /tool fetch url=\"https://api.telegram.org/bot\$iTBotToken/sendmessage\?chat_id=\$iTGrChatID&text=\$iMessage\" keep-result=no
  }
}}
# ------------------------------\r\n")
/ip hotspot user profile set [find name=$hsupPName] on-login=$sOnLogin
put "($hsupinfo) /ip hotspot user profile => onLogin=[$hsupPName]"
}

# ==============================
# Hotspot User Profile onLogout
# ------------------------------
put "($hsupinfo) Setting onLogout..."
/{local sOnLogout ("# $hsupinfo_onLogout #
if (\$cause=\"session timeout\") do={
  /system scheduler set [find name=\$user] interval=5s
}
# ------------------------------\r\n")
/ip hotspot user profile set [find name=$hsupPName] on-logout=$sOnLogout
put "($hsupinfo) /ip hotspot user profile => onLogout=[$hsupPName]"
}

# ------------------------------
put "(juanfi43_hsup.rsc) end..."
}
