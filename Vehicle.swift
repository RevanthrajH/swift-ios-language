class Vehicle {
    var brand = "Toyota"

    func start() {
        print("Vehicle started")
    }
}

class Car: Vehicle {
    func drive() {
        print("Car is driving")
    }
}

let myCar = Car()

print(myCar.brand)
myCar.start()
myCar.drive()