# Release notes template

## Highlights
- <kratko: glavne promene u ovom izdanju>
- <npr. nove opcije / instaleri / kompatibilnost>

## Installation
### Debian / Ubuntu
```bash
sudo ./install_debian_system_wide.sh
```

### openSUSE (Leap/Tumbleweed)
```bash
sudo ./install_opensuse_system_wide.sh
```

## Compatibility
- `install_system_wide.sh` je alias koji prosleđuje na `install_debian_system_wide.sh`.

## Notes
- `konvertor` je sistemska komanda (više korisnika, bilo koji folder).
- Tag: `<verzija>`

---

## Komanda za objavu release-a

```bash
GH_PAGER=cat gh release create <verzija> \
  --title "<verzija>" \
  --notes-file RELEASE_NOTES_TEMPLATE.md
```

## Komanda za izmenu postojećeg release-a

```bash
GH_PAGER=cat gh release edit <verzija> --notes-file RELEASE_NOTES_TEMPLATE.md
```
