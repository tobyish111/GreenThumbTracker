import SwiftUI

struct ConflictResolutionView<T: RecordSyncable & Identifiable & Equatable>: View {
    var conflict: ConflictPair<T>
    let onResolve: (T) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text("Conflict Detected")
                .font(.title2.bold())
                .foregroundStyle(.green)
                .padding(.top)

            Text("We found a difference between the local and remote versions of this record.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 20) {
                recordColumn(
                    title: "🌿 Local Version",
                    record: conflict.local,
                    primary: true,
                    actionLabel: "Keep Local"
                ) {
                    onResolve(conflict.local)
                    dismiss()
                }

                recordColumn(
                    title: "☁️ Backend Version",
                    record: conflict.remote,
                    primary: false,
                    actionLabel: "Keep Backend"
                ) {
                    onResolve(conflict.remote)
                    dismiss()
                }
            }

            Button("Cancel", role: .cancel) {
                dismiss()
            }
            .foregroundColor(.red)
            .padding(.bottom)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemGreen).opacity(0.2), Color(.systemBackground)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    @ViewBuilder
    private func recordColumn(title: String, record: T, primary: Bool, actionLabel: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)

            RecordCard(record: record)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: primary ?
                                    [Color.green.opacity(0.25), Color.green.opacity(0.1)] :
                                    [Color.gray.opacity(0.15), Color.gray.opacity(0.05)]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(primary ? Color.green.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                )

            Button(actionLabel, action: action)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func RecordCard(record: T) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🕓 \(record.date.formatted(date: .abbreviated, time: .shortened))")
            Text("🆔 ID: \(record.id.uuidString.prefix(6))")
            if let value = extractValue(from: record) {
                Text("🌱 \(value)")
            }
        }
        .font(.footnote)
        .foregroundColor(.primary)
        .padding()
    }

    // Uses Mirror to reflect properties
    func extractValue(from record: T) -> String? {
        let mirror = Mirror(reflecting: record)
        for child in mirror.children {
            if let label = child.label,
               ["amount", "height", "humidity", "light", "soilMoisture", "temperature"].contains(label),
               let value = child.value as? CustomStringConvertible {
                return "\(label.capitalized): \(value.description)"
            }
        }
        return nil
    }
}
