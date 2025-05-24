# How to use in OBS

## 1. Add Image Sources to Your Scene

1. In OBS, add **eight image sources**:
   - `Player1Health`
   - `Player1Aura`
   - `Player1Psy`
   - `Player1Gut`
   - `Player2Health`
   - `Player2Aura`
   - `Player2Psy`
   - `Player2Gut`
2. Set the correct spritesheet as image for each.

---

## 2. Add Crop Filters

1. For each image source do: Right-click → **Filters**
2. Click `+` under *Effect Filters* → select **Crop/Pad**
3. Name it exactly (for each): `HealthCrop`, `AuraCrop`, `PsyCrop`, `GutCrop`
4. Close the filter windows — no need to adjust values (the script does that)

---

## 3. Load the Lua Script

1. Go to `Tools > Scripts`
2. Click `+`, find the folder where the plugin is located and select `MainEgo.lua`
3. On the right side of the panel, the source names should already be attributed.
4. Make sure the image source matches the plugin source name, you can change those if you want.

---

## 4. Assign Hotkeys

1. Go to `Settings > Hotkeys`
2. Scroll down to find the hotkeys declared by the script.
3. Assign keys as desired.

---

## 5. Test It

- Press your hotkeys in OBS preview or while streaming.
- Health bars and aura meters should shift frame-by-frame.
- On health loss or Aura gain, a **brief white flash** should appear.

---
