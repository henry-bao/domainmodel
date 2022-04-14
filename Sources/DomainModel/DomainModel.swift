struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    let amount: Int
    let currency: String
     
    private let someCurrencyToUsdDict: [String: Double] = [
        "GBP": 0.5,
        "EUR": 1.5,
        "CAN": 1.25,
        "USD": 1.0
    ]
    
    init(amount: Int, currency: String) {
        self.amount = amount
        self.currency = currency
    }
    
    func convert(_ currencyToConvert: String) -> Money {
        if currencyToConvert == "USD" {
            return Money(amount: Int(Double(self.amount) / someCurrencyToUsdDict[self.currency]!), currency: currencyToConvert)
        } else {
            return Money(amount: Int((Double(self.amount) * someCurrencyToUsdDict[currencyToConvert]!)), currency: currencyToConvert)
        }
    }
    
    func add(_ moneyToAdd: Money) -> Money {
        let sum = self.convert(moneyToAdd.currency).amount + moneyToAdd.amount
        return Money(amount: sum, currency: moneyToAdd.currency)
    }
    
}

////////////////////////////////////
// Job
//
public class Job {
    let title: String
    var type: JobType
    
    init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    
    func calculateIncome(_ time: Int) -> Int {
        switch self.type {
        case .Hourly(let wage):
            return Int(wage * Double(time))
        case .Salary(let salary):
            return Int(salary)
        }
    }
    
    func raise(byAmount: Double) -> Void {
        switch self.type {
        case .Hourly(let wage):
            self.type = JobType.Hourly(wage + byAmount)
        case .Salary(let salary):
            self.type = JobType.Salary(UInt(Double(salary) + byAmount))
        }
    }
    
    func raise(byPercent: Double) -> Void {
        switch self.type {
        case .Hourly(let wage):
            self.type = JobType.Hourly(wage * (1 + byPercent))
        case .Salary(let salary):
            self.type = JobType.Salary(UInt(Double(salary) * (1 + byPercent)))
        }
    }
    
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
}

////////////////////////////////////
// Person
//
public class Person {
    var firstName: String
    var lastName: String
    var age: Int
    var job: Job? {
        didSet {
            if age < 16 {
                job = nil
            }
        }
    }
    var spouse: Person? {
        didSet {
            if age < 18 {
                spouse = nil
            }
        }
    }
    
    init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.job = nil
        self.spouse = nil
    }
    
    func toString() -> String {
        return String("[Person: firstName:\(self.firstName) lastName:\(self.lastName) age:\(self.age) job:\(self.job?.title) spouse:\(self.spouse?.firstName)]")
    }
}

////////////////////////////////////
// Family
//
public class Family {
    var members: [Person] = []
    
    init(spouse1: Person, spouse2: Person) {
        if spouse1.spouse == nil && spouse2.spouse == nil {
            spouse1.spouse = spouse2
            spouse2.spouse = spouse1
            members = [spouse1, spouse2]
        }
    }
    
    func haveChild(_ child: Person) -> Bool {
        if self.members.count < 2 || (members[0].age <= 21 && members[1].age <= 21) {
            return false
        }
        members.append(child)
        return true
    }
    
    func householdIncome() -> Int {
        return members.reduce(0) { (total, person) -> Int in
            return total + (person.job?.calculateIncome(2000) ?? 0)
        }
    }
}
