# Alsa-USB
_Effortless USB audio support for Retropie + EmulationStation_

`Install script is WIP`

Manual Installation
---
- All files you need are in each directory under `/nexus`
- For each directory, there is a file beginning with `__` - The text following `__` indicates the parent directory path _(where commas are slashes)_
- Some directory names have a prefix. The prefix indicates the necessary file operations:
- `A_` is for append - File(s') **contents** should be inserted into the correspondingly-named and located file
- `S_` is for symlink - File(s) here contain `,,` in their names. **Before** `,,` is the filepath for a symlink to be created. **After** `,,` is the linked file
- `(no prefix)` - File(s) simply need copied into a directory, overwriting any existing file(s) of the same name(s)

**So, to install:**
1. Run `sudo mkdir ~/Alsa-USB && cd ~/Alsa-USB && sudo wget -N -q --show-progress "https://raw.githubusercontent.com/SaberMage/Alsa-USB" && sudo chmod 777 -R ./`
2. Visit the first directory under `/nexus`
3. Perform the corresponding file operations
4. Repeat steps `2` and `3` above for each of the remaining directories under `/nexus`, until all have been processed
5. Reboot the device

After installing:
---
- **Default behavior:** USB audio is enabled when connected, onboard audio is enabled when USB disconnects
- Changes to audio output only occur **outside of gameplay**
- `Behavior`, `USB volume`, and `audio device` can all be modified from the **Alsa-USB** menu, now found under `EmulationStation Home`->`Configs`

**Note**: **Alsa-USB** is compatible with Naprosnia's [RetroPie BGM Player](https://github.com/Naprosnia/RetroPie_BGM_Player)

_An automated install script + menu screenshots are in the works!_
