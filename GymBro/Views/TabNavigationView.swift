import SwiftUI

struct TabNavigationView: View {
    @State private var selectedTab: Int = 0
        
        var body: some View {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    ContentView()
                        .tag(0)
                    
                    WalkingRouteView()
                        .tag(1)
                    
                }
                
                HStack(spacing: 0) {
                    
                    // Home View
                    TabBarButton(systemImage: "house", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    // Walking route View
                    TabBarButton(systemImage: "figure.walk", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                }
                .frame(height: 56)
            }
        }
    }

#Preview {
    TabNavigationView()
}
