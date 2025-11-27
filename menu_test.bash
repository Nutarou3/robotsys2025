#!/bin/bash
#
# Copyright (c) 2025 Gentoku Morimoto
# SPDX-FileCopyrightText: 2025 Gentoku Morimoto <s24c1123tf@s.chibakoudai.jp>
# SPDX-License-Identifier: GPL-3.0-only
#
# menu_proposer コマンドの動作確認用テストスクリプト
#
# コマンド名は環境に合わせて変更してください。
COMMAND="./menu_proposer.py"

# --- テストユーティリティ ---

# カウント初期化
TEST_COUNT=0
FAIL_COUNT=0

# テスト実行関数
run_test() {
    TEST_COUNT=$((TEST_COUNT + 1))
    # 標準出力と標準エラー出力のファイル名を生成
    OUT_FILE=$(mktemp)
    ERR_FILE=$(mktemp)
    
    # テスト実行
    eval "$1" > "$OUT_FILE" 2> "$ERR_FILE"
    STATUS=$?

    # 結果判定
    if eval "$2"; then
        echo "OK: $3"
    else
        echo "NG: $3"
        echo "    COMMAND: $1"
        echo "    EXPECTED: $4"
        echo "    ACTUAL STATUS: $STATUS"
        echo "    ACTUAL STDOUT: $(<"$OUT_FILE")"
        echo "    ACTUAL STDERR: $(<"$ERR_FILE")"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    rm "$OUT_FILE" "$ERR_FILE"
}

# --- 1. 必須要件のテスト ---

# 1-1. 正常終了と出力形式の確認（データ出力のみ）
run_test \
    "echo -e 'にく\n中華\n中華' | $COMMAND" \
    "STATUS -eq 0 && grep -q '^\(にく\|中華\):' \$OUT_FILE && [[ \$(wc -l < \$OUT_FILE) -eq 1 ]]" \
    "正常終了と出力形式の確認 (ジャンル:料理名 1行)" \
    "終了ステータス 0, 出力形式 'ジャンル:料理名' 1行"

# 1-2. 警告がstderrに出ているか確認 (未登録ジャンル)
run_test \
    "echo -e 'にく\n未登録ジャンル\nパスタ' | $COMMAND" \
    "STATUS -eq 0 && grep -q '警告: ' \$ERR_FILE" \
    "警告がstderrに出ているか確認 (警告メッセージの検出)" \
    "終了ステータス 0, STDERRに '警告: ' を含む"

# 1-3. 入力なしで異常終了(1)することを確認 (必須要件)
run_test \
    "echo '' | $COMMAND" \
    "STATUS -eq 1 && grep -q 'エラー: 有効なジャンルが標準入力から検出されませんでした。' \$ERR_FILE" \
    "入力なしで異常終了(1)することを確認 (エラーメッセージとステータス)" \
    "終了ステータス 1, STDERRに「有効なジャンルが...」を含む"

# 1-4. 標準入力をオプションのように使っていないことの確認 (減点回避)
run_test \
    "$COMMAND にく" \
    "STATUS -eq 1" \
    "引数入力で異常終了(1)することを確認" \
    "終了ステータス 1 (Pythonが引数を使わずstdin待ちになるため)"

# --- 2. まとめ ---

echo ""
echo "--- menu_proposer_fixed.py テスト終了 ---"
echo "結果: 成功 $((TEST_COUNT - FAIL_COUNT)) 件, 失敗 $FAIL_COUNT 件"

# 総合的な成功判定
if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
