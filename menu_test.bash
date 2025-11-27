#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (c) 2025 Gentoku Morimoto
# SPDX-FileCopyrightText: 2025 Gentoku Morimoto <s24c1123tf@s.chibakoudai.jp>
# SPDX-License-Identifier: GPL-3.0-only
#
# このコマンドは、標準入力で受け取ったジャンルリストから献立を確率的に提案します。
# 標準入力の重複は、そのジャンルの選択確率を上げる「重み」として機能します。

import sys
import random
import argparse
from typing import List, Dict

# --- 1. 献立データ定義 ---
# すべてのデータはこのファイル内で完結させます。

MENU_DATA: Dict[str, List[str]] = {
    "にく": [
        "ハンバーグ",
        "焼肉",
        "ローストビーフ",
        "豚の生姜焼き",
        "鶏の唐揚げ",
    ],
    "さかな": [
        "鯖の塩焼き",
        "刺身",
        "アジフライ",
        "カレイの煮付け",
        "海鮮丼",
    ],
    "中華": [
        "麻婆豆腐",
        "餃子",
        "回鍋肉",
        "炒飯",
        "エビチリ",
    ],
    "イタリアン": [
        "マルゲリータピザ",
        "カルボナーラ",
        "ラザニア",
        "アクアパッツァ",
        "カプレーゼ",
    ],
    "ベジタリアン": [
        "野菜カレー",
        "豆腐ハンバーグ",
        "ひよこ豆のファラフェル",
        "野菜とキノコのグリル",
        "豆乳シチュー",
    ],
    "ジャンクフード": [
        "ハンバーガー",
        "カップ麺",
        "お菓子",
        "フライドチキン",
        "たこ焼き",
    ],
    "パン": [
        "サンドイッチ",
        "クロワッサン",
        "フレンチトースト",
        "カレーパン",
        "トースト＆目玉焼き",
    ],
    "米": [
        "白米と味噌汁",
        "おにぎり",
        "オムライス",
        "牛丼",
        "炊き込みご飯",
    ],
    "パスタ": [
        "ペペロンチーノ",
        "ミートソース",
        "ジェノベーゼ",
        "和風きのこパスタ",
        "ボンゴレ",
    ],
    "揚げ物": [
        "エビフライ",
        "とんかつ",
        "コロッケ",
        "かき揚げ",
        "天ぷら（野菜）",
    ],
    "和食": [
        "味噌汁",
        "だし巻き卵",
        "天ぷら",
        "おひたし",
        "蕎麦",
    ],
    "煮物": [
        "肉じゃが",
        "ブリ大根",
        "おでん",
        "筑前煮",
        "かぼちゃの煮物",
    ],
    "炒め物": [
        "野菜炒め",
        "ニラレバ炒め",
        "ゴーヤチャンプルー",
        "青椒肉絲",
        "きのこのバター炒め",
    ],
}

# --- 2. 関数定義とロジック ---

def parse_args():
    """コマンドライン引数を解析（現在はオプションを使用しないが、将来の拡張のために定義）"""
    parser = argparse.ArgumentParser(
        description="標準入力で与えられたジャンルリストから献立を確率的に提案します。",
        prog="menu_proposer"
    )
    return parser.parse_args()

def main():
    # コマンドライン引数を解析
    parse_args()

    # 標準入力の内容を重みとして格納するリスト
    input_genres: List[str] = []

    try:
        # 1. 標準入力からすべての行を読み込み、ジャンルを抽出
        for line in sys.stdin:
            genre_name = line.strip()

            if not genre_name or genre_name.startswith('#'):
                continue
            
            # 既知のジャンルリストに含まれているかチェック
            if genre_name in MENU_DATA:
                # 含まれていれば、リストに追加（重み付け）
                input_genres.append(genre_name)
            else:
                # 未知のジャンル名は、標準エラー出力に警告を出力
                sys.stderr.write(f"警告: '{genre_name}' は登録ジャンルに含まれないため無視されました。\n")

    except Exception as e:
        # 予期せぬエラーは標準エラー出力へ
        sys.stderr.write(f"エラー: 標準入力の処理中に予期せぬエラーが発生しました: {e}\n")
        sys.exit(1)

    # 有効な入力がなかった場合は、エラーとして処理を終了
    if not input_genres:
        sys.stderr.write("エラー: 有効なジャンルが標準入力から検出されませんでした。\n")
        sys.exit(1)

    try:
        # A. ジャンルを確率的にランダムに選択（重み付けされた選択）
        selected_genre: str = random.choice(input_genres)
        
        # B. 選択されたジャンルから、料理をランダムに選択
        dishes: List[str] = MENU_DATA[selected_genre]
        selected_dish: str = random.choice(dishes)
        
        # C. 標準出力からデータのみを出力 (形式: ジャンル:料理名)
        sys.stdout.write(f"{selected_genre}:{selected_dish}\n")
        
    except Exception as e:
        # 予期せぬエラーは標準エラー出力へ
        sys.stderr.write(f"エラー: 献立選定中に予期せぬエラーが発生しました: {e}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
