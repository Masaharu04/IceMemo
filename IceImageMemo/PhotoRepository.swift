/*
 PhotoRepository.swift
 --------------------------------------------
 このファイルは「写真（画像ファイル）の永続化」を担う
 リポジトリ層のプロトコルと実装をまとめたものです。

 ■ 何をする？
 - PhotoRepository（プロトコル）
   画像の取得・保存・削除という最小限のI/O操作を定義します。
 - PhotoRepositoryImpl（実装）
   アプリのドキュメントディレクトリ配下を走査し、
   画像の URL 一覧取得 / ファイル削除 / データ保存 を行います。

 ■ どこを見に行く？
 - ドキュメント直下の各期限バケット（Expiration.allCases）
   例）Documents/day, Documents/week, ... といったフォルダ
 - 拡張子: jpg / jpeg / png / heic / heif のみ対象（隠しファイルは除外）

 ■ 主なメソッド
 - fetch(): 各バケット直下（再帰なし）から画像ファイルの URL を集めて返す
 - delete(url:): 指定 URL のファイルを削除
 - save(data:url:): 指定 URL にデータを書き込み（上書き）。※ディレクトリ作成はしない

 ■ 注意点・補足
 - ファイルI/Oは重くなる可能性があるため、必要に応じてバックグラウンドキューで呼び出してください。
 - 失敗時は throw せず print でログ出力のみ（必要ならエラーハンドリング方針を拡張してください）。
 - Expiration は別定義の enum（各バケット名を rawValue に持つ）を前提としています。
*/

import Foundation
import UIKit

protocol PhotoRepository {
    func fetch() -> [URL]
    func delete(url: URL)
    func save(data: Data, url: URL)
}

final class PhotoRepositoryImpl: PhotoRepository {
    func fetch() -> [URL] {
        let fm = FileManager.default
        guard let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("ドキュメントディレクトリが取得できませんでした")
            return []
        }
        let allowedExts = Set(["jpg", "jpeg", "png", "heic", "heif"])
        var imageUrls: [URL] = []
        for bucket in Expiration.allCases {
            let dir = documentsURL.appendingPathComponent(bucket.rawValue, isDirectory: true)
            guard fm.fileExists(atPath: dir.path) else { continue }
            
            do {
                let items = try fm.contentsOfDirectory(
                    at: dir,
                    includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
                    options: [.skipsHiddenFiles]
                )
                for url in items {
                    let values = try url.resourceValues(forKeys: [.isDirectoryKey])
                    let isDir = values.isDirectory ?? false
                    if !isDir && allowedExts.contains(url.pathExtension.lowercased()) {
                        imageUrls.append(url)
                    }
                }
            } catch {
                print("一覧取得失敗: \(dir.lastPathComponent) \(error)")
            }
        }
        return imageUrls
    }
    
    func delete(url: URL) {
        let filemanager = FileManager.default
        do {
            try filemanager.removeItem(at: url)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func save(data: Data, url: URL) {
        do {
            try data.write(to: url)
        } catch {
            return
        }
    }
}

