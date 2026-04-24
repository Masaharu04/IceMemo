# チケット実装スキル

引数として渡されたNotionチケットURL（または説明）をもとに、ブランチ作成からPR作成まで一貫して対応する。

## 手順

### 1. 事前準備

**未コミット差分の確認とスタッシュ**
```bash
git status --short
```
- 差分があれば `git stash push -m "wip: before ticket work"` でスタッシュする
- 差分がなければそのまま進む

**ブランチ作成**
- チケット内容からブランチ名を決める（例: `feature/localize-camera-period-labels`）
- `git checkout -b <branch-name>` で新規ブランチを作成する

### 2. チケット取得

引数がNotionのURLであれば `notion-fetch` ツールで内容を取得する。
チケットの内容を把握してから実装方針を考える。

**ステータスを「進行中」に更新（Notion MCPが使える場合）:**
- ブランチ作成後、`notion-update-page` ツールでチケットのステータスプロパティを「進行中」に変更する
- Notion MCPが使えない場合はスキップしてそのまま進む

### 3. 実装

**シンプルさを最優先にする:**
- 最小限の変更で要件を満たす
- 新しい抽象化・ヘルパーを増やさない
- 既存パターンに合わせる

**`project.pbxproj` の扱い:**
- ファイル追加など本当に必要な変更のみ行う
- `DEVELOPMENT_TEAM` は絶対にコミットしない
- ステージする **前に** 必ず確認:
  ```bash
  git diff -- IceImageMemo.xcodeproj/project.pbxproj | grep -i "DEVELOPMENT_TEAM"
  ```
  **検出された場合:**
  1. `git restore IceImageMemo.xcodeproj/project.pbxproj` で元に戻す
  2. project.pbxproj **以外** のファイルだけをステージしてコミットする
  3. 必要な変更がある場合のみ手動で再適用する
  
  **検出されなかった場合:** 通常通りステージしてよい

### 4. リンターチェック

**SwiftFormat（lintモード）:**
```bash
swiftformat --lint $(git diff --name-only origin/develop..HEAD -- '*.swift' | tr '\n' ' ')
```
エラーが出た場合は修正して再チェック。よくあるルール:
- `wrapPropertyBodies`: 1行のプロパティbodyは複数行に展開
- `trailingCommas`: 末尾カンマ
- `braces`: 波括弧のスタイル

**SwiftLint:**
```bash
swiftlint lint --quiet
```
エラーがあれば修正する。

### 5. コミット

```bash
git add <変更ファイル>  # project.pbxprojは個別に確認してからstage
git diff --cached IceImageMemo.xcodeproj/project.pbxproj | grep -i "DEVELOPMENT_TEAM"
# → 何も出なければOK
git commit -m "feat/fix/chore: 変更内容の要約（日本語可）"
```

### 6. プッシュとPR作成

```bash
git push -u origin <branch-name>
gh pr create --base develop --title "<タイトル>" --body "<本文>"
```

PR本文には:
- ## Summary（箇条書き）
- ## Test plan（確認手順チェックリスト）
- チケットURLへのリンク
- `🤖 Generated with [Claude Code](https://claude.com/claude-code)`

を含める。

## 注意点

- `DEVELOPMENT_TEAM` はローカル環境依存のため、絶対にコミットしない
- SwiftFormat/SwiftLintのエラーはすべて解消してからプッシュする
- 実装はシンプルに。過度な抽象化・コメント・エラーハンドリングは不要
