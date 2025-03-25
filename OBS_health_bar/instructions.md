# Health bar

## How to set up in OBS

### 1. Add Your Health Bar Sprite Sheet
- In OBS, add a new **Image Source** to your scene.
- Name it something like: `HealthBarImage`
- Set the image file to your **spritesheet** (`OBS_health_bar/sprites/element_blue01.png`).

---

### 2. Add a Crop Filter for Animation
- Right-click the `HealthBarImage` source → **Filters**
- Click the `+` under *Effect Filters* → choose **Crop/Pad**
- **Name the filter** exactly: `HealthCrop` (must match your script)
- Hit **Close** once added (you don’t need to manually set values — the script handles that)

---

### 3. Load the Script
- In OBS: `Tools` → `Scripts`
- Click the `+` → select the `healthBar.lua` file
- On the right side under the script’s name:
  - Set **Source Name** to `HealthBarImage` (or whatever you named the image).

---

### 4. Assign Hotkeys
- Go to `Settings` → `Hotkeys`
- Scroll to find **Increase Health** and **Decrease Health** (They will appear after the script is loaded)
- Suggestion:
  - `Page Up` = Increase Health
  - `Page Down` = Decrease Health

---

### 5. Test It
- Press your assigned keys while streaming or previewing.
- You should see the health bar update smoothly across 16 frames (from full to empty).

---

## Notes

- Your `max_health` is `16`
- If your image source doesn’t update:
  - Double-check that the filter is named `HealthCrop`
  - Make sure your source name exactly matches the one you typed in the script field
  - Confirm hotkeys are active in OBS settings

---