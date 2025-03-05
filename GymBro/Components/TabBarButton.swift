import SwiftUI

struct TabBarButton: View {
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .white : .gray)
                
                if isSelected {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
