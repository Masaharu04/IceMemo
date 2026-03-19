.PHONY: lint format build setup

# SwiftLint — 全ファイルチェック
lint:
	swiftlint lint --strict

# swift-format — 全ファイルフォーマットチェック
format-check:
	swift-format lint --strict --recursive IceImageMemo/

# swift-format — 自動修正
format:
	swift-format format --in-place --recursive IceImageMemo/

# ビルド（fastlane経由）
build:
	bundle exec fastlane ci_build_check

# 開発環境セットアップ
setup:
	brew install swiftlint swift-format
	bundle install
	@if [ ! -f xcconfig/Local.xcconfig ]; then \
		cp xcconfig/Local.xcconfig.sample xcconfig/Local.xcconfig; \
		echo "⚠️  xcconfig/Local.xcconfig を作成しました。DEVELOPMENT_TEAM を設定してください。"; \
	fi
