# 🚀 Destiny Damage Tracker 🚀

Destiny Damage Tracker is a tool for Destiny 2 that helps you keep track of certain statistics and information. This includes the boss's current health, the fireteam's DPS (damage per second), the estimated time to defeat the boss, and more. 

## 🎯 How it Works 🎯

The functionality of Destiny Damage Tracker is pretty straightforward. It counts the pixels in the boss's health bar on the screen and uses this data to calculate the statistics that are presented to you.

## 🛠️ Installation 🛠️

You have two options for installing Destiny Damage Tracker:

- 📂 **Download and Extract**: Download the files, extract them into a preferred folder, and run the "Destiny Damage Tracker.ahk" file.
- 📌 **Releases Page**: Navigate to the releases page and download the most recent release.

## ⚙️ Setup and Settings ⚙️

Before you start using Destiny Damage Tracker, you might want to adjust some settings to fit your preferences. You can do this in the "settings.txt" file in the program's folder. You'll find several options there that allow you to change how the tool looks and behaves.

### 🎚️ Understanding the Settings 🎚️

Here's a brief overview of each setting in the `settings.txt` file:

#### Reload Script Hotkey
A hotkey for swiftly closing and relaunching the program with one button press, handy for applying new settings.

#### Settings GUI Hotkey
Launch a GUI with all raid and dungeon bosses at your fingertips. Upon selection, the tool loads the respective boss's health pool, assuming the on-screen health bar corresponds to that boss. Choose "Default" or "Default with final stand" for a percentage-based health and DPS calculation.

#### Manually Start and Stop DPS Phases
Toggle this option to take control of DPS phases, determining when they start and stop. Note that DPS and certain other metrics are only calculated during DPS phases. If set to 'false', DPS phases commence and conclude automatically based on the boss's health bar changes.

#### Start And Stop DPS Phase Hotkey
A dedicated hotkey to manually control DPS phases—only functional if the above setting is 'true'.

#### Include DPS Calculations
Enabling this option will display sustained and burst DPS numbers, calculated by dividing the damage done by the elapsed time of the DPS phase.

#### DPS Numbers Near Crosshair
Toggle to relocate DPS numbers (if enabled) from below the boss's health bar to flanking the crosshair.

#### Include Burst and Sustained Specifiers
Enable this to add "Burst" and "Sustained" labels for a clear distinction between DPS numbers.

#### Decimal Places in Main Health Percentage
Specify the number of decimal places for the main health percentage displayed under the boss's health bar. Default is set to 2.

#### Include Estimated Boss Health
Enable this setting to display an estimate of the remaining boss health beneath the health percentage.

#### Show Damage Dealt Instead of Boss Health
Switch the displayed number under the health percentage from estimated remaining health to the total damage dealt to the boss.

#### Show Damage Phase Duration
Turn on to display a timer indicating the active DPS phase duration.

#### Show Estimated Time to Kill
Turn on to display the estimated time to defeat the boss based on current DPS and remaining boss health.

#### GUI Text Color
Personalize the text color displayed by the program. Basic colors such as "White", "Red", "Green", and hex color codes are accepted (e.g., "FF0000" for red).

#### GUI Text Font
Customize the text font to any installed on your computer.

#### Make Text Bold
Switch this option on to bold all the text from the program.

#### 1920x1080
Enable this setting for the program to function optimally on 1920x1080 monitors. If disabled, the program adjusts to work for 2560x1440 monitors, which is its default setting.

#### Ultrawide 1440p Monitor
Switch this option on for optimal performance on ultrawide 3440x1440 monitors.

#### Colorblind Setting
Set this to match your in-game colorblind setting. The accepted options are "Normal", "Deuteranopia", "Protanopia", and "Tritanopia".
