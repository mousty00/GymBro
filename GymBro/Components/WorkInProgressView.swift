import SwiftUI

struct WorkInProgressView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "hammer.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
                .padding()
            
            Text("Work in Progress")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 8)
            
            
            Spacer()
        }
    }
}
