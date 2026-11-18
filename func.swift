struct Calculator {
    var a: Int
    var b: Int

    func add() -> Int {
        return a + b
    }
}

let calc = Calculator(a: 10, b: 20)

print(calc.add())