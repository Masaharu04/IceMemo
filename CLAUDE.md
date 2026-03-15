# IceMemo - CLAUDE.md

## Project Overview
このプロジェクトは **SwiftUIのみ** で構築されたiOSアプリです。
有効期限付き写真管理アプリ（写メモ帳）で、撮影した写真を day/week/month/year の期限フォルダに保存し、期限が来たら自動削除します。
UIKit（Storyboard, XIB, UIViewControllerなど）は原則として使用しません。

## Target Environment
- **iOS Target**: iOS 18.0+
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
- **依存注入**: ViewModel はコンストラクタ経由で依存を受け取る（Protocol ベース）
- **画面遷移**: Coordinator パターン（`AppCoordinator`）

## Directory Structure
```
IceImageMemo/
├── Model/           # UseCase（ビジネスロジック・通知スケジューリング）
│   ├── PhotoUseCase.swift
│   ├── ScheduleDeleteNoticeForPhotoUseCase.swift
│   └── CancelDeleteNoticeForPhotoUseCase.swift
├── oldLogic/        # 非推奨 ⚠️ 触らない
└── oldView/         # 非推奨 ⚠️ 触らない
```

## Screen / Component Map

| 画面 | View | ViewModel | UseCase / Service |
|---|---|---|---|
| カメラ撮影 | `MainCameraView` | `MainCameraViewModel` | `PhotoUseCase`, `CameraService` |
| アルバム一覧 | `AlbumView` | `AlbumViewModel` | `PhotoUseCase` |
| 写真詳細 | `DetailView` | `DetailViewModel` | `PhotoUseCase`, `CancelDeleteNoticeForPhotoUseCase` |

**共通コンポーネント:**
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
4. **コメント**:
   - 簡潔に書く（1行以内が理想）
   - コードを読めばわかることは書かない
5. **コミット前**:
   - `make lint` でエラーがないこと
   - `make format-check` でフォーマット違反がないこと

## Anti-Patterns（禁止事項）
- **UIKit の多用**: SwiftUI で代替不可の場合（カメラ等）のみ `UIViewRepresentable` を使用
- **Force Unwrap (`!`)**: 絶対に避け、`if let` / `guard let` / デフォルト値を使用
- **巨大な View**: 1つの View にすべてのロジック・UIを詰め込まない
- **`oldLogic/` / `oldView/` の編集**: 非推奨のため変更・参照しない

## CI/CD
- GitHub Actions: PR → `main` で自動実行
  1. SwiftLint
  2. swift-format チェック
  3. Fastlane ビルド（`ci_build_check` lane）
