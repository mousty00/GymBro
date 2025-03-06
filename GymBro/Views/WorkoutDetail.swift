import SwiftUI
import AVFAudio

struct WorkoutDetail: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WorkoutViewModel
    
    init(workout: ModelWorkout) {
        self.viewModel = WorkoutViewModel(workout: workout)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 10){
                            Text(viewModel.workout.name)
                                .fontWeight(.semibold)
                                .font(.system(size: 40))
                            Text(NSLocalizedString("Type", comment: "Workout type") + ": \(viewModel.workout.type)")
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .primary)
                        }
                        Spacer()
                        Image(systemName: workoutImageName)
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    .padding()
                    
                    if viewModel.isWorkoutCompletedToday {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.green)
                            Text("Workout Completed")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    } else {
                        if viewModel.isWorkoutToday {
                            VStack(alignment: .center, spacing: 20) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        let minutes = viewModel.timeRemaining / 60
                                        let seconds = viewModel.timeRemaining % 60

                                        Text(String(format: "%02d:%02d", minutes, seconds))
                                            .font(.system(size: 50))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .primary)
                                        Text(viewModel.currentPhase)
                                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .primary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        viewModel.isStarted.toggle()
                                        if viewModel.isStarted {
                                            viewModel.startTimer()
                                        } else {
                                            viewModel.stopTimer()
                                        }
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .trim(from: 0.0, to: viewModel.progress)
                                                .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                                                .foregroundColor(viewModel.currentPhase == NSLocalizedString("Workout", comment: "Workout phase") ? (viewModel.isStarted ? .orange : .green) : .red)
                                                .rotationEffect(.degrees(-90))
                                                .animation(.linear(duration: 1), value: viewModel.progress)
                                            
                                            Image(systemName: viewModel.isStarted ? "pause" : "play.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30, alignment: .center)
                                                .foregroundStyle(viewModel.currentPhase == NSLocalizedString("Workout", comment: "Workout phase") ? (viewModel.isStarted ? .orange : .green) : .red)
                                        }
                                    }
                                    .frame(width: 100, height: 100)
                                }
                                .padding()
                            }
                            
                            Button {
                                viewModel.skipPhase()
                            } label: {
                                Text(NSLocalizedString("Skip", comment: "Skip phase"))
                                    .font(.system(size: 20))
                                    .bold()
                                    .foregroundStyle(.blue)
                            }
                        } else {
                            Text(NSLocalizedString("This workout is not available for today.", comment: ""))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .primary)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .center) {
                        VStack(alignment: .center){
                            Text("\(viewModel.workout.steps)")
                                .fontWeight(.semibold)
                                .font(.system(size: 40))
                            Text(NSLocalizedString("Reps", comment: "Repetitions"))
                                .fontWeight(.semibold)
                                .font(.system(size: 20))
                        }
                        Text("X")
                        VStack(alignment: .center){
                            Text("\(viewModel.setsRemaining)")
                                .fontWeight(.semibold)
                                .font(.system(size: 40))
                            Text(NSLocalizedString("Sets", comment: "Workout sets"))
                                .fontWeight(.semibold)
                                .font(.system(size: 20))
                        }
                    }
                    
                    Spacer()
                    
                    if let workoutNotes = viewModel.workout.notes, !workoutNotes.isEmpty {
                        VStack{
                            Section(header: Text(NSLocalizedString("Notes", comment: "Workout notes header"))
                                .fontWeight(.semibold)
                                .font(.system(size: 20))
                            ) {
                                Text(workoutNotes)
                                    .padding()
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.8) : .primary)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
                            }
                        }
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            viewModel.toggleMute()
                        } label: {
                            Image(systemName: viewModel.isMuted ? "speaker.slash.circle.fill" : "speaker.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, height: 35)
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: .infinity)
                .padding()
                
                if viewModel.showCompletionScreen {
                    WorkoutDone(name: viewModel.workout.name)
                        .onDisappear {
                            viewModel.showCompletionScreen = false
                        }
                }
            }
            .onAppear {
                configureAudioSession()
            }
        }
    }
    
    private var workoutImageName: String {
        if viewModel.isWorkoutCompletedToday {
            return "checkmark.circle.fill"
        }
        switch viewModel.workout.type.lowercased() {
        case "yoga":
            return "figure.yoga"
        case "strength":
            return "figure.strengthtraining.traditional"
        case "cardio":
            return "figure.run"
        case "hiit":
            return "bolt.fill"
        default:
            return "dumbbell"
        }
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error configuring audio session: \(error)")
        }
    }
}


