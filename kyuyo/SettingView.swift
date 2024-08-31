//
//  SettingView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/10.
//

import SwiftUI
import WebKit

struct OtherApp: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let appStoreLink: String
}

extension OtherApp {
    static let allApps = [
        OtherApp(name: "DrawGoal", description: "「DrawGoal」は目標達成をサポートするアプリケーションです。自らの目標を設定し、その達成に向けての日々の進捗を記録することができます。", appStoreLink: "https://apps.apple.com/us/app/drawgoal-%E7%9B%AE%E6%A8%99%E9%81%94%E6%88%90%E6%94%AF%E6%8F%B4%E3%82%A2%E3%83%97%E3%83%AA/id6451417773"),
        OtherApp(name: "ご褒美ToDo", description: "自分へのご褒美の予定を立てることができるアプリです。", appStoreLink: "https://apps.apple.com/us/app/%E3%81%94%E8%A4%92%E7%BE%8Etodo/id6474063404"),
        OtherApp(name: "ITクエスト", description: "ゲーム感覚でITの知識が学べるアプリ。『ITパスポート』『基本情報技術者試験』『応用技術者試験』などIT周りの勉強をゲーム感覚で学べます。", appStoreLink: "https://apps.apple.com/us/app/it%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88-it%E3%81%A8%E5%95%8F%E9%A1%8C%E3%81%A8%E5%8B%89%E5%BC%B7%E3%81%A8%E5%AD%A6%E7%BF%92%E3%81%8C%E3%81%A7%E3%81%8D%E3%82%8B%E3%82%A2%E3%83%97%E3%83%AA/id6469339499"),
        OtherApp(name: "お金クエスト", description: "ゲーム感覚でお金の知識が学べるアプリ。税金、投資、節約、予算管理などお金周りの勉強をゲーム感覚で学べます。", appStoreLink: "https://apps.apple.com/us/app/%E3%81%8A%E9%87%91%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88/id6476828253"),
        OtherApp(name: "英語クエスト", description: "ゲーム感覚で英語の知識が学べるアプリ。「英単語」「英熟語」「英文法」に分かれており、それぞれ『英検』『TOIEC』の難易度別に勉強をゲーム感覚で学べます。", appStoreLink: "https://apps.apple.com/us/app/%E8%8B%B1%E8%AA%9E%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88-%E8%8B%B1%E8%AA%9E%E3%81%AE%E5%95%8F%E9%A1%8C%E3%81%AE%E5%8B%89%E5%BC%B7%E3%81%A8%E5%AD%A6%E7%BF%92%E3%81%8C%E3%81%A7%E3%81%8D%E3%82%8B%E3%82%A2%E3%83%97%E3%83%AA/id6477769441"),
    ]
}

struct SettingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isSoundOn: Bool = true
    @ObservedObject var authManager = AuthManager()
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("情報")) {
                    NavigationLink(destination: TermsOfServiceView()) {
                        HStack {
                            Text("利用規約")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.systemGray4))
                        }
                    }
                    
                    NavigationLink(destination: PrivacyView()) {
                        HStack {
                            Text("プライバシーポリシー")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.systemGray4))
                        }
                    }
                    
                    NavigationLink(destination: WebView(urlString: "https://docs.google.com/forms/d/e/1FAIpQLSfHxhubkEjUw_gexZtQGU8ujZROUgBkBcIhB3R6b8KZpKtOEQ/viewform?embedded=true")) {
                        HStack {
                            Text("お問い合せ")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.systemGray4))
                        }
                    }
//                    if authManager.adminFlag == 1 {
//                    NavigationLink(destination: SubscriptionView(audioManager: audioManager).navigationBarBackButtonHidden(true)) {
//                        HStack {
//                            Text("広告を非表示にする")
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(Color(.systemGray4))
//                        }
//                    }
                    Button("アカウントを削除") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                    .alert("アカウントを削除してもよろしいですか？この操作は元に戻せません。", isPresented: $showingDeleteAlert) {
                        Button("削除", role: .destructive) {
                            authManager.deleteUserAccount { success, error in
                                if success {
                                    // アカウント削除成功時の処理
                                } else {
                                    // エラー処理
                                }
                            }
                        }
                        Button("キャンセル", role: .cancel) {}
                    }
//                    }
//                    NavigationLink(destination: Interstitial1()) {
//                        HStack {
//                            Text("インタースティシャル")
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(Color(.systemGray4))
//                        }
//                    }
                }
                Section(header: Text("他のアプリ")) {
//                    ScrollView{
                        ForEach(OtherApp.allApps) { app in
                            Link(destination: URL(string: app.appStoreLink)!) {
                                
                                HStack {
                                    Image("\(app.name)")
                                        .resizable()
                                        .frame(width:80,height: 80)
                                        .cornerRadius(10)
                                    VStack(alignment: .leading) {
                                        Text(app.name)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        Text(app.description)
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color("fontGray"))
                                    }
                                }
                            }
//                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("設定")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarItems(leading: Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("fontGray"))
                            Text("戻る")
                                .foregroundColor(Color("fontGray"))
                        })
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
