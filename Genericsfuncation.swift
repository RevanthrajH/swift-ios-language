func getFirst<T>(array: [T]) -> T? {
    return array.first
}

let numbers = [10, 20, 30]
let names = ["Arun", "Raj", "Sam"]

print(getFirst(array: numbers) ?? 0)
print(getFirst(array: names) ?? "Empty")