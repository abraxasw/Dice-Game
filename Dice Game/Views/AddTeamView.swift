import SwiftUI

// Import CardStyle from ContentView
extension View {
    func cardStyle(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8, shadowY: CGFloat = 4) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: shadowRadius, y: shadowY)
        }
    }
}

struct AddTeamView: View {
    // MARK: - Constants
    private static let minPlayers = 1
    private static let maxPlayers = 20

    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @Binding var teams: [Team]
    @State private var teamName = ""
    @State private var playerCount = 1
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Team Name Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Team Name")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        TextField("Enter team name", text: $teamName)
                            .textFieldStyle(.plain)
                            .font(.title3)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.background)
                            }
                            .focused($isNameFieldFocused)
                    }
                    .padding()
                    .cardStyle(shadowY: 0)

                    // Player Count Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number of Players")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text("\(playerCount)")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .frame(width: 60)
                            
                            VStack {
                                Button {
                                    withAnimation { playerCount = min(Self.maxPlayers, playerCount + 1) }
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                        .frame(width: 44, height: 32)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(playerCount < Self.maxPlayers ? Color.blue : Color.secondary)
                                        }
                                }
                                .disabled(playerCount >= Self.maxPlayers)

                                Button {
                                    withAnimation { playerCount = max(Self.minPlayers, playerCount - 1) }
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                        .frame(width: 44, height: 32)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(playerCount > Self.minPlayers ? Color.blue : Color.secondary)
                                        }
                                }
                                .disabled(playerCount <= Self.minPlayers)
                            }
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.background)
                        }
                    }
                    .padding()
                    .cardStyle(shadowY: 0)

                    Spacer()
                    
                    // Add Button
                    Button {
                        withAnimation {
                            teams.append(Team(name: teamName, playerCount: playerCount))
                            dismiss()
                        }
                    } label: {
                        Text("Add Team")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(teamName.isEmpty ? Color.secondary : Color.blue)
                            }
                    }
                    .disabled(teamName.isEmpty)
                }
                .padding()
            }
            .navigationTitle("New Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .onAppear { isNameFieldFocused = true }
        }
    }
} 