import SwiftUI

struct AdvancedSettingsView: View {
    @EnvironmentObject private var store: ConnectionStore
    @Environment(\.dismiss) private var dismiss
    @State private var showModelPicker = false

    var body: some View {
        VStack(spacing: 18) {
            HStack { Text("高级").font(.headline); Spacer(); Button { dismiss() } label: { Image(systemName: "xmark") } }.padding(.horizontal, 22).padding(.top, 18)
            RoundedCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack { Text("模型").font(.headline); Spacer(); Button { showModelPicker = true } label: { Text(store.remoteCapabilities.models.first(where: { $0.id == store.selectedModelID })?.name ?? "从 DSH 读取") } }
                    if store.remoteCapabilities.models.isEmpty { Text("DSH 没有返回模型列表；模型由已连接的 DSH 配置决定。").font(.footnote).foregroundStyle(.secondary) }
                    else { ForEach(store.remoteCapabilities.models) { model in Button { store.selectModel(model.id) } label: { HStack { Text(model.name); if let provider = model.provider { Text(provider).font(.caption).foregroundStyle(.secondary) }; Spacer(); if model.id == store.selectedModelID { Image(systemName: "checkmark") } }.padding(.vertical, 7).foregroundStyle(.primary) }.buttonStyle(.plain) } }
                }
            }
            RoundedCard {
                VStack(alignment: .leading, spacing: 10) {
                    if !store.remoteCapabilities.providers.isEmpty {
                        Text("DSH 提供商").font(.headline)
                        ForEach(store.remoteCapabilities.providers, id: \.self) { provider in Text(provider).foregroundStyle(.secondary) }
                    }
                    Text("DSH 远端设置").font(.headline)
                    if store.remoteCapabilities.settings.isEmpty { Text("DSH 未返回可编辑设置。").font(.footnote).foregroundStyle(.secondary) }
                    else { ForEach(store.remoteCapabilities.settings.keys.sorted(), id: \.self) { key in HStack { Text(key); Spacer(); Text(store.remoteCapabilities.settings[key] ?? "") .foregroundStyle(.secondary) } } }
                }
            }
            Spacer()
        }.padding(.horizontal, 14).background(Color(uiColor: .systemGroupedBackground))
            .sheet(isPresented: $showModelPicker) { ModelPickerView(store: store).presentationDetents([.medium]) }
    }

    private func option(_ label: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { HStack { Text(label).font(.headline); Spacer(); Text(value); Image(systemName: "chevron.up.chevron.down").foregroundStyle(.secondary) }.padding(.vertical, 14) }.buttonStyle(.plain)
    }
}

struct ModelPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: ConnectionStore
    var body: some View { VStack(alignment: .leading, spacing: 0) { Text("DSH 返回的模型").font(.headline).padding(.bottom, 12); if store.remoteCapabilities.models.isEmpty { Text("没有模型数据").foregroundStyle(.secondary) } else { ForEach(store.remoteCapabilities.models) { item in Button { store.selectModel(item.id); dismiss() } label: { HStack { Text(item.name); Spacer(); if store.selectedModelID == item.id { Image(systemName: "checkmark") } }.padding(.vertical, 12).foregroundStyle(.primary) }.buttonStyle(.plain) } } }.padding(24) }
}

struct ThinkingOverlay: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View { VStack(spacing: 16) { ProgressView().controlSize(.large); Text("正在思考").font(.headline); Text("DSH 正在运行任务并等待远程主机返回结果…").font(.subheadline).foregroundStyle(.secondary); Button("放到后台") { dismiss() }.buttonStyle(.bordered) }.padding(34) }
}
