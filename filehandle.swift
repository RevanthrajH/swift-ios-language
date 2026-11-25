import Foundation

let fileURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("student.txt")

let message = "Welcome to Swift!"

do {
    try message.write(
        to: fileURL,
        atomically: true,
        encoding: .utf8
    )

    print("File saved successfully!")
} catch {
    print("Error: \(error)")
}