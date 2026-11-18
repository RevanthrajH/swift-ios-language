
import SwiftUI

struct ContentView: View {

    @State private var num1 = ""
    @State private var num2 = ""
    @State private var result = "Result"

    var body: some View {
        VStack(spacing: 20) {

            Text("Simple Calculator")
                .font(.largeTitle)
                .bold()

            TextField("Enter first number", text: $num1)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)

            TextField("Enter second number", text: $num2)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("+") {
                    calculate("+")
                }

                Button("-") {
                    calculate("-")
                }

                Button("×") {
                    calculate("*")
                }

                Button("÷") {
                    calculate("/")
                }
            }
            .buttonStyle(.borderedProminent)

            Text(result)
                .font(.title2)
                .bold()
        }
        .padding()
    }

    func calculate(_ operation: String) {
        guard let a = Double(num1),
              let b = Double(num2) else {
            result = "Enter valid numbers"
            return
        }

        switch operation {
        case "+":
            result = "Result: \(a + b)"
        case "-":
            result = "Result: \(a - b)"
        case "*":
            result = "Result: \(a * b)"
        case "/":
            result = b == 0 ? "Cannot divide by zero" : "Result: \(a / b)"
        default:
            result = "Invalid operation"
        }
    }
}
{
    ContentView()
}
