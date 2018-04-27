//
//  ViewController.swift
//  broeser2
//
//  Created by 勝村里佳 on 2018/04/26.
//  Copyright © 2018年 jako. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UITextFieldDelegate {

    // URL入力フィールド
    @IBOutlet weak var urlTextField: UITextField!

    // web view
    @IBOutlet weak var browserWebView: WKWebView!

    // 戻るボタン
    @IBOutlet weak var backButton: UIBarButtonItem!

    // 進むボタン
    @IBOutlet weak var forwardButton: UIBarButtonItem!

    // 再読み込みボタン
    @IBOutlet weak var reloadButton: UIBarButtonItem!

    // 読み込み中マーク
    @IBOutlet weak var browserActivityIndicatorView: UIActivityIndicatorView!
    
    // URL読み込み開始時の処理
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 読み込み中マーク
        self.browserActivityIndicatorView.startAnimating()
    }

    // 初期表示
    override func viewDidLoad() {
        super.viewDidLoad()

        // UIデリゲートを宣言
        self.browserWebView.uiDelegate                     = self

        // UIナビゲーションデリゲートを宣言
        self.browserWebView.navigationDelegate             = self

        // URLテキストフィールドデリゲートを宣言
        self.urlTextField.delegate                         = self

        // 読み込み中マークは非表示
        self.browserActivityIndicatorView.hidesWhenStopped = true
    }

    // URL読み込み終了時の処理
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 読み込み中マーク
        self.browserActivityIndicatorView.stopAnimating()

        // テキストフィールドにURLを表示
        if let urlString = webView.url?.absoluteString {
            self.urlTextField.text = urlString
        }

        // 戻るボタンの有効状態を判定
        self.backButton.isEnabled = self.browserWebView.canGoBack

        // 進むボタンの有効状態を判定
        self.forwardButton.isEnabled = self.browserWebView.canGoForward
    }

    // 読み込み完了後処理
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 初期表示URL
        let urlString  = "https://www.google.com"
        
        // URLを読み込み
        self.loadUrl(urlString: urlString)

        // 枠線を追加
        self.addBorder()
    }

    // エラーで読み込めなかったとき
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // ユーザーが読み込みキャンセルした場合は処理を抜ける
        if (error as! URLError).code == URLError.cancelled {
            return
        }

        // エラーメッセージを設定してアラートを表示
        let errorMsg = "エラーだよ"
        self.showAlert(errorMsg)
        
        // 読み込みをストップ
        self.browserWebView.stopLoading()
        
        // 読み込み中アイコンもストップ
        self.browserActivityIndicatorView.stopAnimating()

    }

    // URL入力後エンターキー押下
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // URLテキストフィールド以外はそのまま処理を続行
        if textField != self.urlTextField {
            return true
        }

        // URLが入力されていればロードする
        if let urlString = textField.text {
            loadUrl(urlString: urlString)
        }

        return true
    }

    // テキストフィールド押下時内容を全選択
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // URLテキストフィールド以外はそのまま処理を続行
        if textField != self.urlTextField {
            return
        }

        // テキストフィールドの選択範囲を最初から最後にする
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }

    // 枠線追加用メソッド
    func addBorder() {
        // 上部の枠線
        let topBorder = CALayer()

        // 0.5px
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: self.browserWebView.frame.size.width, height: 0.5)

        // グレー
        topBorder.backgroundColor = UIColor.lightGray.cgColor

        // web viewのレイヤーに追加
        self.browserWebView.layer.addSublayer(topBorder)
    }

    // アラート表示処理
    func showAlert(_ errorMsg: String) {
        // アラートコントローラーを宣言
        let alertController = UIAlertController(title: "Error", message: errorMsg, preferredStyle: .alert)

        // デフォルトアクションを定義
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)

        // アラートコントローラーにデフォルトアクションを追加
        alertController.addAction(defaultAction)

        // アラートを表示
        self.present(alertController, animated: true, completion: nil)
    }

    // バリデーション
    func getValidateUrl(urlString: String) -> URL? {
        // エラーメッセージ
        var errorMsg = ""

        // 不要な空白やタブを削除
        let trimmed = urlString.trimmingCharacters(in: NSCharacterSet.whitespaces)

        // nil判定
        if URL(string: trimmed) == nil {
            // エラーメッセージ設定
            errorMsg = "無効なURLだよ"

            // エラー表示
            self.showAlert(errorMsg)

            return nil
        }

        // URL形式の文字列を返却
        return URL(string: self.appendScheme(trimmed))
    }

    // httpなしの文字列にhttpを追加
    func appendScheme(_ urlString: String) -> String {
        // 返却する初期値をセット
        var ret = urlString

        // URL形式かどうか判定
        if URL(string: urlString)?.scheme == nil {
            // URL形式でなければhttp://を付けてあげる
            ret = "http://" + urlString
        }

        return ret
    }
    
    // 読み込み処理
    func loadUrl(urlString: String) {
        // バリデーション通過後に処理を実行
        if let url = self.getValidateUrl(urlString: urlString) {

            // リクエスト形式に変換
            let urlRequest = URLRequest(url: url)
            
            // web viewで表示
            self.browserWebView.load(urlRequest)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // 戻るアクション
    @IBAction func goBack(_ sender: Any) {
        // もどる
        self.browserWebView.goBack()
    }
    
    // 進むアクション
    @IBAction func goForward(_ sender: Any) {
        // すすむ
        self.browserWebView.goForward()
    }
    
    // 再読み込みアクション
    @IBAction func reloadAction(_ sender: Any) {
        // 再読み込み
        self.browserWebView.reload()
    }

}

