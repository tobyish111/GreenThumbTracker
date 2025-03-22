/*
 
 Author - Toby Buckmaster 
 
 
 */
import SwiftUI

struct DashboardView: View {
    // 🔢 Water amount entered by user
    @State private var waterAmount: String = ""
    
    // 📅 Date selected by user
    @State private var waterDate = Date()
    
    // For now, hardcoded Plant ID (can be dynamic later)
    let plantId = 1
    
    //  Success/failure message
    @State private var resultMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Add Water Record")
                .font(.title2)
                .bold()

            //  Water amount input
            TextField("Water Amount (e.g. 500)", text: $waterAmount)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)

            // Date picker
            DatePicker("Select Date", selection: $waterDate, displayedComponents: .date)
                .datePickerStyle(.compact)

            // Submit button
            Button("Submit Water Record") {
                guard let amount = Int(waterAmount) else {
                    resultMessage = "❌ Invalid amount"
                    return
                }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let formattedDate = formatter.string(from: waterDate)

                APIManager.shared.createWaterRecord(plantId: plantId, amount: amount, date: formattedDate) { result in
                    switch result {
                    case .success(let message):
                        resultMessage = "✅ \(message)"
                    case .failure(let error):
                        resultMessage = "❌ Error: \(error.localizedDescription)"
                    }
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.green)
            .cornerRadius(10)

            // Feedback message
            if let resultMessage = resultMessage {
                Text(resultMessage)
                    .foregroundColor(resultMessage.contains("✅") ? .green : .red)
                    .padding(.top, 10)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    DashboardView()
}
