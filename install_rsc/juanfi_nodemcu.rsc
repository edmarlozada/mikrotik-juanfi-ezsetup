# ==============================
# Mikrotik JuanFi NodeMCU
# by: Chloe Renae & Edmar Lozada
# ==============================
/{put "(JuanFi NodeMCU) Config/Setup..."

local cfg [[parse [/system script get "cfg-juanfi" source]]]
local iUsrGroup ($cfg->"NodeUsrGroup")
local iUserName ($cfg->"NodeUserName")
local iUserPass ($cfg->"NodeUserPass")
local iUserNote ($cfg->"NodeComment")
local iVendoEnd ($cfg->"NodeEndIP")
local iVendoMac ($cfg->"NodeMAC")
local iDHServer ($cfg->"HSDHCPServer")

# ------------------------------
# Do not edit below this point!
# ------------------------------
local iHSInter [/ip dhcp-server get [find name=$iDHServer] interface]
local iVendoIP  [/ip address get [find interface=$iHSInter] address]
set   iVendoIP  [pick $iVendoIP 0 [find $iVendoIP "." [find $iVendoIP "." [find $iVendoIP "."]]]]
set   iVendoIP  "$iVendoIP.$iVendoEnd"

# ==============================
# Wireless Profiles
# ------------------------------
if ([/interface wireless find default-name=wlan1]!="") do={
  /interface wireless set [find default-name=wlan1] \
    ssid="JuanFi" \
    security-profile=default
  put "(JuanFi NodeMCU) /interface wireless => ssid=[JuanFi] security-profile=[]"
}

# ==============================
# UserName and Password ( NodeMCU )
# ------------------------------
if ([/user group find name=$iUsrGroup]="") do={
      /user group  add name=$iUsrGroup}
/user group set [find name=$iUsrGroup] comment="JuanFi API Group" \
 policy="local,telnet,ssh,reboot,read,write,test,password,web,sniff,sensitive,api,romon,tikapp,ftp,policy,winbox,!dude"
if ([/user find name=$iUserName]="") do={
      /user  add name=$iUserName  password=$iUserPass group=$iUsrGroup }
/user  set [find name=$iUserName] password=$iUserPass group=$iUsrGroup comment="JuanFi API Users"
put "(JuanFi NodeMCU) /user => name=[$iUserName] group=[$iUsrGroup]"

# ==============================
# DHCP Lease ( NodeMCU )
# ------------------------------
/ip dhcp-server lease remove [find address=$iVendoIP]
if ([/ip dhcp-server lease find mac-address=$iVendoMac server=$iDHServer dynamic]!="") do={
     /ip dhcp-server lease make-static [find mac-address=$iVendoMac server=$iDHServer] }
if ([/ip dhcp-server lease find mac-address=$iVendoMac server=$iDHServer]="") do={
     /ip dhcp-server lease  add mac-address=$iVendoMac server=$iDHServer  address=$iVendoIP }
/ip dhcp-server lease set [find mac-address=$iVendoMac server=$iDHServer] address=$iVendoIP \
    comment="( $iUserNote )"
put "(JuanFi NodeMCU) /ip dhcp-server lease => mac-address=[$iVendoMac] server=[$iDHServer]"

# ==============================
# IP Hotspot IP-Binding ( NodeMCU )
# ------------------------------
if ([/ip hotspot ip-binding find mac-address=$iVendoMac]="") do={
     /ip hotspot ip-binding  add mac-address=$iVendoMac }
/ip hotspot ip-binding set [find mac-address=$iVendoMac] \
    type=bypassed comment="( $iUserNote )"
put "(JuanFi NodeMCU) /ip hotspot ip-binding => mac-address=[$iVendoMac] type=[bypassed]"

# ==============================
# ip firewall filter ( NodeMCU )
# ------------------------------
# if ([/ip firewall filter find src-address=$iVendoIP chain=input action=accept]="") do={
#       /ip firewall filter  add src-address=$iVendoIP chain=input action=accept  comment="( $iUserNote )" place-before=0 }
# /ip firewall filter  set [find src-address=$iVendoIP chain=input action=accept] comment="( $iUserNote )"
# put "(JuanFi NodeMCU) /ip firewall filter => src-address=[$iVendoIP] chain=[input] action=[accept]"

# ==============================
# ip hotspot walled-garden ( NodeMCU )
# ------------------------------
# if ([/ip hotspot walled-garden ip find dst-address=$iVendoIP]="") do={
#       /ip hotspot walled-garden ip  add dst-address=$iVendoIP  action=accept disabled=no comment="( $iUserNote )" }
# /ip hotspot walled-garden ip  set [find dst-address=$iVendoIP] action=accept disabled=no comment="( $iUserNote )"
# put "(JuanFi NodeMCU) /ip hotspot walled-garden ip => dst-address=[$iVendoIP] action=[accept]"


# ------------------------------
put "(juanfi_nodemcu.rsc) end..."
}
