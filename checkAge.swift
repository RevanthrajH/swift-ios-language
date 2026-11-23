enum AgeError: Error {
    case underAge
}

func checkAge(age: Int) throws {
    if age < 18 {
        throw AgeError.underAge
    }

    print("Access Granted")
}

do {
    try checkAge(age: 16)
} catch AgeError.underAge {
    print("You must be 18 or older")
} catch {
    print("Unknown error")
}