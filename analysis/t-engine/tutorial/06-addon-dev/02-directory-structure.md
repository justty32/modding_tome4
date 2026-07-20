一個完整的 Addon 結構如下（全部可選，按需使用）：

```
game/addons/my-addon/
├── init.lua          ← 必須；Addon 元資料
├── hooks/
│   └── load.lua      ← 遊戲事件 hook（最常用）
├── superload/
│   └── mod/class/Actor.lua   ← 攔截並包裝現有 Lua 模組
├── overload/
│   └── mod/class/MyClass.lua ← 完全替換現有 Lua 模組
└── data/
    ├── birth/                ← 職業/種族描述符
    ├── talents/              ← 天賦定義
    └── ...                   ← 任意遊戲資料
```

---
