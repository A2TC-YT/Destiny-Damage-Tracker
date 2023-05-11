#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%\Gdip_all.ahk

pToken := Gdip_Startup()

global dps_phase_active := false
global boss_health_pool := {}
global boss_final_stand := {}
global boss_list := ""
FileRead, content, %A_ScriptDir%\boss_health.txt
Loop, Parse, content, `n, `r
{
    StringSplit, line, A_LoopField, `,
    boss_health_pool[Trim(line1)] := Trim(line2)
    boss_final_stand[Trim(line1)] := Trim(line3)
    boss_list := boss_list "|" line1
}

Gui, settings: New
Gui, settings: Add, DropDownList, w150 vBossName, 
Gui, settings: Add, Button, gButtonOK, OK

global ColorBlind := "Normal"

global settingsGUIHotkey := "F5"  ; default settings
global startAndStopDPS := "F2"
global reloadScriptHotkey := "F4"
global includeDPSCalculations := 1
global DPSatCrosshair := 0
global includeEstimatedBossHealth := 1
global includeBurstAndSustainedSpecifiers := 1
global textColor := "white"
global textFont := "Helvetica"
global boldText := 1
global showDamageDealt := 0
global decimalPlacesHealthPercentage := 2
global showDamageDuration := 0
global estimateTimeToKill := 0
global 1080pResolution := 0
global manualDPSPhases := 0
global isUltraWide := 0
global boss_health_colors 

FileRead, settings, settings.txt

; Parse each line of the settings
Loop, Parse, settings, `n, `r
{
    ; Split the line into setting and value
    StringSplit, line, A_LoopField, =
    setting := Trim(line1)
    value := Trim(line2)

    ; Check each setting and assign the corresponding value
    if (setting == "Reload Script Hotkey")
        reloadScriptHotkey := value
    if (setting == "Settings GUI Hotkey")
        settingsGUIHotkey := value
    else if (setting == "Start And Stop DPS Phase")
        startAndStopDPS := value
    else if (setting == "Manually Start and Stop DPS Phases")
        manualDPSPhases := ParseBooleanValue(value)
    else if (setting == "Include DPS Calculations")
        includeDPSCalculations := ParseBooleanValue(value)
    else if (setting == "DPS Numbers Near Crosshair")
        DPSatCrosshair := ParseBooleanValue(value)
    else if (setting == "Decimal Places in Main Health Percentage")
        decimalPlacesHealthPercentage := value
    else if (setting == "Include Estimated Boss Health")
        includeEstimatedBossHealth := ParseBooleanValue(value)
    else if (setting == "Show Damage Dealt Instead of Boss Health")
        showDamageDealt := ParseBooleanValue(value)
    else if (setting == "Show Damage Phase Duration")
        showDamageDuration := ParseBooleanValue(value)
    else if (setting == "Show Estimated Time to Kill")
        estimateTimeToKill := ParseBooleanValue(value)
    else if (setting == "Include Burst and Sustained Specifiers")
        includeBurstAndSustainedSpecifiers := ParseBooleanValue(value)
    else if (setting == "GUI Text Color")
        textColor := value
    else if (setting == "GUI Text Font")
        textFont := value
    else if (setting == "Make Text Bold")
        boldText := ParseBooleanValue(value)
    else if (setting == "1920x1080")
        1080pResolution := ParseBooleanValue(value)
    else if (setting == "Ultrawide 1440p Monitor")
        isUltraWide := ParseBooleanValue(value)
    else if (setting == "Colorblind Setting")
    {
        if (value == "Normal" || value == "normal")
            boss_health_colors := findAllColorsBetween(0xD39621, 0xEDB147)
        else if (value == "Deuteranopia" || value == "deuteranopia")
            boss_health_colors := findAllColorsBetween(0x8E8F4E, 0xAAAB6E)
        else if (value == "Protanopia" || value == "protanopia")
            boss_health_colors := findAllColorsBetween(0xC49800, 0xDEB331)
        else if (value == "Tritanopia" || value == "tritanopia" )
            boss_health_colors := findAllColorsBetween(0xBA727F, 0xD88F9B)
    }
}

; Helper function to parse boolean values from the settings file
ParseBooleanValue(value) {
    if (value == "true" || value == "1" || value == "True" || value == "TRUE")
        return 1
    else
        return 0
}

Hotkey, %settingsGUIHotkey%, ShowSettingsGUI
Hotkey, %startAndStopDPS%, manualDPSPhase
Hotkey, %reloadScriptHotkey%, reload_the_script

global change_phase := 0
global time_to_kill := 0
global elapsed_time := 0
global percent_dealt := 0
global stop_loop := 0
global get_back_in_loop := 0
global healthbar_location := "858|1302|845|3"
if (1080pResolution)
    global healthbar_location := "644|977|634|1"

if (1080pResolution)
{
    Gui, bossHealth: Color, 0x010101
    Gui, bossHealth: -Caption +AlwaysOnTop +ToolWindow +LastFound +E0x20
    Gui, bossHealth: Font, % " s12 c" textColor, % textFont
    if (boldText)
        Gui, bossHealth: Font, Bold
    Gui, bossHealth: Add, Text, x860 y1020 w200 h20 vPercentHealth +0x200 +Center
    Gui, bossHealth: Add, Text, x810 y1050 w300 h20 vTotalHealth +0x200 +Center

    Gui, bossHealth: Add, Text, x1320 y1010 w200 h20 vGUI_dps_phase +0x200 +Center
    Gui, bossHealth: Add, Text, x1520 y1010 w200 h20 vGUI_time_to_kill +0x200 +Center
    Gui, bossHealth: Add, Text, x1320 y1040 w200 h20 vDPSDuration +0x200 +Center
    Gui, bossHealth: Add, Text, x1520 y1040 w200 h20 vTimeToKill +0x200 +Center

    Gui, bossHealth: Font, s10
    Gui, bossHealth: Add, Text, x660 y1010 w200 h15 vGUI_burst +0x200 +Center
    Gui, bossHealth: Add, Text, x1060 y1010 w200 h15 vGUI_sustained +0x200 +Center

    if (DPSatCrosshair)
    {
        Gui, bossHealth: Font, s8
        Gui, bossHealth: Add, Text, x760 y530 w200 h20 vHighestDPS +0x200 +Center
        Gui, bossHealth: Add, Text, x960 y530 w200 h20 vAverageDPS +0x200 +Center
    }
    Else
    {
        Gui, bossHealth: Font, s12
        Gui, bossHealth: Add, Text, x660 y1040 w200 h20 vHighestDPS +0x200 +Center
        Gui, bossHealth: Add, Text, x1060 y1040 w200 h20 vAverageDPS +0x200 +Center
    }

    Gui, bossHealth: Show, x0 y0 h1080 NoActivate, Boss Health
}
Else 
{
    Gui, bossHealth: Color, 0x010101
    Gui, bossHealth: -Caption +AlwaysOnTop +ToolWindow +LastFound +E0x20
    Gui, bossHealth: Font, % " s18 c" textColor, % textFont
    if (boldText)
        Gui, bossHealth: Font, Bold
    Gui, bossHealth: Add, Text, x300 y1350 w200 h50 vPercentHealth +0x200 +Center
    Gui, bossHealth: Add, Text, x200 y1390 w400 h50 vTotalHealth +0x200 +Center

    Gui, bossHealth: Add, Text, x950 y1340 w200 h50 vGUI_dps_phase +0x200 +Center
    Gui, bossHealth: Add, Text, x1150 y1340 w200 h50 vGUI_time_to_kill +0x200 +Center
    Gui, bossHealth: Add, Text, x950 y1380 w200 h50 vDPSDuration +0x200 +Center
    Gui, bossHealth: Add, Text, x1150 y1380 w200 h50 vTimeToKill +0x200 +Center

    Gui, bossHealth: Font, s12
    Gui, bossHealth: Add, Text, x0 y1360 w200 h15 vGUI_burst +0x200 +Center
    Gui, bossHealth: Add, Text, x600 y1360 w200 h15 vGUI_sustained +0x200 +Center

    if (DPSatCrosshair)
    {
        Gui, bossHealth: Font, s12
        Gui, bossHealth: Add, Text, x190 y690 w200 h50 vHighestDPS +0x200 +Center
        Gui, bossHealth: Add, Text, x410 y690 w200 h50 vAverageDPS +0x200 +Center
    }
    Else
    {
        Gui, bossHealth: Font, s18
        Gui, bossHealth: Add, Text, x0 y1380 w200 h50 vHighestDPS +0x200 +Center
        Gui, bossHealth: Add, Text, x600 y1380 w200 h50 vAverageDPS +0x200 +Center
    }

    if (isUltraWide)
    {
        healthbar_location := "1298|1302|845|3"
        Gui, bossHealth: Show, x1320 y0 h1440 NoActivate, Boss Health
    }
    Else
        Gui, bossHealth: Show, x880 y0 h1440 NoActivate, Boss Health
}

WinSet, Transparent, 255, Boss Health
WinSet, TransColor, 0x010101, Boss Health

if (showDamageDuration)
    GuiControl bossHealth:, GUI_dps_phase, DPS Phase:
if (estimateTimeToKill)
    GuiControl bossHealth:, GUI_time_to_kill, Time To Kill:

if (includeDPSCalculations)
{
    if (includeBurstAndSustainedSpecifiers && !(DPSatCrosshair))
    {
        GuiControl bossHealth:, GUI_burst, Burst:
        GuiControl bossHealth:, GUI_sustained, Sustained:
    }
}

SetTimer, check_destiny_open, 500
global currently_shown := 1

return

; hide the gui if destiny isnt currently in focus
check_destiny_open:
    IfWinActive, Destiny 2
    {
        if !(currently_shown)
        {
            Gui, bossHealth: Show, NoActivate
            currently_shown := 1
        }
    }
    Else
    {
        if (currently_shown)
        {
            Gui, bossHealth: Hide
            currently_shown := 0
        }
    }
Return

; calculates the number of pixels in the bitmap that fall withing the healthbar color range
bossHealthPercentage(pBitmap, has_final=0)
{
    totalPixels := 0
    healthBarPixels := 0
    Gdip_GetImageDimensions(pBitmap, w, h)
    x := 0
    y := 0
    black_pixels := 0
    loop %h%
    {
        loop %w%
        {
            totalPixels += 1
            color := Gdip_GetPixel(pBitmap, x, y)
            if (boss_health_colors.HasKey(color))
                healthBarPixels += 1
            x += 1
        }
        x := 0
        y += 1
    }
    loop, % has_final
    {
        totalPixels -= 2
        if (healthbar_location == "858|1302|845|3")
            totalPixels -= 7
    } 
    return (healthBarPixels / totalPixels) * 100
}

; functions for getting every possible color the bosses healthbar could be
    findAllColorsBetween(darkColor, LightColor)
    {
        darkArray := convertToRGB(darkColor) 
        lightArray := convertToRGB(lightColor) 
        returnHashTable := {}
        redDifference := lightArray[1] - darkArray[1] + 1
        greenDifference := lightArray[2] - darkArray[2] + 1
        blueDifference := lightArray[3] - darkArray[3] + 1
        redIndex := 0
        greenIndex := 0
        blueIndex := 0
        loop, %redDifference%
        {
            loop, %greenDifference%
            {
                loop, %blueDifference%
                {
                    tempColorArray := [(darkArray[1]+redIndex), (darkArray[2]+greenIndex), (darkArray[3]+blueIndex)]
                    tempColor := format("{:s}", convertToHex(tempColorArray))
                    returnHashTable[tempColor] := 1
                    blueIndex++
                }
                blueIndex := 0
                greenIndex++
            }
            greenIndex := 0
            redIndex++
        }
        return returnHashTable
    }

    convertToHex(array)
    {
        return format("0xff{:02x}{:02x}{:02x}", array*) 
    }

    convertToRGB(color) 
    {
        red := "0x" . SubStr(color, 3, 2)
        green := "0x" . SubStr(color, 5, 2)
        blue := "0x" . SubStr(color, 7, 2)
        array := [format("{:d}", red), format("{:d}", green), format("{:d}", blue)]
        convertToHex(array)
        return array
    }
; =============================

Return

; this i sthe main driving fucntion in this script
calculateDPS(bossName)
{
    global dps_start_time
    global total_damage := 0
    global highest_dps := 0
    global last_boss_hp_percent
    global time_of_last_damage

    stop_loop := 0

    boss_max_hp := boss_health_pool[bossName]
    final_stand := boss_final_stand[bossName]
    If (bossName == "default with final stand" || bossName == "default")
        is_default := 1
    Else
        is_default := 0

    if (showDamageDuration)
        SetTimer, show_damage_duration, 50
    if (estimateTimeToKill)
        SetTimer, calculate_kill_time, 100

    Loop,
    {
        if (currently_shown)
        {
            if (stop_loop)
                Break

            ; take a screenshot and find the boss health percentage
            pBitmap := Gdip_BitmapFromScreen(healthbar_location)
            boss_hp_percent := bossHealthPercentage(pBitmap, final_stand)

            percent_dealt := 1 - (boss_hp_percent/100) ; temporary to help find boss actual health pools

            ; calculate the total boss hp left or dealt depending on user preference
            if (showDamageDealt)
                boss_total_health := FormatWithCommas(Round((1-(boss_hp_percent/100))*boss_max_hp, 0))
            Else
                boss_total_health := FormatWithCommas(Round((boss_hp_percent/100)*boss_max_hp, 0))

            ; if there is no damage phase currently active and the boss health goes down start a damage phase
            if ((!dps_phase_active && boss_hp_percent < last_boss_hp_percent && !manualDPSPhases) || (change_phase && !dps_phase_active))
            {
                ; DPS phase starts
                change_phase := 0
                dps_phase_active := true
                dps_start_time := A_TickCount
                time_of_last_damage := A_TickCount
            }

            if (boss_hp_percent != last_boss_hp_percent && boss_hp_percent <= 0.1)
            {
                Sleep, 50
                pBitmap := Gdip_BitmapFromScreen(healthbar_location)
                boss_hp_percent := bossHealthPercentage(pBitmap, final_stand)
            }

            ; if the damage phase is active then calculate dps and related variables
            else if (dps_phase_active)
            {
                ; damage dealt since last tick, and add it to the total damage dealt
                damage_this_tick := (last_boss_hp_percent - boss_hp_percent) * boss_max_hp / 100
                if (damage_this_tick > 0)
                    total_damage += damage_this_tick

                ; update the last time damage was dealt if boss hp changes
                if (last_boss_hp_percent != boss_hp_percent)
                    time_of_last_damage := A_TickCount

                ; update the elapsed time
                elapsed_time := Round((A_TickCount - dps_start_time) / 1000, 2)  ; Convert from ms to s

                ; calculate the average dps and adjust highest dps if its changed
                if (is_default)
                {
                    current_dps := Round((total_damage / elapsed_time), 3)
                    if (elapsed_time >= 0.25)
                        highest_dps :=  Round((max(highest_dps, current_dps)), 3)
                }
                Else
                {
                    current_dps := Round((total_damage / elapsed_time), 0)
                    if (elapsed_time >= 0.25)
                        highest_dps :=  Round((max(highest_dps, current_dps)), 0)
                }

                ; calculate the time to kill the boss based on the current dps and the hp left
                time_to_kill := Round((boss_max_hp*(boss_hp_percent/100))/current_dps, 2)
            }

            ; if no damage dealt for 8 seconds end the dps phase
            if (((A_TickCount - time_of_last_damage) >= 8000 && !manualDPSPhases) || (change_phase && dps_phase_active))
            {
                change_phase := 0
                dps_phase_active := false
                total_damage := 0
                highest_dps := 0
                if (includeDPSCalculations)
                {
                    GuiControl bossHealth:, HighestDPS, 0
                    GuiControl bossHealth:, AverageDPS, 0
                }
                if (showDamageDuration)
                    GuiControl bossHealth:, DPSDuration, 0
                if (estimateTimeToKill)
                    GuiControl bossHealth:, TimeToKill, 0
            }

            ; update the gui
            if (last_boss_hp_percent != boss_hp_percent)
            {
                GuiControl bossHealth:, PercentHealth, % Round(boss_hp_percent, decimalPlacesHealthPercentage) "%"
                if (includeEstimatedBossHealth && !(is_default))
                    GuiControl bossHealth:, TotalHealth, % boss_total_health " / " FormatWithCommas(boss_max_hp)
            }

            if (dps_phase_active)
            {
                if (includeDPSCalculations)
                {
                    if (is_default)
                    {
                        GuiControl bossHealth:, AverageDPS, % FormatWithCommas(current_dps) "%"
                        GuiControl bossHealth:, HighestDPS, % FormatWithCommas(highest_dps) "%"
                    }
                    Else
                    {
                        GuiControl bossHealth:, AverageDPS, % FormatWithCommas(current_dps)
                        GuiControl bossHealth:, HighestDPS, % FormatWithCommas(highest_dps)
                    }
                }

                if (showDamageDuration)
                    GuiControl bossHealth:, DPSDuration, % elapsed_time    
                if (estimateTimeToKill)
                    GuiControl bossHealth:, TimeToKill, % time_to_kill  
            }    

            ; update the last boss hp to be the current boss health
            last_boss_hp_percent := boss_hp_percent
            Sleep, 30
        }
        Else
            Sleep, 100
    }
    GuiControl bossHealth:, HighestDPS, 
    GuiControl bossHealth:, AverageDPS, 
    GuiControl bossHealth:, PercentHealth, 
    GuiControl bossHealth:, TotalHealth,
    stop_loop := 0
    Return
}

calculate_kill_time:
    if (dps_phase_active)
        GuiControl bossHealth:, TimeToKill, % time_to_kill
Return

show_damage_duration:
    if (dps_phase_active)
        GuiControl bossHealth:, DPSDuration, % elapsed_time
Return

reset_dps_gui:
    SetTimer, reset_dps_gui, Off
    GuiControl bossHealth:, HighestDPS, 
    GuiControl bossHealth:, AverageDPS, 
Return

FormatWithCommas(number)
{
    return RegExReplace(number, "(\d)(?=(?:\d{3})+(?:\.|$))", "$1,")
}

ButtonOK:
    Gui, settings: Submit
    Gui, settings: Hide
    calculateDPS(BossName)
return

ShowSettingsGUI:
    stop_loop := 1
    boss_list := ""
    FileRead, content, %A_ScriptDir%\boss_health.txt
    Loop, Parse, content, `n, `r
    {
        StringSplit, line, A_LoopField, `,
        boss_health_pool[Trim(line1)] := (Trim(line2), Trim(line3))
        boss_list := boss_list "|" line1
    }
    GuiControl settings:, BossName, % boss_list
    Gui, settings: Show
Return

manualDPSPhase:
    if (manualDPSPhases)
        change_phase := 1
Return

reload_the_script:
Reload

^Esc::ExitApp