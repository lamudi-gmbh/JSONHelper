//
//  JSONHelper.swift
//
//  Created by Baris Sencan on 28/08/2014.
//  Copyright 2014 Baris Sencan
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/isair/JSONHelper
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

import Foundation

// Internally used functions, but defined as public as they might serve some
// purpose outside this library.
public func JSONString(object: AnyObject?) -> String? {
  return object as? String
}

public func JSONStrings(object: AnyObject?) -> [String]? {
  return object as? [String]
}

public func JSONStringsMap(object: AnyObject?) -> [String: String]? {
    return object as? [String: String]
}

public func JSONInt(object: AnyObject?) -> Int? {
  return object as? Int
}

public func JSONInts(object: AnyObject?) -> [Int]? {
  return object as? [Int]
}

public func JSONIntsMap(object: AnyObject?) -> [String: Int]? {
    return object as? [String: Int]
}

public func JSONBool(object: AnyObject?) -> Bool? {
  return object as? Bool
}

public func JSONBools(object: AnyObject?) -> [Bool]? {
  return object as? [Bool]
}

public func JSONBoolsMap(object: AnyObject?) -> [String: Bool]? {
    return object as? [String: Bool]
}

public func JSONArray(object: AnyObject?) -> [AnyObject]? {
  return object as? [AnyObject]
}

public func JSONArraysMap(object: AnyObject?) -> [String: [AnyObject]]? {
    return object as? [String: [AnyObject]]
}

public func JSONObject(object: AnyObject?) -> [String: AnyObject]? {
  return object as? [String: AnyObject]
}

public func JSONObjects(object: AnyObject?) -> [[String: AnyObject]]? {
  return object as? [[String: AnyObject]]
}

public func JSONObjectsMap(object: AnyObject?) -> [String: [String: AnyObject]]? {
    return object as? [String: [String: AnyObject]]
}

//MARK: Helper methods for NSDate



// Operator for use in "if let" conversions.
infix operator >>> { associativity left precedence 150 }

public func >>> <A, B>(a: A?, f: A -> B?) -> B? {

  if let x = a {
    return f(x)
  } else {
    return nil
  }
}

// MARK: - Operator for quick primitive type deserialization.

infix operator <<< { associativity right precedence 150 }

// For optionals.
public func <<< <T>(inout property: T?, value: AnyObject?) -> T? {
  var newValue: T?

  if let unwrappedValue: AnyObject = value {

    if let convertedValue = unwrappedValue as? T { // Direct conversion.
      newValue = convertedValue
    } else if property is Int? && unwrappedValue is String { // String -> Int

      if let intValue = "\(unwrappedValue)".toInt() {
        newValue = intValue as T
      }
    } else if property is NSURL? { // String -> NSURL

      if let stringValue = unwrappedValue as? String {
        newValue = NSURL(string: stringValue) as T?
      }
    } else if property is NSDate? { // Int || Double || NSNumber -> NSDate

      if let timestamp = value as? Int {
        newValue = NSDate(timeIntervalSince1970: Double(timestamp)) as T
      } else if let timestamp = value as? Double {
        newValue = NSDate(timeIntervalSince1970: timestamp) as T
      } else if let timestamp = value as? NSNumber {
        newValue = NSDate(timeIntervalSince1970: timestamp.doubleValue) as T
      }
    }
  }
  property = newValue
  return property
}

// For non-optionals.
public func <<< <T>(inout property: T, value: AnyObject?) -> T {
  var newValue: T?
  newValue <<< value
  if let newValue = newValue { property = newValue }
  return property
}

// Special handling for value and format pair to NSDate conversion.
public func <<< (inout property: NSDate?, valueAndFormat: (value: AnyObject?, format: String)) -> NSDate? {
  var newValue: NSDate?

  if let dateString = valueAndFormat.value >>> JSONString {

    let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = valueAndFormat.format

      if let newDate = dateFormatter.dateFromString(dateString) {
        newValue = newDate
      }
    }
  property = newValue
  return property
}

public func <<< (inout property: NSDate, valueAndFormat: (value: AnyObject?, format: String)) -> NSDate {
  var date: NSDate?
  date <<< valueAndFormat
  if let date = date { property = date }
  return property
}

// MARK: - Operator for quick primitive array deserialization.

infix operator <<<* { associativity right precedence 150 }

public func <<<* <T>(inout array: [T]?, value: AnyObject?) -> [T]? {
  var newValue:[T]? = [T]()
  //trying each primitive array to find the matching one
  if let stringArray = value >>> JSONStrings {
    for string in stringArray {
      var singleValue:T?
      singleValue <<< (string as AnyObject?)
      if singleValue != nil {
        newValue!.append(singleValue!)
      } else {
        newValue = nil
        break
      }
    }
  } else if let stringArray = value >>> JSONBools {
    for string in stringArray {
      var singleValue:T?
      singleValue <<< (string as AnyObject?)
      if singleValue != nil {
        newValue!.append(singleValue!)
      } else {
        newValue = nil
        break
      }
    }
  } else if let stringArray = value >>> JSONInts {
    for string in stringArray {
      var singleValue:T?
      singleValue <<< (string as AnyObject?)
      if singleValue != nil {
        newValue!.append(singleValue!)
      } else {
        newValue = nil
        break
      }
    }
  }
  array = newValue
  return array
}
// For non-optionals.
public func <<<* <T>(inout property: [T], value: AnyObject?) -> [T] {
  var newValue: [T]?
  newValue <<<* value
  if let newValue = newValue { property = newValue }
  return property
}

//#MARK: special handling for date with format

public func <<<* (inout array: [NSDate]?, valueAndFormat: (value: AnyObject?, format: String)) -> [NSDate]? {
  var newValue: [NSDate]?

  if let dateStringArray = valueAndFormat.value >>> JSONArray {
    newValue = []
    for dateString in dateStringArray {
      var date:NSDate?
      date <<< (dateString, valueAndFormat.format)
      if date? != nil {
        newValue!.append(date!)
      } else {
        newValue = nil
        break
      }
    }
  }
  array = newValue
  return array
}

public func <<<* (inout array: [NSDate], valueAndFormat: (value: AnyObject?, format: String)) -> [NSDate] {
  var newValue: [NSDate]?
  newValue <<<* valueAndFormat
  if let newValue = newValue { array = newValue }
  return array
}

//#MARK: handling maps

public func <<<* <T>(inout map: [String:T]?, value: AnyObject?) -> [String:T]? {
  var newValue:[String:T]? = [String:T]()
  //trying each primitive array to find the matching one
  if let stringMap = value >>> JSONStringsMap {
    for (key, string) in stringMap {
      var singleValue:T?
      singleValue <<< (string as AnyObject?)
      if singleValue != nil {
        newValue![key] = singleValue!
      } else {
        newValue = nil
        break
      }
    }
  } else if let boolMap = value >>> JSONBoolsMap {
    for (key, bool) in boolMap {
      var singleValue:T?
      singleValue <<< (bool as AnyObject?)
      if singleValue != nil {
        newValue![key] = singleValue!
      } else {
        newValue = nil
        break
      }
    }
  } else if let stringArray = value >>> JSONIntsMap {
    for (key, int) in stringArray {
      var singleValue:T?
      singleValue <<< (int as AnyObject?)
      if singleValue != nil {
        newValue![key] = singleValue!
      } else {
        newValue = nil
        break
      }
    }
  }
  map = newValue
  return map
}
// For non-optionals.
public func <<<* <T>(inout property: [String:T], value: AnyObject?) -> [String:T] {
  var newValue: [String:T]?
  newValue <<<* value
  if let newValue = newValue { property = newValue }
  return property
}

//#MARK: special handling for date with format

public func <<<* (inout array: [String:NSDate]?, valueAndFormat: (value: AnyObject?, format: String)) -> [String:NSDate]? {
  var newValue: [String:NSDate]?
  
  if let dateStringMap = valueAndFormat.value >>> JSONObject {
    newValue = [String:NSDate]()
    for (key, dateString) in dateStringMap {
      var date:NSDate?
      date <<< (dateString, valueAndFormat.format)
      if date? != nil {
        newValue![key] = date!
      } else {
        newValue = nil
        break
      }
    }
  }
  array = newValue
  return array
}

public func <<<* (inout array: [String:NSDate], valueAndFormat: (value: AnyObject?, format: String)) -> [String:NSDate] {
  var newValue: [String:NSDate]?
  newValue <<<* valueAndFormat
  if let newValue = newValue { array = newValue }
  return array
}

// MARK: - Operator for quick class deserialization.

infix operator <<<< { associativity right precedence 150 }

public protocol Deserializable {
  init(data: [String: AnyObject])
}

public func <<<< <T: Deserializable>(inout instance: T?, dataObject: AnyObject?) -> T? {

  if let data = dataObject >>> JSONObject {
    instance = T(data: data)
  } else {
    instance = nil
  }
  return instance
}

public func <<<< <T: Deserializable>(inout instance: T, dataObject: AnyObject?) -> T {
  var newInstance: T?
  newInstance <<<< dataObject
  if let newInstance = newInstance { instance = newInstance }
  return instance
}

// MARK: - Operator for quick deserialization into an array of instances of a deserializable class.

infix operator <<<<* { associativity right precedence 150 }

public func <<<<* <T: Deserializable>(inout array: [T]?, dataObject: AnyObject?) -> [T]? {

  if let dataArray = dataObject >>> JSONObjects {
    array = [T]()

    for data in dataArray {
      array!.append(T(data: data))
    }
  } else {
    array = nil
  }
  return array
}

public func <<<<* <T: Deserializable>(inout array: [T], dataObject: AnyObject?) -> [T] {
  var newArray: [T]?
  newArray <<<<* dataObject
  if let newArray = newArray { array = newArray }
  return array
}


public func <<<<* <T: Deserializable>(inout dictionary: [String:T]?, dataObject: AnyObject?) -> [String:T]? {

  if let dataDictionary = dataObject >>> JSONObjectsMap {
    dictionary = [String:T]()

    for (key, data) in dataDictionary {
      dictionary![key] = T(data: data)
    }
  } else {
    dictionary = nil
  }
  return dictionary
}

public func <<<<* <T: Deserializable>(inout dictionary: [String:T], dataObject: AnyObject?) -> [String: T] {
  var newDictionary: [String:T]?
  newDictionary <<<<* dataObject
  if let newDictionary = newDictionary { dictionary = newDictionary }
  return dictionary
}

// MARK: - Overloading of own operators for deserialization of JSON strings.

private func dataStringToObject(dataString: String) -> AnyObject? {
  var data: NSData = dataString.dataUsingEncoding(NSUTF8StringEncoding)!
  var error: NSError?
  return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)
}

public func <<<< <T: Deserializable>(inout instance: T?, dataString: String) -> T? {
  return instance <<<< dataStringToObject(dataString)
}

public func <<<< <T: Deserializable>(inout instance: T, dataString: String) -> T {
  return instance <<<< dataStringToObject(dataString)
}

public func <<<<* <T: Deserializable>(inout array: [T]?, dataString: String) -> [T]? {
  return array <<<<* dataStringToObject(dataString)
}

public func <<<<* <T: Deserializable>(inout array: [T], dataString: String) -> [T] {
  return array <<<<* dataStringToObject(dataString)
}
