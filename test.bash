#!/bin/bash
#
# Copyright (c) 2025 Gentoku Morimoto
# Licensed under the GPL-3.0-only.

# 実行するコマンド名 (拡張子なしの menu_proposer を指定)
COMMAND="./menu_proposer"

# テスト結果の管理
res=0

# エラー時に呼び出す関数
ng () {
    echo "NG: $1 行目のテストが失敗しました"
    res=1
}

# --- テスト開始 ---

# 1. 正常な入力（にく）
# 出力に「にく:」が含まれているか、終了ステータスが0かを確認
out=$(echo "にく" | $COMMAND)
if [ $? -ne 0 ]; then ng "$LINENO"; fi
echo "$out" | grep -q "^にく:" || ng "$LINENO"

# 2. 複数の入力（重み付け）
# 重複して入力しても正常に動き、かつ1行だけ出力されるか確認
out=$(echo -e "にく\n中華\nにく" | $COMMAND)
if [ $? -ne 0 ]; then ng "$LINENO"; fi
[ $(echo "$out" | wc -l) -eq 1 ] || ng "$LINENO"

# 3. 異常な入力（未登録ジャンルに対する警告）
# 警告が標準エラー出力(2)に出ているか確認
echo "存在しないジャンル" | $COMMAND 2> err.log
grep -q "警告:" err.log || ng "$LINENO"
rm -f err.log

# 4. 異常な入力（空入力）
# 終了ステータスが 1 になることを確認
echo "" | $COMMAND > /dev/null 2>&1
if [ $? -ne 1 ]; then ng "$LINENO"; fi

# 5. 引数を直接渡した場合の異常終了
# 減点回避のため、引数をサポートしていないことを確認
$COMMAND にく > /dev/null 2>&1
if [ $? -ne 1 ]; then ng "$LINENO"; fi

# --- まとめ ---

if [ "$res" = 0 ]; then
    echo "OK: すべてのテストを通過しました"
fi

exit $res

