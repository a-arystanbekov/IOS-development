// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}



class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · Decoding Telemetry

// 1.1
@discardableResult
func parseReading(_ raw: String) -> Reading? {
    guard let (x, y) = splitOnce(raw, by: ":"),
          x.isEmpty == false,
          let ystr = Int(y),
          (x == "TEMP" || ystr >= 0)
    else {
        return nil
    }
    return (sensor: x, value: ystr)
}

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var validnum: [Reading] = []
    var num = 0
    for i in lines {
        if let reading = parseReading(i) {
            validnum.append(reading)
        } else {
            num += 1
        }
    }
    return (valid: validnum, invalidCount: num)
}


// MARK: Level 2 · Analysis

// 2.1
func select(readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var arr: [Reading] = []
    for i in readings {
        if isIncluded(i) {
            arr.append(i)
        }
    }
    return arr
}

func values(of readings: [Reading]) -> [Int] {
    var num1: [Int] = []
    for i in readings {
        num1.append(i.value)
    }
    return num1
}

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard values.isEmpty == false else { return nil }
    var min = values[0]
    var max = values[0]
    var s = 0
    for i in values {
        if i < min { min = i }
        if i > max { max = i }
        s += i
    }
    let avg = Double(s) / Double(values.count)
    return (min: min, max: max, average: avg)
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}


// MARK: Level 3 · Temperature Stabilization
//3.1
func heatUp(_ temp: Int) -> Int { temp + 5 }
func coolDown(_ temp: Int) -> Int { temp - 3 }
func hold(_ temp: Int) -> Int { temp }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}
//3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var current = start
    var steps = 0
    
    while (current < 18 || current > 24) && steps < maxSteps {
        let p = chooseProtocol(for: current)
        current = p(current)
        steps += 1
    }
    
    let isStable = (current >= 18 && current <= 24)
    return (finalTemp: current, steps: steps, isStable: isStable)
}


// MARK: Level 4 · The Crew
//4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}
//4.2
func status(of member: CrewMember) -> String {
    guard let mod = member.module else {
        return "\(member.name): no data (open space)"
    }
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(mod.name))"
    }
    
    let state = (level < 20) ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(state)"
}
//4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    
    let maxCanTake = source
    let maxCanAdd = 100 - target
    
    var actual = amount
    if actual > maxCanTake { actual = maxCanTake }
    if actual > maxCanAdd { actual = maxCanAdd }
    
    source -= actual
    target += actual
    return actual
}
//4.4
func evacuationOrder(names: String..., roster: [String: CrewMember]) -> [String] {
    var foundMembers: [CrewMember] = []
    
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        foundMembers.append(member)
    }
    
    var sortedMembers = foundMembers
    var i = 0
    while i < sortedMembers.count {
        var j = i + 1
        while j < sortedMembers.count {
            if sortedMembers[j].priority < sortedMembers[i].priority {
                let temp = sortedMembers[i]
                sortedMembers[i] = sortedMembers[j]
                sortedMembers[j] = temp
            }
            j += 1
        }
        i += 1
    }
    
    var resultNames: [String] = []
    for member in sortedMembers {
        resultNames.append(member.name)
    }
    return resultNames
}


// MARK: Level 5 · The Saboteur's Logbook

func reportOxygen(for member: CrewMember) -> String {
    guard let mod = member.module, let tank = mod.oxygenTank else {
        return "\(member.name): no tank data"
    }
    return "\(member.name): \(tank.level)"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}


// MARK: --- Bonus: makeAlarm ---

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var fireCount = 0
    return { level in
        if level < threshold {
            fireCount += 1
            print("Alarm #\(fireCount)")
            return true
        }
        return false
    }
}


// MARK: - ================= EXECUTION & FINALE =================

let rawLog = [
    "O2:87", "TEMP:-12", "RAD:-1", ":55",
    "TEMP:22", "O2:15", "TEMP:31", "TEMP:100",
    "O2:95", "TEMP:abc", "O2:invalid", "O2:45"
]

// 1.
let parsed = parseLog(rawLog)
let A = parsed.invalidCount

// 2.
let o2Readings = select(readings: parsed.valid) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)

let o2Stats = stats(of: o2Values)
let B = Int(o2Stats?.average ?? 0)

// 3. Task 2.3 Closure Ladder Verification
let validReadings = parsed.valid

let s1 = validReadings.sorted(by: { (a: Reading, b: Reading) -> Bool in return a.value > b.value })
let s2 = validReadings.sorted(by: { a, b in return a.value > b.value })
let s3 = validReadings.sorted(by: { a, b in a.value > b.value })
let s4 = validReadings.sorted(by: { $0.value > $1.value })
let s5 = validReadings.sorted { $0.value > $1.value }

let isS1S2 = s1.elementsEqual(s2, by: { $0.sensor == $1.sensor && $0.value == $1.value })
let isS2S3 = s2.elementsEqual(s3, by: { $0.sensor == $1.sensor && $0.value == $1.value })
let isS3S4 = s3.elementsEqual(s4, by: { $0.sensor == $1.sensor && $0.value == $1.value })
let isS4S5 = s4.elementsEqual(s5, by: { $0.sensor == $1.sensor && $0.value == $1.value })

let allMatch = isS1S2 && isS2S3 && isS3S4 && isS4S5

print("Task 2.3 Closure Ladder verified:", allMatch) // Выведет: trueprint("Task 2.3 Closure Ladder verified:", allMatch)

// 4.
let tempReadings = select(readings: parsed.valid) { $0.sensor == "TEMP" }
let tempValues = values(of: tempReadings)
let minTemp = stats(of: tempValues)?.min ?? 0
let stableResult = runUntilStable(from: minTemp)
let C = stableResult.steps

// 5.
var labOxygen = 40
var habOxygen = 12
transferOxygen(from: &labOxygen, to: &habOxygen, amount: 30)
let D = habOxygen

// Finale
let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("----------------------------------------")
print("LAUNCH CODE: \(launchCode)")
print("----------------------------------------")

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    - `guard let` enforces early exit: its `else` block strictly REQUIRES exiting the current scope using `return`, `break`, `continue`, or `throw`.
    - Unwrapped variables bound with `guard let` remain accessible in the code execution path OUTSIDE and AFTER the check, whereas `if let` variables exist ONLY inside the curly braces `{}` of the `if` block.
    - `guard let` prevents deep indentation ("Pyramid of Doom"), keeping the happy-path code flat and legible.

 2. Why can't you pass [Int] to stats(_ values: Int...)?
    - The variadic parameter `Int...` expects individual integer arguments passed separated by commas (e.g., `stats(1, 2, 3)`).
    - Swift does not support automatic array unpacking/splatting into variadic parameters.
    - To pass an existing array `[Int]`, you must call the overloaded variant with the explicit argument label: `stats(of: myArray)`.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
    - Due to Swift's memory safety law: Law of Exclusive Access to Memory.
    - Passing the exact same variable `x` to two different `inout` parameters creates two simultaneous mutating accesses to the same memory location.
    - The Swift compiler blocks this at compile time to prevent Data Races and Undefined Behavior.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
    - `oxygenLevel(of:)` returns an `Int?` (Optional Int), making the left-hand side of `??` an optional `Int`.
    - The right-hand side of the nil-coalescing operator (`??`) MUST evaluate to the same underlying non-optional type (`Int`).
    - Since `"no data"` is a `String`, a type mismatch error occurs (`Int` vs `String`). You would need String interpolation or `if let` instead.

 5. Full type of chooseProtocol and how to read it:
    - Full type signature: `(Int) -> (Int) -> Int`
    - How to read it: "A function that takes an `Int` as input and returns ANOTHER function, which in turn takes an `Int` and returns an `Int`."

 Bonus. Where does the alarm counter live after makeAlarm returns?
    - In the Heap.
    - Closures in Swift are reference types. When the closure captures the local variable `fireCount` from `makeAlarm`'s outer scope, Swift automatically allocates memory for `fireCount` on the Heap. This allows it to persist state across repeated closure invocations long after `makeAlarm` has returned.
*/
