#!/usr/bin/env bash
# 訊息輸出與 usage。用 `source` 引入，不要直接執行。
#
# 四個等級固定用同一組色碼與寬度，讓 agent 能用 grep 可靠地判讀腳本輸出：
#   [FAIL] → stderr 並 exit 1     [WARN] → stderr，不中止
#   [INFO] → stdout，過程訊息      [ OK ] → stdout，某一步成功
# 判定結果請一律看**退出碼**，不要 parse 這些字串。

die()  { printf '\033[31m[FAIL]\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m[ OK ]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*" >&2; }

# usage_from_header <script_path>
#
# 把腳本開頭那段 `#` 註解當成說明書印出來（跳過 shebang，遇到第一個非註解行停）。
# 好處是說明只有一份、永遠不會和實作對不上——改了檔頭就等於改了 --help。
usage_from_header() {
    sed -e '1{/^#!/d}' -e '/^#/!Q' -e 's/^# \{0,1\}//' "$1"
}

# handle_help_flag "$@" —— 放在每支腳本參數解析的最前面
handle_help_flag() {
    case "${1:-}" in
        -h|--help) usage_from_header "${BASH_SOURCE[1]}"; exit 0 ;;
    esac
}
