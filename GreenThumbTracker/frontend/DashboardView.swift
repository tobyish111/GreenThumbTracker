/*
 
 Author - Toby Buckmaster 
 
 
 */
import SwiftUI

struct DashboardView: View {
    @State private var plants: [Plant] = []
    @State private var selectedPlantId: Int?
    @State private var amount: String = ""
    @State private var date = Date()
    @State private var successMessage: String?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            gradientBackground

            VStack(spacing: 20) {
                Text("Water a Plant")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.green)

                // Plant Picker
                if plants.isEmpty {
                    ProgressView("Loading plants...")
                } else {
                    Picker("Select Plant", selection: $selectedPlantId) {
                        ForEach(plants) { plant in
                            Text(plant.name).tag(Optional(plant.id))
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Amount
                TextField("Water Amount (mL)", text: $amount)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)

                // Date
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)

                // Feedback
                if let message = successMessage {
                    Text(message)
                        .foregroundColor(.green)
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                // Submit
                GreenButton(title: "Submit") {
                    submitWaterRecord()
                }

                Spacer()
            }
            .padding()
            .onAppear {
                APIManager.shared.fetchPlants { result in
                    switch result {
                    case .success(let fetched):
                        self.plants = fetched
                        self.selectedPlantId = fetched.first?.id
                    case .failure:
                        self.errorMessage = "Failed to load plants."
                    }
                }
            }
        }
    }

    private var gradientBackground: some View {
        LinearGradient(
            colors: [.zenGreen.opacity(0.8), .zenBeige.opacity(0.6), .green.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ).ignoresSafeArea()
    }

    func submitWaterRecord() {
        guard let plantId = selectedPlantId, let waterAmount = Int(amount) else {
            errorMessage = "Please enter valid data."
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        APIManager.shared.createWaterRecord(plantId: plantId, amount: waterAmount, date: dateString) { result in
            switch result {
            case .success(let message):
                self.successMessage = message
                self.errorMessage = nil
                self.amount = ""
            case .failure:
                self.errorMessage = "Failed to create water record."
                self.successMessage = nil
            }
        }
    }
}
#Preview {
    DashboardView()
}
