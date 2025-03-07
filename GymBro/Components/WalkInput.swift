import SwiftUI

struct WalkInput: View {
    @Binding var walkingTime: String
    @FocusState private var isTextFieldFocused: Bool
    let viewModel: WalkingRouteViewModel
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text(NSLocalizedString("specify the desired walking duration:", comment: ""))
                .font(.title)
                .foregroundStyle(.foreground)
                .multilineTextAlignment(.center)
                .padding()
            
            Text(NSLocalizedString("Enter walking time (minutes)", comment: ""))
                .font(.callout)
                .foregroundStyle(.gray.opacity(0.9))
            HStack {
                TextField(NSLocalizedString("Enter walking time (minutes)", comment: ""),
                          text: $walkingTime)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(.numberPad)
                    .focused($isTextFieldFocused)
                    .padding(.horizontal)
                
                Button(action: {
                    isTextFieldFocused = false
                    if let time = Int(walkingTime) {
                        viewModel.calculateWalkingRoute(time: time * 60)
                    }
                    dismiss()
                }) {
                    Text(NSLocalizedString("Walk", comment: ""))
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 120)
                        .background(.blue)
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                        .scaleEffect(isTextFieldFocused ? 1.05 : 1.0)
                        .animation(.easeInOut, value: isTextFieldFocused)
                }
                .padding()
            }
            .padding(.horizontal)
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            .padding()
        }
    }
}

#Preview {
    WalkInput(walkingTime: .constant("15"), viewModel: WalkingRouteViewModel())
}

