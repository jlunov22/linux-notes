Last update: 02-16-2026

package needed fcitx5-im fcitx5-rime

[de] kde plasma 

Add rime from system settings > input method > [add] rime

for kwin (Wayland) 
No need add env 

for X11

``
    TK_IM_MODULE=fcitx
    QT_IM_MODULE=fcitx
    XMODIFIERS=@im=fcitx
``

Extra

add boshiamy with lua 

need plum 

$ git clone https://github.com/rime/plum.git 

generate boshiamy

`
$ rime_frontend=fcitx5-rime rime-install https://raw.githubusercontent.com/hftsai256/rime-liur-lua/master/liur-lua-packages.conf
`
altered config with other input methods


``
cat ~/.local/share/fcitx5/rime/default.custom.yaml
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

``


[Ref] https://www.ptt.cc/bbs/Linux/M.1614454898.A.F8D.html
