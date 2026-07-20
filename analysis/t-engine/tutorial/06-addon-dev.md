# 教學 06：製作第一個 ToME Addon

> **目標**：從零開始製作一個 ToME Addon，學會三種整合機制（hooks / superload / overload），並以一個完整的「新增職業」範例貫穿全程。
>
> **前置**：閱讀 [教學 01](./01-hello-dungeon.md) 了解 TE4 基礎結構；熟悉 Lua 的 `require`、閉包、metatables。


> 本文件為自動產生的索引檔，原始大檔已按章節拆分。

## 目錄

- [1. Addon 是什麼](06-addon-dev/01-what-is-an-addon.md)
- [2. 目錄結構](06-addon-dev/02-directory-structure.md)
- [3. `init.lua`：Addon 元資料](06-addon-dev/03-init-lua-metadata.md)
- [4. 三種整合機制](06-addon-dev/04-three-integration-mechanisms.md)
- [5. `data/` 目錄](06-addon-dev/05-data-directory.md)
- [6. 完整範例：新增一個職業](06-addon-dev/06-complete-example-new-class.md)
- [7. 測試開發中的 Addon](06-addon-dev/07-testing-addon.md)
- [8. Superload 鏈（多個 Addon 同時存在時）](06-addon-dev/08-superload-chain.md)
- [9. 打包發布](06-addon-dev/09-packaging-release.md)
- [10. 參考：實際 Addon 分析](06-addon-dev/10-reference-addon-analysis.md)
- [11. 小結](06-addon-dev/11-summary.md)
