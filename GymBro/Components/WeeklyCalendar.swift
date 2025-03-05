import SwiftUI

struct YearlyCalendar: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedDate: Date
    @State private var currentMonth: Date = Date.today
    @State private var isFirstAppear = true
    
    private var daysInMonth: [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth) ?? 0..<0
        return range.map { calendar.date(byAdding: .day, value: $0 - 1, to: currentMonth.startOfMonth())! }
    }
    
    var body: some View {
        VStack {
            // Month navigation
            HStack {
                Button(action: {
                    navigateToPreviousMonth()
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                
                Text("\(currentMonth, formatter: monthYearFormatter)")
                    .font(.title)
                    .bold()
                
                Button(action: {
                    navigateToNextMonth()
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            
            // Days Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(daysInMonth, id: \.self) { date in
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
                                        .frame(width: 40, height: 40, alignment: .center)
                                    
                                    Circle().fill()
                                        .foregroundColor(date == Date.today ? (selectedDate == date ? Color.gray.opacity(0.1) : .primary) : .clear)
                                        .frame(width: 5, height: 5)
                                        .offset(y: -5)
                                }
                            }
                            .padding(10)
                            .background(selectedDate == date ? Color.gray.opacity(0.1) : Color.clear)
                            .clipShape(Circle())
                            .shadow(color: selectedDate == date ? .gray : .clear, radius: 5)
                        }
                        .frame(width: 60) // day button Width
                    }
                }
                .padding(.horizontal, 10)
            }
            .padding(.vertical, 5)
        }
        .onAppear {
            if isFirstAppear {
                isFirstAppear = false
                selectedDate = Date.today
            }
        }
    }
    
    // Month navigation
    private func navigateToPreviousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func navigateToNextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy - MMMM"
        return formatter
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
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }
    
    func startOfYear() -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year], from: self))!
    }
}

#Preview {
    YearlyCalendar(selectedDate: .constant(.now))
}

