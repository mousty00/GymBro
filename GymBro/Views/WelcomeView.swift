
import SwiftUI

struct WelcomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isActive = false
    
    
    var body: some View {
        if isActive {
            TabNavigationView()
        } else {
            VStack {
                Spacer()
                
                Image(colorScheme == .dark ? "ic_dark" : "ic_light" )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Spacer()
                Text("Gym Bro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(NSLocalizedString("App developed by Mousty", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 10)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview{
    WelcomeView()
}
