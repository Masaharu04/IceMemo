# FadeMemo

撮った写真が設定した期限で自動的に消えるカメラアプリ。  
「残しておきたいわけじゃないけど、今この瞬間は残したい」という用途に向けたiOSアプリです。

## 機能

- **期限付き撮影** — 1日 / 1週間 / 1ヶ月 / 1年 から期限を選んで撮影
- **自動削除** — 期限を過ぎた写真はアプリ起動時に自動削除
- **アルバム** — 撮影済み写真の一覧と残り期限の確認
- **詳細表示** — ピンチズームやクロップ検出に対応した詳細ビュー
- **削除通知** — 期限が近づくとプッシュ通知でお知らせ

## 動作環境

- iOS 17.6 以上
- Xcode 26

## セットアップ

```bash
# 1. リポジトリをクローン
git clone <repo-url>
cd IceMemo

# 2. 自分の開発チームIDを設定
cp xcconfig/Local.xcconfig.sample xcconfig/Local.xcconfig
# Local.xcconfig を開いて DEVELOPMENT_TEAM = XXXXXXXXXX を設定

# 3. Xcode でプロジェクトを開く
open IceImageMemo.xcodeproj
```

詳細は [TEAM_SETUP.md](TEAM_SETUP.md) を参照。

---

## Claude Code スキル

このプロジェクトには Claude Code 用のカスタムスキルが用意されています。  
Claude Code のチャットで `/スキル名` と入力するだけで使えます。

### `/new-ticket` — Notionチケット作成

LEGOの開発チケットデータベースにチケットを作成します。

```
/new-ticket <作りたいチケットの内容>
```

**例:**

```
/new-ticket アルバム画面にカウントバッジを追加したい
/new-ticket 月の期限計算が30日固定になっている
/new-ticket CLAUDE.md を整備する
```

内容からチケット種別（バグ💥 / 機能✨ / 改善🔧 / ドキュメント📋 など）を自動判断し、  
タイトル・アイコン・本文を整えてNotionに登録します。

---

### `/ticket` — チケット実装

Notionチケットの内容をもとに、ブランチ作成から実装・PR作成まで一貫して対応します。

```
/ticket <NotionチケットのURL>
```

**実行内容:**
1. 未コミット差分をスタッシュ
2. チケット内容を取得してステータスを「進行中」に更新
3. ブランチを作成して実装
4. SwiftFormat / SwiftLint チェック
5. コミット・プッシュ・PR作成

---

### `/new-pr` — PR作成

現在のブランチをチェックしてPRを作成します。

```
/new-pr
```

**実行内容:**
1. 未コミット差分の確認
2. `DEVELOPMENT_TEAM` の混入チェック（検出したら中断）
3. SwiftFormat / SwiftLint チェック
4. `git push` してPR作成
5. 関連Notionチケットのステータスを更新
