// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge
    case lab
    case cargo
    case medbay
    case engine
    
    var evacuationPriority: Int {
        switch self {
        case .bridge:
            return 1
        case .medbay:
            return 2
        case .lab:
            return 3
        case .engine:
            return 4
        case .cargo:
            return 5
        }
    }
}

for deck in Deck.allCases {
    print("Deck: \(deck.rawValue), priority: \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red
    
    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let steps = mass / 500
        
        if steps >= 3 {
            return AlarmLevel(rawValue: 3) ?? .red
        }
        
        return AlarmLevel(rawValue: steps + 0)
            ?? .green
    }
}

print("Alarm 0 kg: \(AlarmLevel.level(forTotalMass: 0))")
print("Alarm 940 kg: \(AlarmLevel.level(forTotalMass: 940))")
print("Alarm 4000 kg: \(AlarmLevel.level(forTotalMass: 4000))")


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}
// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    
    guard let tag = parts.first else {
        return .unknown(raw: line)
    }
    
    switch tag {
    case "crate":
        guard parts.count == 3,
              let id = Int(parts[1]),
              let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        
        return .crate(id: id, massKg: mass)
        
    case "container":
        guard parts.count == 3,
              let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        
        return .container(code: parts[1], massKg: mass)
        
    case "livestock":
        guard parts.count == 4,
              let count = Int(parts[2]),
              let massPerUnit = Int(parts[3]) else {
            return .unknown(raw: line)
        }
        
        return .livestock(
            species: parts[1],
            count: count,
            massPerUnitKg: massPerUnit
        )
        
    default:
        return .unknown(raw: line)
    }
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case let .crate(_, massKg):
        return massKg
        
    case let .container(_, massKg):
        return massKg
        
    case let .livestock(_, count, massPerUnitKg):
        return count * massPerUnitKg
        
    case .unknown:
        return 0
    }
}

var totalMass = 0
var unknownCount = 0

for line in rawManifest {
    let entry = parseEntry(line)
    
    if case .unknown = entry {
        unknownCount += 1
    }
    
    totalMass += mass(of: entry)
}

let A = totalMass

print("Manifest total mass: \(A) kg")
print("Unknown manifest lines: \(unknownCount)")
// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int
    
    mutating func breathe(_ amount: Int) {
        oxygen -= amount
        
        if oxygen < 0 {
            oxygen = 0
        }
    }
    
    mutating func move(to deck: Deck) {
        self.deck = deck
    }
    
    mutating func reviveInMedbay() {
        self = CrewSnapshot(
            name: name,
            deck: .medbay,
            oxygen: 100
        )
    }
    
    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(
            name: name,
            deck: .bridge,
            oxygen: 100
        )
    }
}

// 3.2
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int
    
    mutating func breathe(_ amount: Int) {
        oxygen -= amount
        
        if oxygen < 0 {
            oxygen = 0
        }
    }
    
    mutating func move(to deck: Deck) {
        self.deck = deck
    }
    
    mutating func reviveInMedbay() {
        self = CrewSnapshot(
            name: name,
            deck: .medbay,
            oxygen: 100
        )
    }
    
    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(
            name: name,
            deck: .bridge,
            oxygen: 100
        )
    }
}

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)
func changeOxygen(_ member: CrewSnapshot) -> CrewSnapshot {
    var changedMember = member
    changedMember.breathe(10)
    return changedMember
}

func changeOxygenInout(_ member: inout CrewSnapshot) {
    member.breathe(10)
}
// Copy demonstration
var original = crewRoster[0]
var copy = original

print("Copy before: \(copy.oxygen)")
copy.breathe(10)
print("Copy after: \(copy.oxygen)")
print("Original after copy changed: \(original.oxygen)")


// Plain parameter demonstration
print("Plain parameter before: \(original.oxygen)")
let changed = changeOxygen(original)
print("Returned changed value: \(changed.oxygen)")
print("Original after plain function: \(original.oxygen)")


// inout demonstration
print("Inout before: \(original.oxygen)")
changeOxygenInout(&original)
print("Inout after: \(original.oxygen)")


// Other required methods
var testCrew = CrewSnapshot.rookie(named: "Test")

print("Rookie: \(testCrew.name), \(testCrew.oxygen)")
testCrew.move(to: .lab)
print("Moved to: \(testCrew.deck.rawValue)")

testCrew.breathe(30)
print("After breathing: \(testCrew.oxygen)")

testCrew.reviveInMedbay()
print("After revive: \(testCrew.deck.rawValue), \(testCrew.oxygen)")

// MARK: Level 4 · The Teleport Pod
// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?
    
    // CrewSnapshot is a struct, so Swift can synthesize its memberwise
    // initializer. This class has a custom initializer because we define it.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }
    
    func load(_ crew: CrewSnapshot) -> Bool {
        if occupant != nil || chargeLevel < 20 {
            return false
        }
        
        occupant = crew
        return true
    }
    
    func fire() -> CrewSnapshot? {
        guard let crew = occupant else {
            return nil
        }
        
        chargeLevel -= 20
        occupant = nil
        
        return crew
    }
}

// 4.2 · Charge ledger: load+fire three times, then fire an empty pod
let pod = TeleportPod(id: "P-1", chargeLevel: 100)

// 1. Timur
pod.load(crewRoster[0])
print("After loading Timur: charge = \(pod.chargeLevel)")

let firedTimur = pod.fire()
print("After firing Timur: charge = \(pod.chargeLevel), result = \(firedTimur?.name ?? "nil")")

// 2. Dana
pod.load(crewRoster[1])
print("After loading Dana: charge = \(pod.chargeLevel)")

let firedDana = pod.fire()
print("After firing Dana: charge = \(pod.chargeLevel), result = \(firedDana?.name ?? "nil")")

// 3. Nurlan
pod.load(crewRoster[3])
print("After loading Nurlan: charge = \(pod.chargeLevel)")

let firedNurlan = pod.fire()
print("After firing Nurlan: charge = \(pod.chargeLevel), result = \(firedNurlan?.name ?? "nil")")

// 4. Empty pod
let emptyFire = pod.fire()
print("After firing empty pod: charge = \(pod.chargeLevel), result = \(emptyFire?.name ?? "nil")")

let C = pod.chargeLevel

print("Final pod charge: \(C)")
// 4.3 · Reference-semantics demonstration
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA

podB.chargeLevel = 50

print("podA charge: \(podA.chargeLevel)")
print("podB charge: \(podB.chargeLevel)")

// Struct comparison
var snapshotA = crewRoster[0]
var snapshotB = snapshotA

snapshotB.oxygen = 10

print("snapshotA oxygen: \(snapshotA.oxygen)")
print("snapshotB oxygen: \(snapshotB.oxygen)")

// Class = reference type.
// Struct = value type.


// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String
    
    var hullIntegrity: Int {
        willSet {
            print("Hull transition: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }
    
    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        
        var result = "Diagnostics for \(callSign):"
        
        for deck in Deck.allCases {
            result += " \(deck.rawValue)=\(oxygenByDeck[deck] ?? 0)"
        }
        
        return result
    }()
    
    var oxygenByDeck: [Deck: Int]
    
    var totalOxygen: Int {
        var total = 0
        
        for value in oxygenByDeck.values {
            total += value
        }
        
        return total
    }
    
    var averageOxygen: Int {
        get {
            if oxygenByDeck.count == 0 {
                return 0
            }
            
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Deck.allCases {
                if oxygenByDeck[deck] != nil {
                    oxygenByDeck[deck] = newValue
                }
            }
        }
    }
    
    init(callSign: String, hullIntegrity: Int) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        
        var readings: [Deck: Int] = []
        
        for reading in deckReadings {
            if let deck = Deck(rawValue: reading.deck) {
                readings[deck] = reading.oxygen
            }
        }
        
        self.oxygenByDeck = readings
    }
}


// Create station
let station = Station(
    callSign: "ALMA-7",
    hullIntegrity: 100
)

// Prove lazy property is not accessed yet
print("Station created.")
print("Total oxygen: \(station.totalOxygen)")

// B must be startup average BEFORE changing anything
let B = station.averageOxygen

print("Starting average oxygen: \(B)")

// First access to lazy property
print(station.fullDiagnostics)

// Second access - "Running full scan..." should NOT appear again
print(station.fullDiagnostics)


// 5.2 · The clamp trap: 130, then -40, then 55
station.hullIntegrity = 130
print("Hull after 130: \(station.hullIntegrity)")

station.hullIntegrity = -40
print("Hull after -40: \(station.hullIntegrity)")

station.hullIntegrity = 55
print("Hull after 55: \(station.hullIntegrity)")

// didSet does not create an infinite loop because Swift does not
// call property observers again when the property is changed
// from inside its own observer.


// Test average setter
station.averageOxygen = 70

print("Average after setter: \(station.averageOxygen)")
print("Total oxygen after setter: \(station.totalOxygen)")


// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
 var roster = crewRoster
  for var member in roster {
      member.oxygen -= 10
  }

  print(roster[0].oxygen)

  Expected:
  The author expected the oxygen of the roster members to decrease.

  Actual:
  The oxygen does not change in the original array.

  Rule:
  CrewSnapshot is a struct, so it has value semantics.
  The loop variable is a copy of each element.

  Fix:
  Use an index and modify the actual array element.
  */

 var fixedRoster = crewRoster

 for index in fixedRoster.indices {
     fixedRoster[index].breathe(10)
 }

 print("Report 1 fixed oxygen: \(fixedRoster[0].oxygen)")


/*
 REPORT 2

 let podA = TeleportPod(id: "A", chargeLevel: 100)
 let podB = podA
 podB.chargeLevel = 0
 print(podA.chargeLevel)

 Expected:
 The author expected podA to remain 100.

 Actual:
 podA becomes 0.

 Rule:
 TeleportPod is a class, so it has reference semantics.
 podA and podB point to the same object.

 Fix:
 Create another TeleportPod if an independent object is required.
 */

let fixedPodA = TeleportPod(id: "A", chargeLevel: 100)
let fixedPodB = TeleportPod(id: "B", chargeLevel: fixedPodA.chargeLevel)

fixedPodB.chargeLevel = 0

print("Report 2 fixed podA: \(fixedPodA.chargeLevel)")
print("Report 2 fixed podB: \(fixedPodB.chargeLevel)")


/*
 REPORT 3

 struct Logbook {
     var entries: [String] = []

     func add(_ entry: String) {
         entries.append(entry)
     }
 }

 Expected:
 The author expected add() to append an entry.

 Actual:
 It does not compile.

 Rule:
 A struct method that changes stored properties must be marked mutating.

 Fix:
 */

struct Logbook {
    var entries: [String] = []
    
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}

var logbook = Logbook()
logbook.add("Teleporter repaired")

print("Report 3 entries: \(logbook.entries.count)")
print("Report 3 first entry: \(logbook.entries[0])")


/*
 REPORT 4

 let snapshot = CrewSnapshot.rookie(named: "Dana")
 snapshot.oxygen = 40

 let pod = TeleportPod(id: "B", chargeLevel: 50)
 pod.chargeLevel = 10

 Expected:
 The author might expect both values to be immutable because both
 variables use let.

 Actual:
 snapshot.oxygen = 40 does NOT compile.
 pod.chargeLevel = 10 DOES compile.

 Rule:
 For a struct, let makes the entire value immutable.

 For a class, let makes the reference itself immutable,
 but the object's var properties can still be changed.
 */

let reportSnapshot = CrewSnapshot.rookie(named: "Dana")

// This would produce:
// error: cannot assign to property: 'reportSnapshot' is a 'let' constant
//
// reportSnapshot.oxygen = 40

let reportPod = TeleportPod(id: "B", chargeLevel: 50)
reportPod.chargeLevel = 10

print("Report 4 snapshot oxygen: \(reportSnapshot.oxygen)")
print("Report 4 pod charge: \(reportPod.chargeLevel)")


// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {
    
    // private blocks outside code from directly replacing or clearing entries.
    private var entries: [String] = []
    
    // private(set) blocks outside code from changing isSealed.
    private(set) var isSealed = false
    
    // internal is explicitly written so outside code can read the count.
    internal var entryCount: Int {
        return entries.count
    }
    
    // internal allows outside code to read the formatted transcript.
    internal var transcript: String {
        return entries.joined(separator: "\n")
    }
    
    // internal allows outside code to add entries through this method.
    internal func add(_ entry: String) {
        if !isSealed {
            entries.append(entry)
        }
    }
    
    // internal allows outside code to seal the recorder.
    internal func seal() {
        isSealed = true
    }
    
    // fileprivate allows code in this file to access the private history.
    fileprivate func rawEntries() -> [String] {
        return entries
    }
}


// Free function using fileprivate helper
func auditTranscript(of recorder: FlightRecorder) -> String {
    var result = "AUDIT:"
    
    for entry in recorder.rawEntries() {
        result += " [\(entry)]"
    }
    
    return result
}


// Test recorder
let recorder = FlightRecorder()

recorder.add("Crew transferred")
recorder.add("Manifest verified")

print("Recorder count: \(recorder.entryCount)")
print("Recorder transcript:")
print(recorder.transcript)

print(auditTranscript(of: recorder))

recorder.seal()

print("Recorder sealed: \(recorder.isSealed)")

// This should not add anything because recorder is sealed.
recorder.add("Illegal history change")

print("Entries after sealed attempt: \(recorder.entryCount)")


// These would fail and are intentionally left as comments:
//
// recorder.entries = []
// error: 'entries' is inaccessible due to 'private' protection level
//
// recorder.isSealed = false
// error: cannot assign to property: 'isSealed' setter is inaccessible
//
// recorder.entries.append("Fake")
// error: 'entries' is inaccessible due to 'private' protection level


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue

let integrityCode = "\(A)-\(B)-\(C)-\(D)"

print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

// deinit in TeleportPod, a do-block lifetime experiment, and === identity


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 DEFENSE QUESTIONS

 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?

 CrewSnapshot is a struct with stored properties and no custom initializer,
 so Swift provides a memberwise initializer automatically.
 TeleportPod is a class, so we wrote its initializer ourselves.


 2. What does mutating do to self, and why do classes never need it?

 mutating allows a struct method to change the value of self or its stored
 properties. Classes do not need mutating because class instances have
 reference semantics and their properties can be changed through the reference.


 3. In Report 4, both values are let. What exactly does let freeze?

 For a struct, let makes the whole value immutable, so its var properties
 cannot be changed.

 For a class, let makes the reference constant. The object itself can still
 change its var properties.


 4. Why must a lazy property be var? When does lazy change behaviour?

 A lazy property is initialized only when it is accessed for the first time.
 It must be var because its value is initialized after the object itself
 has already been created.

 For example, fullDiagnostics does not run when Station is created.
 It runs only when fullDiagnostics is accessed.


 5. private vs fileprivate: where in your FlightRecorder would private
 be too strict?

 private is used for entries because outside code should not access it.

 fileprivate is used for rawEntries() because the free function
 auditTranscript() is outside the class but still needs access to the
 recorder's internal history in the same file.


 BONUS

 deinit runs when the last strong reference to a class instance is removed.
 === checks whether two class references point to exactly the same instance.

 CrewSnapshot is a struct, so it is a value type and cannot be used with ===.
 */
