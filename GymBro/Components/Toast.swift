import SwiftUI

struct Toast: View {
    var message: String
    var status: String?
    
    var body: some View {
        HStack{
            
            Spacer()
            
            Text(message)
                .font(.subheadline)
            Spacer()
            
                switch status {
                    case "error":
                    Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .foregroundStyle(.red)
                            .frame(width: 30, height: 30)
                    case "info":
                        Image(systemName: "exclamationmark.circle.fill")
                            .resizable()
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30)
                    case "success":
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .foregroundColor(.green)
                            .frame(width: 30, height: 30)
                    default:
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .foregroundColor(.green)
                            .frame(width: 30, height: 30)
                }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .foregroundStyle(.primary)
        .cornerRadius(8)
        .padding(.horizontal)
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: 1)
        .padding(.bottom, 50)
        .frame(maxWidth: .infinity, alignment: .center)
            
    }
}

#Preview {
    Toast(message: "Workout deleted", status: "info")
}
