import SwiftUI

// MARK: - Calendar Schedule Card Component
struct CalendarScheduleCard: View {
    let scheduleItems: [ScheduleItem]
    let onCustomizeTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Calendar Schedule")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Customize") {
                    onCustomizeTap()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            // Schedule Items
            VStack(spacing: 12) {
                ForEach(scheduleItems) { item in
                    ScheduleItemRow(item: item)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Schedule Item Row
struct ScheduleItemRow: View {
    let item: ScheduleItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(item.dayOfWeek)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text(item.dayNumber)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .frame(width: 40, alignment: .leading)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let time = item.time {
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let description = item.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Status Indicator
            if let status = item.status {
                statusIndicator(for: status)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(backgroundColorForStatus(item.status))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func statusIndicator(for status: ScheduleStatus) -> some View {
        switch status {
        case .scheduled:
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
        case .conflict:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.caption)
        case .completed:
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
        }
    }
    
    private func backgroundColorForStatus(_ status: ScheduleStatus?) -> Color {
        switch status {
        case .conflict:
            return Color.red.opacity(0.1)
        case .scheduled, .completed:
            return Color.clear
        case .none:
            return Color.clear
        }
    }
}

// MARK: - Schedule Status Enum
enum ScheduleStatus {
    case scheduled
    case conflict
    case completed
}

// MARK: - Schedule Item Model
struct ScheduleItem: Identifiable {
    let id = UUID()
    let dayOfWeek: String
    let dayNumber: String
    let title: String
    let time: String?
    let description: String?
    let status: ScheduleStatus?
}

// MARK: - Preview
#Preview {
    CalendarScheduleCard(
        scheduleItems: [
            ScheduleItem(
                dayOfWeek: "MON",
                dayNumber: "26",
                title: "Strength Training",
                time: "9:00 a.m - 10:30 a.m",
                description: nil,
                status: .scheduled
            ),
            ScheduleItem(
                dayOfWeek: "TUE",
                dayNumber: "27",
                title: "Time Conflict",
                time: nil,
                description: "Meeting vs Aerobic Training",
                status: .conflict
            ),
            ScheduleItem(
                dayOfWeek: "WED",
                dayNumber: "26",
                title: "Aerobic Training",
                time: "7:00 p.m - 8:00 p.m",
                description: nil,
                status: .scheduled
            )
        ],
        onCustomizeTap: {}
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
