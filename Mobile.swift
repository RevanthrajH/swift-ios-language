class Mobile {
    var brand: String
    var price: Int

    init(brand: String, price: Int) {
        self.brand = brand
        self.price = price
    }

    func display() {
        print("Brand: \(brand)")
        print("Price: ₹\(price)")
    }
}

let mobile1 = Mobile(brand: "Apple", price: 50000)

mobile1.display()