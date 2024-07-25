//
//  ContentView.swift
//  BraintreePayPalVaultDemo
//
//  Created by OK on 25/07/2024.
//

import SwiftUI
import BraintreeCore
import BraintreePayPal

struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.startAnimating()
    }
}


struct ContentView: View {
    @State private var braintreeClient: BTAPIClient?
    @State private var isProcessing: Bool = false
    @State private var resultMessage: String = ""

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Text("Select Payment Method")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Spacer()

                Button(action: {
                    payWithPayPal()
                }) {
                    Text("Pay with PayPal")
                        .fontWeight(.bold)
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }

                // Display result message
                     if !resultMessage.isEmpty {
                         Text(resultMessage)
                             .fontWeight(.medium)
                             .foregroundColor(.white)
                             .padding()
                             .background(Color.black.opacity(0.7))
                             .cornerRadius(10)
                             .padding(.top, 20)
                             .padding(.horizontal, 20)
                     }

                     Spacer()
            }
            .padding()
            
            if isProcessing {
                VStack {
                    ProgressView("Processing...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
            }
        }
    }

    func payWithPayPal() {
        resultMessage = ""
        isProcessing = true
        startCheckout()
    }

    func startCheckout() {
        // Initialize BTAPIClient, if you haven't already
        braintreeClient = BTAPIClient(authorization: "sandbox_zjmbj683_926q7cx2s9rp5fh5")
        guard let braintreeClient = braintreeClient else { return }
        
        let payPalClient = BTPayPalClient(apiClient: braintreeClient)

        let request = BTPayPalVaultRequest()
        request.billingAgreementDescription = "Your agreement description" 
        
        payPalClient.tokenize(request) { (tokenizedPayPalAccount, error) -> Void in
            isProcessing = false
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                resultMessage = "Got a nonce: \(tokenizedPayPalAccount.nonce)"
                // Send payment method nonce to your server to create a transaction
            } else if let error = error {
                // Handle error here...
                print("Error: \(error.localizedDescription)")
                resultMessage = "Error: \(error.localizedDescription)"
            } else {
                // Buyer canceled payment approval
                print("Buyer canceled payment approval")
                resultMessage = "Buyer canceled payment approval"
            }
        }
    }
}
