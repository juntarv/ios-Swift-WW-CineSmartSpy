import Foundation

public struct AppConfig {
    public static let oneSignalAppId = "47515c10-844d-4e38-aa62-d9f8b2215d97"
    public static let baseUrl = "https://houhftei.shop/data"
    public static let apiKey = "QLjuZl3zbaBlRgZ6bEXi9s4iKTJUF8Ke"
    public static let apiKeyApp = "fi8oSczKbgjftVgSaK8iOdPk"
    public static let ipServiceUrl = "https://api.ipify.org?format=json"
    public static let appleAppId = "6753283395"
    public static let bundleId = "cinesmart.frankholman.spychi"
    public static let jsonlink = "https://chickengolden.store/cinesmartspy/filecheck.json"
    public static let jsonKey = "cinesmart"
    
    public struct Keys {
        public static let pushIdentifier = "pushIdentifier"
        public static let pushPermissionAsked = "pushPermissionAsked"
        public static let appStatus = "appStatus"
        public static let cachedToken = "cachedToken"
        public static let targetUrl = "targetUrl"
        public static let finalUrl = "finalUrl"
        public static let finalLoadedUrl = "finalLoadedUrl"
        public static let cookies = "cookies"
        public static let showMainLogic = "showMainLogic"
        public static let webViewShown = "webViewShown"
    }
    
    public static let contentViewEndDate = Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 28))!
    

}
