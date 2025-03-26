# How to use in OBS

## 1. Prepare Your Spritesheet

Make sure your spritesheet:
- Is a **single row of frames**, each `458×35` pixels
- Contains **18 frames**:
  - Frame 0 = full health
  - Frame 16 = empty
  - Frame 17 = full bar in white (used for flashing)

---

## 2. Add Image Sources to Your Scene

1. In OBS, add **two image sources**:
   - `Player1HealthBar`
   - `Player2HealthBar`
2. Set the spritesheet as the image for both

---

## 3. Add Crop Filters

1. Right-click `Player1HealthBar` → **Filters**
2. Click `+` under *Effect Filters* → select **Crop/Pad**
3. Name it exactly: `HealthCrop`
4. Repeat for `Player2HealthBar`
5. Close the filter windows — no need to adjust values (the script does that)

---

## 4. Load the Lua Script

1. Go to `Tools > Scripts`
2. Click `+`, then select your script file (e.g., `healthBarFlash2P.lua`)
3. On the right side of the panel, fill in the fields:
   - **Player 1 Source** = `Player1HealthBar`
   - **Player 2 Source** = `Player2HealthBar`

---

## 5. Assign Hotkeys

1. Go to `Settings > Hotkeys`
2. Scroll down to find:
   - **Increase Health – Player 1**
   - **Decrease Health – Player 1**
   - **Increase Health – Player 2**
   - **Decrease Health – Player 2**
3. Assign keys as desired:
   - `Page Up / Page Down` for Player 1
   - `Home / End` for Player 2

---

## 6. Test It

- Press your hotkeys in OBS preview or while streaming.
- Health bars should shift frame-by-frame.
- On health loss, a **brief white flash** should appear, then return to the normal state.

---

## Notes

- Make sure the **Crop filter** is named `"HealthCrop"` for each source
- Make sure both **source names match** exactly what you type into the script fields
- The **flash frame** (frame 17) must exist at the end of the spritesheet
- Health is clamped between `0` and `16`

---