### 1.1 入口 & 視窗管理
- **`main.c`** — 程式入口；SDL2 視窗、OpenGL context、主迴圈（遊戲 tick、事件分派、FPS 控制）、搖桿/手把支援。

### 1.2 顯示 & 渲染
| 檔案 | 功能 |
|------|------|
| `display_sdl.c / .h` | SDL2 渲染後端，FBO、材質管理 |
| `shaders.c / .h` | GLSL shader 載入、編譯、管理 |
| `map.c / .h` | 地圖圖磚快速繪製（C 層加速） |
| `particles.c / .h` | 粒子系統渲染 |
| `glew.c / .h` | OpenGL 擴充載入 |

### 1.3 音訊
- **`music.c / .h`** — 音樂播放（OGG/vorbis）、音效。

### 1.4 Lua 虛擬機
- **`src/lua/`** — 標準 Lua 5.1
- **`src/luajit2/`** — LuaJIT 2.x（可替換，由編譯選項決定）
- **`core_lua.c / .h`** — 將所有 C 功能注入 Lua `core.*` 命名空間

### 1.5 虛擬檔案系統
- **`src/physfs/`** + **`physfs.c`** — PhysFS 函式庫，支援直接讀取 zip 壓縮包（`.teae`/`.team`），讓模組以單一壓縮包發佈。

### 1.6 亂數
- **`SFMT.c / .h`** — SIMD 版 Mersenne Twister（週期 2^19937-1），高品質偽亂數。
- **`noise.c`** + **`src/libtcod_import/`** — Perlin/Simplex noise（來自 libtcod）。

### 1.7 視野演算法 (FOV)
- **`fov.c / .h`** + **`src/fov/`** — 多種 FOV 演算法（recursive shadowcasting 等）。

### 1.8 Wave Function Collapse
- **`src/wfc/`** (C++) — WFC 演算法實作，供程序化地圖生成使用。

### 1.9 網路 & 在線功能
- **`src/luasocket/`** — TCP/UDP socket（LuaSocket 移植）
- **`profile.c / .h`** — 玩家在線 profile、排行榜、成就上傳
- **`serial.c / .h`** — 序列化協議
- **`src/web-cef3/`** / **`src/web-awesomium/`** — 嵌入式瀏覽器（可選編譯）
- **`discord-te4.c`** + **`src/discord-rpc/`** — Discord Rich Presence 整合

### 1.10 其他工具
- **`src/expat/`** + **`src/lxp/`** — XML 解析（Expat + Lua 綁定）
- **`src/zlib/`** + **`src/bzip2/`** — 壓縮/解壓縮
- **`src/lzlib/`** — zlib 的 Lua 綁定
- **`src/utf8proc/`** — UTF-8 字串處理
- **`src/luamd5/`** — MD5 雜湊
- **`src/luaprofiler/`** — Lua 效能分析器
- **`src/luabitop/`** — Lua 位元運算
- **`src/lpeg/`** — LPeg 解析表達式語法庫
- **`getself.c`** — 取得執行檔自身路徑（自解壓縮支援）
- **`bspatch.c`** — 二進位差分補丁（熱更新）

---
