
import Foundation

// =============================================================
// Station ALMA-7, Part III: The Repair Fleet
// iOS Mobile Development - Module 5
// =============================================================

// MARK: - STARTER DATA
// Do not modify this section.

let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal", charge: 77)
]

struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(
    name: "ALMA-BEACON",
    signalStrength: 8
)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - LEVEL 1: THE POWER CELL

final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = max(0, min(100, charge))
    }

    func level() -> Int {
        return charge
    }

    func spend(amount: Int) -> Bool {
        guard amount > 0, charge >= amount else {
            return false
        }

        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else {
            return
        }

        charge = min(100, charge + amount)
    }
}
// MARK: - LEVEL 2: THE FLEET

// 2.1 Base class

class Drone: Diagnosable, Rechargeable {
    let id: String
    let cell: PowerCell

    var componentID: String {
        return id
    }

    var statusCode: Int {
        return healthStatusCode(for: cell.level())
    }

    var powerCost: Int {
        return 10
    }

    var statusLine: String {
        let charge = cell.level()
        return "\(id): \(charge)% \(charge.powerBar)"
    }

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    func performTask() -> Int {
        return 0
    }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }

    final func runOnce() -> Int {
        guard cell.spend(amount: powerCost) else {
            return 0
        }

        return performTask()
    }
}

// 2.2 Three drone types


final class WelderDrone: Drone {
    override init(id: String, cell: PowerCell) {
        super.init(id: id, cell: cell)
    }

    override var powerCost: Int {
        return 25
    }

    override func performTask() -> Int {
        return 40
    }

    func weldSeam() -> String {
        return "\(id) welded a seam."
    }
}


class ScannerDrone: Drone {
    override var powerCost: Int {
        return 10
    }

    override var statusLine: String {
        return super.statusLine + " [scanner]"
    }

    override func performTask() -> Int {
        return 15
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int {
        return 20
    }

    override func performTask() -> Int {
        return 25
    }
}

// 2.3 Factory

func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)

    switch kind {
    case "welder":
        return WelderDrone(id: id, cell: cell)
    case "scanner":
        return ScannerDrone(id: id, cell: cell)
    case "cargo":
        return CargoDrone(id: id, cell: cell)
    default:
        return nil
    }
}

var fleet: [Drone] = []

for record in fleetData {
    if let drone = makeDrone(
        kind: record.kind,
        id: record.id,
        charge: record.charge
    ) {
        fleet.append(drone)
    } else {
        print("WARNING: Skipping unknown drone kind '\(record.kind)' for \(record.id).")
    }
}


// MARK: - LEVEL 3: THE SHIFT

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var totalWork = 0

    for _ in 0..<max(0, rounds) {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }

    return totalWork
}

let A = runShift(fleet, rounds: 3)
print("DEBUG A:", A)
var B = 0

for drone in fleet {
    B += drone.cell.level()
}

var C = 0

for drone in fleet {
    if drone.cell.level() >= drone.powerCost {
        C += 1
    }
}

print("\n--- SHIFT RESULTS ---")

for drone in fleet {
    print(drone.statusLine)
}

print("Total work units (A): \(A)")
print("Remaining drone charge (B): \(B)")
print("Drones ready for another task (C): \(C)")


// MARK: - LEVEL 4: DIAGNOSTICS

// 4.1 Diagnosable protocol

protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2 Rechargeable protocol

protocol Rechargeable {
    mutating func recharge(by amount: Int)
}


struct SensorModule: Diagnosable, Rechargeable {
    let componentID: String
    var chargeLevel: Int

    init(id: String, charge: Int) {
        self.componentID = id
        self.chargeLevel = max(0, min(100, charge))
    }

    var statusCode: Int {
        return healthStatusCode(for: chargeLevel)
    }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else {
            return
        }

        chargeLevel = min(100, chargeLevel + amount)
    }
}

var sensors: [SensorModule] = []

for record in sensorData {
    sensors.append(
        SensorModule(id: record.id, charge: record.charge)
    )
}

// 4.3 One protocol can represent both classes and structs.

func diagnosticsReport(components: [any Diagnosable]) -> String {
    var report = ""

    for component in components {
        if !report.isEmpty {
            report += "\n"
        }

        report += component.diagnose()
    }

    return report
}


// MARK: - LEVEL 5: SHARED BEHAVIOUR

// 5.1 The Health Rule exists in exactly one place.


extension Diagnosable {
    func diagnose() -> String {
        return "\(componentID): code \(statusCode)"
    }

    func healthStatusCode(for chargeLevel: Int) -> Int {
        let charge = max(0, min(100, chargeLevel))

        if charge >= 70 {
            return 0
        } else if charge >= 40 {
            return 1
        } else if charge >= 20 {
            return 2
        } else {
            return 3
        }
    }
}


// 5.2 Add protocol conformance without modifying LegacyBeacon.

extension LegacyBeacon: Diagnosable {
    var componentID: String {
        return name
    }

    var statusCode: Int {
        return healthStatusCode(for: signalStrength)
    }

    func diagnose() -> String {
        return "LEGACY HARDWARE: \(componentID), code \(statusCode)"
    }
}

var components: [any Diagnosable] = []

for drone in fleet {
    components.append(drone)
}

for sensor in sensors {
    components.append(sensor)
}

components.append(beacon)

print("\n--- DIAGNOSTICS REPORT ---")
print(diagnosticsReport(components: components))

var D = 0

for component in components {
    D += component.statusCode
}

print("Total status codes (D): \(D)")

// 5.3 Extend Int with a ten-character power bar.


extension Int {
    var powerBar: String {
        var filled = self / 10

        if filled < 0 {
            filled = 0
        }

        if filled > 10 {
            filled = 10
        }

        let empty = 10 - filled

        return String(repeating: "#", count: filled)
            + String(repeating: ".", count: empty)
    }
}

print("\n--- POWER BAR EXAMPLES ---")
print("42: \(42.powerBar)")
print("-5: \((-5).powerBar)")
print("250: \(250.powerBar)")


// MARK: - LEVEL 6: INCIDENT REPORTS

/*
REPORT 1

Expected: PatchDrone should produce 30 work units.
Actual: The code does not compile because performTask() overrides
a base-class method without the required override keyword.
Rule: Swift requires override when replacing an inherited method.
Fix:

class PatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}

REPORT 2

Expected: HeavyWelder should inherit WelderDrone and return 999.
Actual: It does not compile. WelderDrone is final, so it cannot
be subclassed. Also, runOnce() is final and cannot be overridden.
Rule: final prevents subclassing or overriding, depending on where
it is applied.
Fix: Keep WelderDrone final and customise performTask() in a
different permitted subclass of Drone. Do not override runOnce().

REPORT 3

Expected: The program should call weldSeam() on the welder.
Actual: It does not compile because first has static type Drone,
which does not declare weldSeam().
Rule: Swift checks available members using the expression's type.
Fix: Use a conditional cast.

let reportFleet: [Drone] = [
    WelderDrone(id: "W-9", cell: PowerCell(charge: 100))
]
let first = reportFleet[0]

if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}

as? returns an optional because the runtime cast might fail,
and optional binding safely handles that possibility.

REPORT 4

Expected: "thruster T-1"
Actual: "generic component"
Rule: label() exists only in the protocol extension, not as a
requirement of Labelled. Calls through a protocol value therefore
use the extension implementation.
Fix: Add func label() -> String to the Labelled protocol.
Then the conforming type's implementation can be dynamically
dispatched through the protocol requirement.
*/


// MARK: - FINALE: MISSION CODE

let missionCode = "\(A)-\(B)-\(C)-\(D)"

print("\nMISSION CODE: \(missionCode)")


// MARK: - DEFENSE QUESTIONS

/*
1. A class is a reference type, so its method can mutate referenced
   state without mutating. A struct is a value type, so a method
   that changes its stored properties must be marked mutating.

2. Inheritance lets a subclass reuse and override implementation
   from a superclass. Protocols let unrelated classes and structs
   share a common interface and behaviour.

3. final prevents subclassing a final class or overriding a final
   member. Making runOnce() final protects the power-check and
   task-execution sequence from being changed by subclasses.

4. label() was not a protocol requirement, so a protocol-typed
   value used the extension's implementation. Making label() a
   protocol requirement enables the conforming implementation to
   be selected through the protocol.
*/


// MARK: - BONUS

/*
1. Runtime approach:
   Put fatalError("Drone is abstract") in a base implementation
   that must never be called. Instantiating the base type becomes
   a runtime failure when that implementation is invoked.

   Compile-time approach:
   Use a protocol as the fleet abstraction instead of allowing
   direct construction of a concrete base Drone.

2. Protocol-based redesign sketch (alternative design):

   protocol DroneUnit {
       var id: String { get }
       var cell: PowerCell { get }
       var powerCost: Int { get }
       func performTask() -> Int
       func runOnce() -> Int
   }

   extension DroneUnit {
       func runOnce() -> Int {
           guard cell.spend(amount: powerCost) else {
               return 0
           }
           return performTask()
       }
   }

   struct WelderDrone: DroneUnit {
       let id: String
       let cell: PowerCell
       var powerCost: Int { 25 }

       func performTask() -> Int {
           return 40
       }
   }

   This is an alternative design, not code to add alongside
   the class-based WelderDrone above.

3. The class design provides shared implementation and lets all
   drones share the same mutable PowerCell reference. The protocol
   design gives unrelated value and reference types a common
   interface without requiring a shared superclass. For this
   station, I would choose the class design because the drones
   share battery behaviour; if drones needed independent value
   semantics, I would consider structs with protocols.
*/
