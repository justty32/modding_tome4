# particles — 寫「新」粒子檔（劍氣、枝枒蔓延…）

本檔已拆分為三個子檔，各自專注一個主題：

1. **[particles-parts/01-core-mechanics.md](particles-parts/01-core-mechanics.md)** — 三個承重事實（overload 路徑、`setfenv` 注入、`--cheat` 需求）與 `return` 四個值的結構（generator、update、粒子池、紋理），含 generator 欄位表、`nb` 守衛機制、兩條回收路徑。

2. **[particles-parts/02-textures-and-shapes.md](particles-parts/02-textures-and-shapes.md)** — 紋理規格與自製須知，以及形狀速查表（想要 X → 抄哪個原版 `lua`）與四個地雷。

3. **[particles-parts/03-techniques-and-testing.md](particles-parts/03-techniques-and-testing.md)** — 劍氣（blade wave）三種實作路線、枝枒蔓延兩種做法（forks 分支表 vs ENGINE_LINES 逐段生長），以及測試要點。

路徑代號見 [README.md](README.md)。原版粒子檔在 `tome-gfx.team`，解壓：
```bash
unzip -p $G/tome-gfx.team data/gfx/particles/<名字>.lua
```
