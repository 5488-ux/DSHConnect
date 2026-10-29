import SwiftUI

struct ConnectionSettingsView: View {
    @EnvironmentObject private var store: ConnectionStore
    @Environment(\.dismiss) private var dismiss
    @State private var host = ""
    @State private var port = ""
    @State private var autoConnect = true
    @State private var token = ""
    @State private var collapseKeyboard = true
    @State private var showContext = false
    @State private var wrapDiffs = true
    @State private var requireFaceID = false
    @State private var followUp = "排队"

    var body: some View {
        NavigationStack {
            Form {
                Section("连接") {
                    HStack { Image(systemName: "laptopcomputer"); VStack(alignment: .leading) { Text(store.selectedEndpoint?.name ?? "DSH"); Text(store.status.title).font(.caption).foregroundStyle(.secondary) }; Spacer(); Circle().fill(store.status == .connected ? .green : .gray).frame(width: 9, height: 9) }
                    Button("重新连接") { store.reconnect() }
                    Button("断开连接", role: .destructive) { store.disconnect() }
                }
                Section("DSH 地址") {
                    TextField("主机名或 IP", text: $host).textInputAutocapitalization(.never).autocorrectionDisabled()
                    TextField("端口", text: $port).keyboardType(.numberPad)
                    TextField("Bearer token（可选）", text: $token).textInputAutocapitalization(.never).autocorrectionDisabled()
                    Toggle("打开时自动连接", isOn: $autoConnect)
                    Button("保存并连接") {
                        guard let p = Int(port), !host.isEmpty else { return }
                        store.config.host = host; store.config.port = p; store.config.token = token; store.config.autoConnect = autoConnect; store.connect(to: host, port: p); dismiss()
                    }.buttonStyle(.borderedProminent)
                }
                Section("自动发现") {
                    Text("优先发现 _dsh._tcp，随后回退到 _http._tcp。DSH 主机应在局域网广播 Bonjour 服务。").font(.footnote).foregroundStyle(.secondary)
                    Button("重新扫描") { store.discovery.start(serviceTypes: [store.config.discovery.service] + store.config.discovery.fallbackServices) }
                }
                Section("编辑器") {
                    Toggle("发送后收起键盘", isOn: $collapseKeyboard)
                    Toggle("显示上下文窗口使用情况", isOn: $showContext)
                    Picker("后续行为", selection: $followUp) { Text("排队").tag("排队"); Text("立即发送").tag("立即发送") }
                }
                Section("行为") {
                    Toggle("代码差异行自动换行", isOn: $wrapDiffs)
                    Picker("实时活动", selection: .constant("每台远程电脑一张卡片")) { Text("每台远程电脑一张卡片").tag("每台远程电脑一张卡片"); Text("仅当前连接").tag("仅当前连接") }
                }
                Section("安全与防护") {
                    Toggle("要求使用面容 ID", isOn: $requireFaceID)
                    Text("需要使用面容 ID 或设备密码才能在此设备上访问 DSH。").font(.footnote).foregroundStyle(.secondary)
                }
                Section("配置文件") { Text("默认读取 Resources/dsh.yaml；GitHub 构建时可直接修改该文件。").font(.footnote).foregroundStyle(.secondary) }
            }
            .navigationTitle("DSH 连接")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { dismiss() } label: { Image(systemName: "xmark") } } }
        }
        .onAppear { host = store.config.host; port = String(store.config.port); token = store.config.token; autoConnect = store.config.autoConnect }
    }
}
