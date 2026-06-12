import SwiftUI
import UniformTypeIdentifiers

// MARK: - Manifest查看器
struct ManifestView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var isCopied = false
    @State private var fontSize: CGFloat = 13
    
    var body: some View {
        VStack(spacing: 0) {
            // 工具栏
            HStack(spacing: 12) {
                // 字体大小控制
                HStack(spacing: 4) {
                    Image(systemName: "textformat.size.smaller")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Slider(value: $fontSize, in: 9...20, step: 1)
                        .frame(width: 100)
                    
                    Image(systemName: "textformat.size.larger")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                )
                
                Spacer()
                
                // 复制按钮
                Button(action: copyManifest) {
                    Label(isCopied ? "已复制" : "复制", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.subheadline)
                }
                .glassButtonStyle()
                
                // 刷新按钮
                Button(action: { /* 重新解析Manifest */ }) {
                    Label("刷新", systemImage: "arrow.clockwise")
                        .font(.subheadline)
                }
                .glassButtonStyle()
            }
            .padding()
            
            // XML内容显示区
            ScrollView([.horizontal, .vertical]) {
                if let info = appState.currentAPKInfo, !info.manifestXML.isEmpty {
                    // 真实XML内容
                    Text(info.manifestXML)
                        .font(.system(size: fontSize, design: .monospaced))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                } else {
                    // 示例XML内容
                    sampleManifestContent
                        .font(.system(size: fontSize, design: .monospaced))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
        }
        .glassBackground()
        .navigationTitle("AndroidManifest.xml")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 示例Manifest内容
    private var sampleManifestContent: Text {
        Text("""
        <?xml version="1.0" encoding="utf-8"?>
        <manifest xmlns:android="http://schemas.android.com/apk/res/android"
            package="com.example.app"
            android:versionCode="1"
            android:versionName="1.0.0">
            
            <!-- 权限声明 -->
            <uses-permission android:name="android.permission.INTERNET" />
            <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
            
            <application
                android:allowBackup="true"
                android:icon="@mipmap/ic_launcher"
                android:label="@string/app_name"
                android:roundIcon="@mipmap/ic_launcher_round"
                android:supportsRtl="true"
                android:theme="@style/AppTheme">
                
                <activity
                    android:name=".MainActivity"
                    android:exported="true">
                    <intent-filter>
                        <action android:name="android.intent.action.MAIN" />
                        <category android:name="android.intent.category.LAUNCHER" />
                    </intent-filter>
                </activity>
                
                <service
                    android:name=".BackgroundService"
                    android:enabled="true"
                    android:exported="false" />
                
                <receiver
                    android:name=".BootReceiver"
                    android:exported="true">
                    <intent-filter>
                        <action android:name="android.intent.action.BOOT_COMPLETED" />
                    </intent-filter>
                </receiver>
                
            </application>
        </manifest>
        """)
    }
    
    // MARK: - 复制功能
    private func copyManifest() {
        let content: String
        if let info = appState.currentAPKInfo, !info.manifestXML.isEmpty {
            content = info.manifestXML
        } else {
            content = """
            <?xml version="1.0" encoding="utf-8"?>
            <manifest xmlns:android="http://schemas.android.com/apk/res/android"
                package="com.example.app"
                android:versionCode="1"
                android:versionName="1.0.0">
                <uses-permission android:name="android.permission.INTERNET" />
                <application
                    android:allowBackup="true"
                    android:icon="@mipmap/ic_launcher"
                    android:label="@string/app_name">
                    <activity android:name=".MainActivity" android:exported="true" />
                </application>
            </manifest>
            """
        }
        
        UIPasteboard.general.string = content
        
        withAnimation {
            isCopied = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isCopied = false
            }
        }
    }
}

// MARK: - 预览
#Preview {
    ManifestView()
        .environmentObject(AppState())
}