import SwiftUI

struct ComposerView: View {
    @EnvironmentObject private var store: ConnectionStore
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var showAttachments = false
    @State private var showApproval = false
    @State private var showProjects = false

    var body: some View {
        VStack(spacing: 0) {
            HStack { Button("取消") { dismiss() }.foregroundStyle(.secondary); Spacer(); StatusPill(status: store.status); Spacer(); Button("发送") { dismiss() }.fontWeight(.semibold) }.padding(.horizontal, 22).padding(.vertical, 12)
            Spacer()
            RoundedCard {
                VStack(alignment: .leading, spacing: 18) {
                    TextField("对表", text: $text, axis: .vertical).font(.title3).lineLimit(4)
                    HStack { Button { showAttachments = true } label: { Image(systemName: "plus").font(.title2) }.buttonStyle(.plain); Button { showApproval = true } label: { Image(systemName: "exclamationmark.shield").font(.title2).foregroundStyle(.orange) }.buttonStyle(.plain); Spacer(); Image(systemName: "bolt.fill").font(.title2); Image(systemName: "dial.medium").font(.title2); Image(systemName: "mic").font(.title2); Button { dismiss() } label: { Image(systemName: "arrow.up").font(.title2.weight(.bold)).foregroundStyle(.white).frame(width: 42, height: 42).background(.blue, in: Circle()) }.buttonStyle(.plain) }
                }
            }.padding(.horizontal, 18).padding(.bottom, 18)
        }
        .sheet(isPresented: $showAttachments) { AttachmentMenu(showProjects: $showProjects).presentationDetents([.medium]) }
        .sheet(isPresented: $showApproval) { ApprovalSheetView().presentationDetents([.medium, .large]) }
        .sheet(isPresented: $showProjects) { ProjectPicker().environmentObject(store).presentationDetents([.medium, .large]) }
    }
}

struct AttachmentMenu: View {
    @Binding var showProjects: Bool
    @Environment(\.dismiss) private var dismiss
    private let items = [("camera", "相机"), ("photo", "照片"), ("paperclip", "文件"), ("puzzlepiece.extension", "插件"), ("slider.horizontal.3", "方案模式"), ("scope", "追求目标")]
    var body: some View { VStack(alignment: .leading, spacing: 20) { ForEach(items, id: \.1) { item in Button { if item.1 == "方案模式" { showProjects = true; dismiss() } } label: { Label(item.1, systemImage: item.0).font(.title3).foregroundStyle(.primary) }.buttonStyle(.plain) } }.padding(26) }
}

struct ProjectPicker: View {
    @EnvironmentObject private var store: ConnectionStore
    @Environment(\.dismiss) private var dismiss
    var body: some View { VStack(alignment: .leading, spacing: 0) { Text("DSH 项目").font(.title2.weight(.semibold)).padding(.bottom, 18); if store.remoteCapabilities.projects.isEmpty { Text("DSH 没有返回项目列表").foregroundStyle(.secondary).padding(.vertical, 12) } else { ForEach(store.remoteCapabilities.projects) { project in Button { dismiss() } label: { HStack(spacing: 14) { Image(systemName: "folder"); Text(project.name); Spacer() }.font(.title3).padding(.vertical, 11).foregroundStyle(.primary) }.buttonStyle(.plain) } }; Divider().padding(.vertical, 8); Label("在 DSH 中添加新文件夹", systemImage: "plus").font(.title3).padding(.vertical, 8) }.padding(26) }
}

struct ApprovalSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selected = 2
    private let choices = [("hand.raised", "请求批准", "编辑外部文件和使用互联网前始终先询问"), ("theatermasks", "替我批准", "仅在检测到可能不安全的操作时进行询问"), ("exclamationmark.shield", "完全访问", "完全访问计算机（风险较高）")]
    var body: some View { VStack(spacing: 16) { Text("应如何批准 Codex 操作？").font(.headline); Button("了解更多") {}.foregroundStyle(.blue); VStack(spacing: 0) { ForEach(Array(choices.enumerated()), id: \.offset) { index, choice in Button { selected = index } label: { HStack(spacing: 14) { Image(systemName: choice.0).font(.title2).foregroundStyle(index == 2 ? .orange : .primary); VStack(alignment: .leading, spacing: 2) { Text(choice.1).font(.headline).foregroundStyle(index == 2 ? .orange : .primary); Text(choice.2).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading) }; Spacer(); if selected == index { Image(systemName: "checkmark").fontWeight(.bold) } }.padding(16) }.buttonStyle(.plain); if index < choices.count - 1 { Divider().padding(.leading, 56) } } }.background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous)); Button("完成") { dismiss() }.buttonStyle(.borderedProminent).tint(.blue) }.padding(24) }
}
