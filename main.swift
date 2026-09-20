import Foundation
//easy
var fruits = ["Apple", "Banana", "Orange", "Pineple", "Grape"]
print(fruits[2])
var Numbers: Set = [1, 2, 3, 4]
Numbers.insert(7)
print(Numbers)
var langDict: [String : Int] = ["Python": 1995, "C++": 1989, "Java": 1988]
print(langDict["Python"]!)
var colours = ["Red", "Silver", "Black", "Purple"]
colours[1] = "Sherry"
print(colours)
//med
let firstSet: Set = [1, 2, 3, 4]
let secondSet: Set = [3, 4, 5 , 6]
let res = firstSet.intersection(secondSet)
print(res)
var studentsGrade: [String:Int] = ["Bob":87, "Draven": 88, "Riley":56]
studentsGrade["Draven"] = 76
print(studentsGrade)
let first = ["banana", "apple"]
let second = ["cherry", "date"]
let third = first + second
print(third)
//hard
var countries: [String:Int] = ["Kzazkhstan" : 20, "USA" : 120, "Russia" : 100]
countries["Turkey"] = 88
print(countries)
var fset: Set<String> = ["Cat", "Dog"]
var sset: Set<String> = ["Dog", "Mouse"]
let unionSet = fset.union(sset)
fset = unionSet
fset.subtract(sset)
print(fset)
let grades: [String:[Int]] = ["Artur":[78, 67, 89], "Dragos":[43, 54, 23], "Vasile": [54, 78, 89]]
print(grades["Artur"]![1])
