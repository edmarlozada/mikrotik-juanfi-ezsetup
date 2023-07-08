# ==============================
# Mikrotik JuanFi Income
# by: Chloe Renae & Edmar Lozada
# ==============================
/{put "(JuanFi Income) Config/Setup..."

# ==============================
# JuanFi Daily & Monthly Income
# ------------------------------
if ([/system script find name=todayincome]="") do={
      /system script  add name=todayincome}
/system script set [find name=todayincome] source="0" comment="JuanFi Daily Income"
put "(JuanFi Income) /system script => name=[todayincome]"

if ([/system script find name=monthlyincome]="") do={
      /system script  add name=monthlyincome}
/system script set [find name=monthlyincome] source="0" comment="JuanFi Monthly Income"
put "(JuanFi Income) /system script => name=[monthlyincome]"

# ==============================
# JuanFi Reset Daily/Monthly Income
# ------------------------------
/{local eName "JuanFi Reset Income"
/system scheduler remove [find name="Reset Daily Income"]
/system scheduler remove [find name="Reset Monthly Income"]
if ([/system scheduler find name=$eName]="") do={
      /system scheduler  add name=$eName}
/system scheduler set [find name=$eName] start-time=00:00:02 interval=1d \
 comment="juanfi_scheduler: JuanFi Reset Income" \
 on-event=("# JuanFi Reset Income #

# Reset Daily Income
  /system script set source=\"0\" todayincome

# Reset Monthly Income (1st day of the month)
if ([pick [/system clock get date] 4 6]=\"01\") do={
  /system script set source=\"0\" monthlyincome
}
# ------------------------------\r\n")
put "(JuanFi Income) /system scheduler => name=[$eName]"
}

# ------------------------------
put "(juanfi_income.rsc) end..."
}
