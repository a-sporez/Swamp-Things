# How to use in OBS

## 1. Add Image Sources to Your Scene

1. In OBS, add **four image sources**:
   - `Player1Health`
   - `Player1Aura`
   - `Player2Health`
   - `Player2Aura`
2. Set the correct sprtesheet as image for each.

---

## 2. Add Crop Filters

1. Right-click `Player1HealthBar` → **Filters**
2. Click `+` under *Effect Filters* → select **Crop/Pad**
3. Name it exactly: `HealthCrop`
4. Repeat for `Player2Health`
5. Repeat for `Player1Aura` and `Player2Aura`
6. Close the filter windows — no need to adjust values (the script does that)

---

## 3. Load the Lua Script

1. Go to `Tools > Scripts`
2. Click `+`, find the folder where the plugin is located and select `MainEgo.lua`
3. On the right side of the panel, the source names should already be attributed.
4. Make sure the image source matches the plugin source name, you can change those if you want.

---

## 4. Assign Hotkeys

1. Go to `Settings > Hotkeys`
2. Scroll down to find:
   - **Damage Player 1**
   - **Heal Player 1**
   - **Increase Health – Player 2**
   - **Decrease Health – Player 2**
3. Assign keys as desired.

---

## 5. Test It

- Press your hotkeys in OBS preview or while streaming.
- Health bars and aura meters should shift frame-by-frame.
- On health loss or Aura gain, a **brief white flash** should appear.

---