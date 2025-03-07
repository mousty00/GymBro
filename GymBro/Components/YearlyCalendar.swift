import SwiftUI

struct YearlyCalendar: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedDate: Date
    @State private var currentMonth: Date = Date.today
    @State private var isFirstAppear = true

    private var daysInMonth: [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth) ?? 0..<0
        var days: [Date] = []

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: currentMonth.startOfMonth()) {
                days.append(date)
            }
        }

        return days
    }
    
    var body: some View {
        VStack {
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
                    .fontWeight(.semibold)
                
                Button(action: {
                    navigateToNextMonth()
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            
            ScrollViewReader { proxy in
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
                                            .foregroundColor(
                                                selectedDate == date
                                                ? (date == Date.today
                                                    ? Color.white
                                                    : (colorScheme == .dark ? Color.black : Color.white))
                                                : (date == Date.today ? Color.red : .primary)
                                            )
                                            .frame(width: 40, height: 40, alignment: .center)
                                            .background(
                                                selectedDate == date
                                                ? (colorScheme == .dark
                                                    ? (date == Date.today ? Color.red : Color.white)
                                                   : (date == Date.today ? Color.red : Color.black))
                                                : Color.clear
                                            )
                                            .clipShape(Circle())
                                        
                                        Circle()
                                            .fill()
                                            .foregroundStyle(date == Date.today ? Color.red : Color.clear)
                                            .frame(width: 5, height: 5)
                                            .offset(y: -1)
                                    }
                                }
                                .padding(10)
                            }
                            .frame(width: 60)
                            .id(date)
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 5)
                .onAppear {
                    if isFirstAppear {
                        isFirstAppear = false
                        selectedDate = Date.today
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            proxy.scrollTo(Date.today, anchor: .center)
                        }
                    }
                }
            }
        }
    }
    
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

