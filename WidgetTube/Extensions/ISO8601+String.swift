//
//  ISO8601+String.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/22/20.
//

import Foundation

extension String {
    func formatISO8601() -> String? {
        var finalString = ""
        let components = durationFrom8601String()
        if let seconds = components.second {
            finalString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        }
        if let minutes = components.minute {
            finalString = "\(components.hour != nil && minutes < 10 ? "0\(minutes)" : "\(minutes)"):\(finalString)"
        }
        if let hours = components.hour {
            finalString = "\(hours):\(finalString)"
        }
        return finalString
    }

    private func durationFrom8601String() -> DateComponents {
        let timeDesignator = CharacterSet(charactersIn:"HMS")
        let periodDesignator = CharacterSet(charactersIn:"YMD")

        var dateComponents = DateComponents()
        let mutableDurationString = self.mutableCopy() as! NSMutableString

        let pRange = mutableDurationString.range(of: "P")
        if pRange.location == NSNotFound {
            logErrorMessage(durationString: self)
            return dateComponents;
        } else {
            mutableDurationString.deleteCharacters(in: pRange)
        }


        if (self.range(of: "W") != nil) {
            let weekValues = componentsForString(string: mutableDurationString as String, designatorSet: CharacterSet(charactersIn: "W"))
            let weekValue: NSString? = weekValues["W"]! as NSString

            if (weekValue != nil) {
                //7 day week specified in ISO 8601 standard
                dateComponents.day = Int(weekValue!.doubleValue * 7.0)
            }
            return dateComponents
        }

        let tRange = mutableDurationString.range(of: "T", options: .literal)
        var periodString = ""
        var timeString = ""
        if tRange.location == NSNotFound {
            periodString = mutableDurationString as String

        } else {
            periodString = mutableDurationString.substring(to: tRange.location)
            timeString = mutableDurationString.substring(from: tRange.location + 1)
        }

        //DnMnYn
        let periodValues = componentsForString(string: periodString, designatorSet: periodDesignator)
        for (key, obj) in periodValues {
            let value = (obj as NSString).integerValue
            if key == "D" {
                dateComponents.day = value
            } else if key == "M" {
                dateComponents.month = value
            } else if key == "Y" {
                dateComponents.year = value
            }
        }

        //SnMnHn
        let timeValues = componentsForString(string: timeString, designatorSet: timeDesignator)
        for (key, obj) in timeValues {
            let value = (obj as NSString).integerValue
            if key == "S" {
                dateComponents.second = value
            } else if key == "M" {
                dateComponents.minute = value
            } else if key == "H" {
                dateComponents.hour = value
            }
        }

        return dateComponents
    }

    private func componentsForString(string: String, designatorSet: CharacterSet) -> Dictionary<String, String> {
        if string.count == 0 {
            return Dictionary()
        }
        let numericalSet = NSCharacterSet.decimalDigits
        let componentValues = (string.components(separatedBy: designatorSet as CharacterSet) as NSArray).mutableCopy() as! NSMutableArray
        let designatorValues = (string.components(separatedBy: numericalSet) as NSArray).mutableCopy() as! NSMutableArray
        componentValues.remove("")
        designatorValues.remove("")
        if componentValues.count == designatorValues.count {
            var dictionary = Dictionary<String, String>(minimumCapacity: componentValues.count)
            for i in 0...componentValues.count - 1 {
                let key = designatorValues[i] as! String
                let value = componentValues[i] as! String
                dictionary[key] = value
            }
            return dictionary
        } else {
            print("String: \(string) has an invalid format")
        }
        return Dictionary()
    }

    private func logErrorMessage(durationString: String) {
        print("String: \(durationString) has an invalid format")
        print("The durationString must have a format of PnYnMnDTnHnMnS or PnW")
    }
}
