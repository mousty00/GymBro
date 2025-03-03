import SwiftUI

struct WeeklyCalendar: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedDate: Date
    @State private var isFirstAppear = true

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date.today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - calendar.firstWeekday), to: Date.today) ?? Date.today
        
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var body: some View {
        VStack {
            HStack {
                ForEach(weekDays, id: \.self) { date in
                    VStack {
                        Text(shortDayName(for: date))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button {
                            selectedDate = date
                        } label: {
                            VStack {
                                Text(dayNumber(for: date))
                                    .font(.title)
                                    .fontWeight(selectedDate == date ? .bold : .regular)
                                    .foregroundColor(selectedDate == date ? (colorScheme == .dark ? .black : .white) : .primary)
                            }
                        }
                        .padding(10)
                        .background(selectedDate == date ? (colorScheme == .dark ? .white : .black) : Color.clear)
                        .clipShape(Circle())
                        .shadow(color: selectedDate == date ? .gray : .clear, radius: 5)
                    }
                    .frame(maxWidth: .infinity)
                    .onAppear {
                        if isFirstAppear {
                            selectedDate = Date.today
                            isFirstAppear = false
                        }
                    }
                }
            }
            .padding()
            
            Text("\(selectedDate.formatted(.dateTime.day().month().year()))")
                .font(.callout)
                .foregroundColor(.gray)
        }
        
    }
    
    private func shortDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }

    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

extension Date {
    static var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

#Preview {
    WeeklyCalendar(selectedDate: .constant(.now))
}

