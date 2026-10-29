import SwiftUI

struct CircleIconButton: View {
    let systemName: String
    var size: CGFloat = 52
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName).font(.system(size: 22, weight: .medium))
                .frame(width: size, height: size).background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.08), lineWidth: 1))
        }.buttonStyle(.plain).foregroundStyle(.primary)
    }
}

struct StatusPill: View {
    let status: ConnectionStatus
    var body: some View { HStack(spacing: 6) { Circle().fill(status == .connected ? .green : .gray).frame(width: 8, height: 8); Text(status.title).font(.subheadline).foregroundStyle(.secondary) } }
}

struct SectionLabel: View {
    let text: String
    var body: some View { Text(text).font(.headline).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading) }
}

struct RoundedCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View { content.padding(16).background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous)) }
}
