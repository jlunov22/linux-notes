# fcitx5 Install Notes

KDE Plasma input method setup. Last updated 2026-02-16.

## Packages

```
fcitx5-im fcitx5-rime
```

## Add Rime

System Settings → Input Method → [add] Rime.

## Environment variables (X11 only)

Not needed under KWin/Wayland.

```
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```

## Add Boshiamy (Lua)

Requires `plum`:

```
git clone https://github.com/rime/plum.git
```

Generate Boshiamy:

```
rime_frontend=fcitx5-rime rime-install https://raw.githubusercontent.com/hftsai256/rime-liur-lua/master/liur-lua-packages.conf
```

## Custom schema config

To use alongside other input methods, edit `~/.local/share/fcitx5/rime/default.custom.yaml`:

```yaml
__patch:
# Rx: hftsai256/rime-liur-lua:install: {
  - patch/+:
      schema_list:
        - {schema: liur}            # 嘸蝦米 (Liu-Lua)
        - {schema: bopomofo}        # 注音 (Standard Bopomofo)
        - {schema: luna_pinyin}     # 朙月拼音 (Traditional Pinyin)
        - {schema: cangjie5}        # 倉頡五代
  - patch/key_binder/bindings/+:
      - { accept: period, send: period, when: has_menu }                   # 輸入. (Input period while menu is open)
      - { accept: "Control+period", toggle: simplification, when: always } # 進行簡繁切換 (Toggle Simp/Trad)
      - { accept: "Control+apostrophe", toggle: liu_w2c, when: always }    # 顯示同音字 (Show homophones - Liu only)
      - { accept: "Control+slash", toggle: extended_charset, when: always} # 擴展字集
      - { accept: "Shift+space", toggle: full_shape, when: always}         # 全半形切換
```

## Reference

[ptt.cc thread](https://www.ptt.cc/bbs/Linux/M.1614454898.A.F8D.html)
