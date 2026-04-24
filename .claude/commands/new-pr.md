# PR作成スキル

現在のブランチの変更をもとに、リンターチェック・プッシュ・PR作成まで一貫して行う。

## 手順

### 1. 現状確認

```bash
git status --short
git diff --stat origin/main..HEAD
git log --oneline origin/main..HEAD
```

- 未コミットの差分があれば先にコミットするよう促す
- コミットがなければ作業中の変更をコミットしてから進む

### 2. DEVELOPMENT_TEAM チェック（必須・コミット前）

project.pbxproj をステージする **前に** 必ず確認する:

```bash
git diff -- IceImageMemo.xcodeproj/project.pbxproj | grep -i "DEVELOPMENT_TEAM"
```

**検出された場合:**
1. `git restore IceImageMemo.xcodeproj/project.pbxproj` でファイルを元に戻す
2. project.pbxproj **以外** のファイルだけをステージしてコミットする
3. project.pbxproj は Xcode が自動で書き換えることがあるため、変更が必要な場合のみ手動で再適用する

**検出されなかった場合:**
- 通常通り project.pbxproj をステージしてよい

> ⚠️ `DEVELOPMENT_TEAM` はローカル環境固有の値。絶対にコミットしない。

### 3. リンターチェック

**SwiftFormat:**
```bash
swiftformat --lint $(git diff --name-only origin/main..HEAD -- '*.swift' | tr '\n' ' ')
```

**SwiftLint:**
```bash
swiftlint lint --quiet
```

エラーがあれば修正してコミットしてから次へ進む。

### 4. リモートへプッシュ

```bash
git push -u origin HEAD
```

### 5. PR作成

以下の形式で `gh pr create` を実行する:

```bash
gh pr create --base main --title "<タイトル>" --body "$(cat <<'EOF'
## Summary
- <変更内容を箇条書き>

## Test plan
- [ ] <確認手順1>
- [ ] <確認手順2>

## Related
<NotionチケットURLがあれば記載>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**タイトルの規則:**
- `feat:` 新機能
- `fix:` バグ修正
- `chore:` 設定・ドキュメント・リファクタ
- 日本語可、70文字以内

### 6. Notionチケットのステータス更新（任意）

関連するNotionチケットがあれば `notion-update-page` でステータスを `進行中` または `完了` に更新する。

### 7. 完了報告

作成したPRのURLをユーザーに伝える。

## 注意点

- ベースブランチは常に `main`
- `DEVELOPMENT_TEAM` が含まれていたら必ず中断する
- リンターエラーがある状態でPRを作らない
- `main` ブランチへの force push は絶対にしない
