# IceMemo - CLAUDE.md

## Project Overview
このプロジェクトは **SwiftUIのみ** で構築されたiOSアプリです。
有効期限付き写真管理アプリ（写メモ帳）で、撮影した写真を day/week/month/year の期限フォルダに保存し、期限が来たら自動削除します。
UIKit（Storyboard, XIB, UIViewControllerなど）は原則として使用しません。

- **アプリ名**: FadeMemo
- **Bundle ID**: app.yaaru.ice-memo1
- **Xcode ターゲット名**: FadeMemo
- **主な機能**: カメラ撮影・期限フォルダ管理・期限切れ写真の自動削除・削除前通知

## Target Environment
- **iOS Target**: iOS 26.0+
- **Swift Version**: Swift 5.0+
- **Framework**: SwiftUI / AVFoundation / UserNotifications

## Setup
```bash
make setup  # SwiftLint / swift-format / bundle インストール + Local.xcconfig 作成
```
`xcconfig/Local.xcconfig` に以下を設定してください：
```
DEVELOPMENT_TEAM = YOUR_TEAM_ID
```

### xcconfig の仕組み
| ファイル | 役割 |
|---|---|
| `xcconfig/Shared.xcconfig` | コミット済み。`PRODUCT_BUNDLE_IDENTIFIER` を定義し `Local.xcconfig` を include |
| `xcconfig/Local.xcconfig` | gitignore 済み。各開発者が `DEVELOPMENT_TEAM` をローカルで設定 |
| `xcconfig/Local.xcconfig.sample` | コミット済みのテンプレート |

## Development Commands
| コマンド | 内容 |
|---|---|
| `make lint` | SwiftLint でコードチェック |
| `make format-check` | swift-format でフォーマット確認 |
| `make format` | swift-format で自動修正 |
| `make build` | fastlane 経由でビルド |

## Architecture & State Management
- **アーキテクチャ**: MVVM + Clean Architecture（UseCase / Repository / ViewModel / View）
- **状態管理**: `@ObservableObject` + `@Published`（Combine ベース）
- **依存注入**: `AppContainer` がファクトリを持ち、`AppCoordinator` 経由でViewModelを生成
- **画面遷移**: Coordinator パターン（`AppCoordinator`）

### 依存の流れ
```
View → ViewModel → UseCase → Repository → FileSystem
```
- View は ViewModel のみを知る
- UseCase はビジネスロジックを持ち、Repository に依存する
- Repository はファイルシステムへの直接アクセスを担当

## Directory Structure
```
IceImageMemo/
├── Coordinator.swift    # AppContainer / AppCoordinator（依存注入・画面遷移）
├── PhotoRepository.swift
├── PhotoUseCase.swift
├── ContentView.swift
├── IceImageMemoApp.swift
├── MainCameraView.swift / MainCameraViewModel.swift
├── AlbumView.swift / AlbumViewModel.swift
├── DetailView.swift / DetailViewModel.swift
├── CameraService.swift
├── ShareableUIImage.swift
├── Model/               # UseCase（ビジネスロジック・通知スケジューリング）
│   ├── ScheduleDeleteNoticeForPhotoUseCase.swift
│   └── CancelDeleteNoticeForPhotoUseCase.swift
├── oldLogic/            # 非推奨 ⚠️ 触らない
└── oldView/             # 非推奨 ⚠️ 触らない
```

## Screen / Component Map

| 画面 | View | ViewModel | UseCase / Service |
|---|---|---|---|
| カメラ撮影 | `MainCameraView` | `MainCameraViewModel` | `PhotoUseCase`, `CameraService` |
| アルバム一覧 | `AlbumView` | `AlbumViewModel` | `PhotoUseCase` |
| 写真詳細 | `DetailView` | `DetailViewModel` | `PhotoUseCase`, `CancelDeleteNoticeForPhotoUseCase` |

**共通コンポーネント:**
- `AppContainer` - ViewModelのファクトリ（依存注入）
- `AppCoordinator` - 画面遷移管理
- `PhotoRepository` - ファイルシステムへのアクセス
- `ScheduleDeleteNoticeForPhotoUseCase` - 削除通知スケジューリング

## File Storage Spec
```
Documents/
├── day/   → 1日後削除
├── week/  → 7日後削除
├── month/ → 30日後削除
└── year/  → 365日後削除
```
ファイル名: `yyyyMMddHHmmss.jpg`

## Coding Guidelines

**シンプルさ最優先**: 最小限の変更で要件を満たす。不要な抽象化・ヘルパーを増やさない。

1. **SwiftUI のモダンな記法**:
   - プレビューには `#Preview` マクロを使用
   - View は小さく分割し再利用性を高める（モディファイアが10行超えたらサブView抽出を検討）
2. **命名規則**:
   - View ファイル: `[Name]View.swift`
   - ViewModel ファイル: `[Name]ViewModel.swift`
   - 変数・関数: キャメルケース、型名: パスカルケース
3. **UI/UX**:
   - Apple の Human Interface Guidelines (HIG) に準拠
   - アイコンは `SF Symbols` を積極活用
4. **Apple 公式推奨パターン**:
   - `@MainActor` / `async-await` / `Combine` を適切に使い分ける
   - 日付計算は `Calendar.current.date(byAdding:to:)` を使う（固定の秒数・日数で計算しない）
   - URL・パス操作は `deletingPathExtension()` など Foundation API を使う
5. **コメント**:
   - 「なぜ」だけ書く。何をしているかはコードで表現する
   - 1行以内が理想。コードを読めばわかることは書かない
6. **コミット前**:
   - `make lint` でエラーがないこと
   - `make format-check` でフォーマット違反がないこと

## Anti-Patterns（禁止事項）
- **`DEVELOPMENT_TEAM` のコミット**: `project.pbxproj` に含めない。`xcconfig/Local.xcconfig` で管理する
- **`xcodebuild` コマンドの直接実行**: ビルドは fastlane / GitHub Actions で管理する
- **`print()` のみのエラー握りつぶし**: エラーは適切に処理するか、呼び出し元に伝える
- **UIKit の多用**: SwiftUI で代替不可の場合（カメラ等）のみ `UIViewRepresentable` を使用
- **Force Unwrap (`!`)**: 絶対に避け、`if let` / `guard let` / デフォルト値を使用
- **巨大な View**: 1つの View にすべてのロジック・UIを詰め込まない
- **`fatalError` の乱用**: 開発者ミス（プログラムの不変条件違反）のみに使用する。ユーザー操作起因のエラーには使わない
- **`oldLogic/` / `oldView/` の編集**: 非推奨のため変更・参照しない

## Branch / PR Rules
- **ベースブランチ**: `main`
- コミット前に必ず `swiftformat --lint` と `swiftlint lint --quiet` を通す
- `DEVELOPMENT_TEAM` が `project.pbxproj` に含まれていないことをコミット前に確認する

## CI/CD
- GitHub Actions: PR → `main` で自動実行
  1. SwiftLint
  2. swift-format チェック
  3. Fastlane ビルド（`ci_build_check` lane、`macos-26` / Xcode 26 で実行）
