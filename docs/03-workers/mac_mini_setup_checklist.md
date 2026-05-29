# Mac mini Image Node Setup Checklist

Purpose: configure a secondary/fallback image node.

## Hardware
- [ ] Apple Silicon Mac mini
- [ ] 16GB unified memory minimum, 32GB preferred
- [ ] 512GB storage minimum, 1TB preferred

## Operating system
- [ ] macOS updated
- [ ] Sleep/energy settings adjusted for always-on use
- [ ] File sharing and remote access configured

## Software
- [ ] Hermes job receiver or orchestration client installed
- [ ] ComfyUI cloud path or supported workflow path selected
- [ ] Any required ARM64 dependencies installed

## Storage
- [ ] Drafts folder created
- [ ] Finals folder created
- [ ] Archive folder created
- [ ] WebDAV target reachable

## Validation
- [ ] Run a low-priority draft job
- [ ] Confirm artifact lands in WebDAV
- [ ] Confirm fallback routing works
