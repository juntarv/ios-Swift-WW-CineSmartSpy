import Foundation

public struct AppConfig {
    public static let oneSignalAppId = "9448e14f-7696-4bc0-9ed5-59fea08cd754"
    public static let baseUrl = "https://eatphfhd.pics/data"
    public static let apiKey = "5vp4x3mBdoiR4MGjYfQJxfBRQUJiIxcs"
    public static let apiKeyApp = "JnBlAqoEHoH7nsdMseMUx4BG"
    public static let ipServiceUrl = "https://api.ipify.org?format=json"
    public static let appleAppId = "6752485340"
    
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
