// Copyright © 2015 Abhishek Banthia

import Cocoa
import CoreLoggerKit

struct ModelConstants {
    static let customLabel = "customLabel"
    static let timezoneName = "formattedAddress"
    static let placeIdentifier = "place_id"
    static let timezoneID = "timezoneID"
    static let emptyString = ""
}

public struct DateFormat {
    public static let twelveHour = "h:mm a"
    public static let twelveHourWithSeconds = "h:mm:ss a"
    public static let twentyFourHour = "HH:mm"
    public static let twentyFourHourWithSeconds = "HH:mm:ss"
    public static let twelveHourWithZero = "hh:mm a"
    public static let twelveHourWithZeroSeconds = "hh:mm:ss a"
    public static let twelveHourWithoutSuffix = "hh:mm"
    public static let twelveHourWithoutSuffixAndSeconds = "hh:mm:ss"
}

// Non-class type cannot conform to NSCoding!
public class TimezoneData: NSObject, NSCoding {
    public enum SelectionType: Int {
        case city
        case timezone
    }

    public enum DateDisplayType: Int {
        case panel
        case menu
    }

    public enum TimezoneOverride: Int {
        case globalFormat = 0
        case twelveHourFormat = 1
        case twentyFourFormat = 2
        case twelveHourWithSeconds = 4
        case twentyHourWithSeconds = 5
        case twelveHourPrecedingZero = 7
        case twelveHourPrecedingZeroSeconds = 8
        case twelveHourWithoutSuffix = 10
        case twelveHourWithoutSuffixAndSeconds = 11
    }

    static let values = [
        NSNumber(integerLiteral: 0): DateFormat.twelveHour,
        NSNumber(integerLiteral: 1): DateFormat.twentyFourHour,

        // Seconds
        NSNumber(integerLiteral: 3): DateFormat.twelveHourWithSeconds,
        NSNumber(integerLiteral: 4): DateFormat.twentyFourHourWithSeconds,

        // Preceding Zero
        NSNumber(integerLiteral: 6): DateFormat.twelveHourWithZero,
        NSNumber(integerLiteral: 7): DateFormat.twelveHourWithZeroSeconds,

        // Suffix
        NSNumber(integerLiteral: 9): DateFormat.twelveHourWithoutSuffix,
        NSNumber(integerLiteral: 10): DateFormat.twelveHourWithoutSuffixAndSeconds,
    ]

    public var customLabel: String?
    public var formattedAddress: String?
    public var placeID: String?
    public var timezoneID: String? = ModelConstants.emptyString
    public var latitude: Double?
    public var longitude: Double?
    public var note: String? = ModelConstants.emptyString
    public var nextUpdate: Date? = Date()
    public var sunriseTime: Date?
    public var sunsetTime: Date?
    public var isFavourite: Int = 0
    public var isSunriseOrSunset = false
    public var selectionType: SelectionType = .city
    public var isSystemTimezone = false
    public var overrideFormat: TimezoneOverride = .globalFormat

    public override init() {
        selectionType = .timezone
        isFavourite = 0
        note = ModelConstants.emptyString
        isSystemTimezone = false
        overrideFormat = .globalFormat
        placeID = UUID().uuidString
    }

    public init(with dictionary: [String: Any]) {
        if let label = dictionary[ModelConstants.customLabel] as? String {
            customLabel = label
        } else {
            customLabel = nil
        }

        if let timezone = dictionary[ModelConstants.timezoneID] as? String {
            timezoneID = timezone
        } else {
            timezoneID = "Error"
        }

        if let lat = dictionary["latitude"] as? Double {
            latitude = lat
        } else {
            latitude = -0.0
        }

        if let long = dictionary["longitude"] as? Double {
            longitude = long
        } else {
            longitude = -0.0
        }

        if let placeIdentifier = dictionary[ModelConstants.placeIdentifier] as? String {
            placeID = placeIdentifier
        } else {
            placeID = "Error"
        }

        if let address = dictionary[ModelConstants.timezoneName] as? String {
            formattedAddress = address
        } else {
            formattedAddress = "Error"
        }

        isFavourite = 0

        selectionType = .city

        if let noteString = dictionary["note"] as? String {
            note = noteString
        } else {
            note = ModelConstants.emptyString
        }

        isSystemTimezone = false

        overrideFormat = .globalFormat
    }

    public required init?(coder aDecoder: NSCoder) {
        customLabel = aDecoder.decodeObject(forKey: "customLabel") as? String

        formattedAddress = aDecoder.decodeObject(forKey: "formattedAddress") as? String

        placeID = aDecoder.decodeObject(forKey: "place_id") as? String

        timezoneID = aDecoder.decodeObject(forKey: "timezoneID") as? String

        latitude = aDecoder.decodeObject(forKey: "latitude") as? Double

        longitude = aDecoder.decodeObject(forKey: "longitude") as? Double

        note = aDecoder.decodeObject(forKey: "note") as? String

        nextUpdate = aDecoder.decodeObject(forKey: "nextUpdate") as? Date

        sunriseTime = aDecoder.decodeObject(forKey: "sunriseTime") as? Date

        sunsetTime = aDecoder.decodeObject(forKey: "sunsetTime") as? Date

        isFavourite = aDecoder.decodeInteger(forKey: "isFavourite")

        let selection = aDecoder.decodeInteger(forKey: "selectionType")
        selectionType = SelectionType(rawValue: selection)!

        isSystemTimezone = aDecoder.decodeBool(forKey: "isSystemTimezone")

        let override = aDecoder.decodeInteger(forKey: "overrideFormat")
        overrideFormat = TimezoneOverride(rawValue: override)!
    }

    public class func customObject(from encodedData: Data?) -> TimezoneData? {
        guard let dataObject = encodedData else {
            return TimezoneData()
        }

        if let timezoneObject = NSKeyedUnarchiver.unarchiveObject(with: dataObject) as? TimezoneData {
            return timezoneObject
        }

        return nil
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(placeID, forKey: "place_id")

        aCoder.encode(formattedAddress, forKey: "formattedAddress")

        aCoder.encode(customLabel, forKey: "customLabel")

        aCoder.encode(timezoneID, forKey: "timezoneID")

        aCoder.encode(nextUpdate, forKey: "nextUpdate")

        aCoder.encode(latitude, forKey: "latitude")

        aCoder.encode(longitude, forKey: "longitude")

        aCoder.encode(isFavourite, forKey: "isFavourite")

        aCoder.encode(sunriseTime, forKey: "sunriseTime")

        aCoder.encode(sunsetTime, forKey: "sunsetTime")

        aCoder.encode(selectionType.rawValue, forKey: "selectionType")

        aCoder.encode(note, forKey: "note")

        aCoder.encode(isSystemTimezone, forKey: "isSystemTimezone")

        aCoder.encode(overrideFormat.rawValue, forKey: "overrideFormat")
    }

    public func formattedTimezoneLabel() -> String {
        // First check if there's an user preferred custom label set
        if let label = customLabel, !label.isEmpty {
            return label
        }

        // No custom label, return the formatted address/timezone
        if let address = formattedAddress, !address.isEmpty {
            return address
        }

        // No formatted address, return the timezoneID
        if let timezone = timezoneID, !timezone.isEmpty {
            let hashSeperatedString = timezone.components(separatedBy: "/")

            // Return the second component!
            if let first = hashSeperatedString.first {
                return first
            }

            // Second component not available, return the whole thing!
            return timezone
        }

        // Return error
        return "Error"
    }

    public func setLabel(_ label: String) {
        customLabel = !label.isEmpty ? label : ModelConstants.emptyString
    }

    public func setShouldOverrideGlobalTimeFormat(_ shouldOverride: Int) {
        if shouldOverride == 0 {
            overrideFormat = .globalFormat
        } else if shouldOverride == 1 {
            overrideFormat = .twelveHourFormat
        } else if shouldOverride == 2 {
            overrideFormat = .twentyFourFormat
        } else if shouldOverride == 4 {
            overrideFormat = .twelveHourWithSeconds
        } else if shouldOverride == 5 {
            print("Setting override format to five")
            overrideFormat = .twentyHourWithSeconds
        } else if shouldOverride == 7 {
            overrideFormat = .twelveHourPrecedingZero
        } else if shouldOverride == 8 {
            overrideFormat = .twelveHourPrecedingZeroSeconds
        } else if shouldOverride == 10 {
            overrideFormat = .twelveHourWithoutSuffix
        } else if shouldOverride == 11 {
            overrideFormat = .twelveHourWithoutSuffixAndSeconds
        } else {
            assertionFailure("Chosen a wrong timezone format")
        }
    }

    public func timezone() -> String {
        if isSystemTimezone {
            timezoneID = TimeZone.autoupdatingCurrent.identifier
            formattedAddress = TimeZone.autoupdatingCurrent.identifier
            return TimeZone.autoupdatingCurrent.identifier
        }

        if let timezone = timezoneID {
            return timezone
        }

        if let name = formattedAddress, let placeIdentifier = placeID, let timezoneIdentifier = timezoneID {
            let errorDictionary = [
                "Formatted Address": name,
                "Place Identifier": placeIdentifier,
                "TimezoneID": timezoneIdentifier,
            ]

            Logger.log(object: errorDictionary, for: "Error fetching timezone() in TimezoneData")
        }

        return TimeZone.autoupdatingCurrent.identifier
    }

    public func timezoneFormat(_ currentFormat: NSNumber) -> String {
        let chosenDefault = currentFormat
        let timeFormat = TimezoneData.values[chosenDefault] ?? DateFormat.twelveHour

        if overrideFormat == .globalFormat {
            return timeFormat
        } else if overrideFormat == .twelveHourFormat {
            return DateFormat.twelveHour
        } else if overrideFormat == .twentyFourFormat {
            return DateFormat.twentyFourHour
        } else if overrideFormat == .twelveHourWithSeconds {
            return DateFormat.twelveHourWithSeconds
        } else if overrideFormat == .twentyHourWithSeconds {
            return DateFormat.twentyFourHourWithSeconds
        } else if overrideFormat == .twelveHourPrecedingZero {
            return DateFormat.twelveHourWithZero
        } else if overrideFormat == .twelveHourPrecedingZeroSeconds {
            return DateFormat.twelveHourWithZeroSeconds
        } else if overrideFormat == .twelveHourWithoutSuffix {
            return DateFormat.twelveHourWithoutSuffix
        } else if overrideFormat == .twelveHourWithoutSuffixAndSeconds {
            return DateFormat.twelveHourWithoutSuffixAndSeconds
        }

        return timeFormat
    }

    public func shouldShowSeconds(_ currentFormat: NSNumber) -> Bool {
        if overrideFormat == .globalFormat {
            let formatInString = TimezoneData.values[currentFormat] ?? DateFormat.twelveHour
            return formatInString.contains("ss")
        }

        let formatInString = TimezoneData.values[NSNumber(integerLiteral: overrideFormat.rawValue)] ?? DateFormat.twelveHour
        return formatInString.contains("ss")
    }

    public override var hash: Int {
        guard let placeIdentifier = placeID, let timezone = timezoneID else {
            return -1
        }

        return placeIdentifier.hashValue ^ timezone.hashValue
    }

    static func == (lhs: TimezoneData, rhs: TimezoneData) -> Bool {
        return lhs.placeID == rhs.placeID
    }

    public override func isEqual(to object: Any?) -> Bool {
        if let other = object as? TimezoneData {
            return placeID == other.placeID
        }
        return false
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let compared = object as? TimezoneData else {
            return false
        }

        // Plain timezones might have similar placeID. Adding another check for timezone identifier.
        return placeID == compared.placeID && timezoneID == compared.timezoneID
    }
}

extension TimezoneData {
    public override var description: String {
        return objectDescription()
    }

    public override var debugDescription: String {
        return objectDescription()
    }

    private func objectDescription() -> String {
        let customString = """
        TimezoneID: \(timezoneID ?? "Error")
        Formatted Address: \(formattedAddress ?? "Error")
        Custom Label: \(customLabel ?? "Error")
        Latitude: \(latitude ?? -0.0)
        Longitude: \(longitude ?? -0.0)
        Place Identifier: \(placeID ?? "Error")
        Is Favourite: \(isFavourite)
        Sunrise Time: \(sunriseTime?.debugDescription ?? "N/A")
        Sunset Time: \(sunsetTime?.debugDescription ?? "N/A")
        Selection Type: \(selectionType.rawValue)
        Note: \(note ?? "Error")
        Is System Timezone: \(isSystemTimezone)
        Override: \(overrideFormat)
        """

        return customString
    }
}
