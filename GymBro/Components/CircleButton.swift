import SwiftUI

struct CircleButton: View {
    let image: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            Image(systemName: image)
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
        }
        .background(Color.pink)
        .clipShape(Circle())
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
        .frame(width: 80, height: 80)
        .padding()
    }
}
