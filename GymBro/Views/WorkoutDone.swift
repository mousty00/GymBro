
import SwiftUI

struct WorkoutDone: View {
    
    let name: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View{
        VStack {
            Text("\(name) " + NSLocalizedString("Done", comment: "Workout completed"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                                
            Text(NSLocalizedString("Great job! Keep pushing your limits!", comment: "Encouragement message"))
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                                
            Button {
                dismiss()
            } label: {
                Text(NSLocalizedString("Continue", comment: "Continue button"))
                    .bold()
                    .padding()
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .foregroundColor(.white)
        .edgesIgnoringSafeArea(.all)
        .transition(.opacity)
    }
}


