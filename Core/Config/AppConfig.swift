import Foundation

enum AppConfig {
    private static let config: [String: String] = {
        #if DEBUG
        let fileName = "AppConfig.Debug"
        #else
        let fileName = "AppConfig.Release"
        #endif

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "plist"),
              let dictionary = NSDictionary(contentsOf: url) as? [String: String] else {
            #if DEBUG
            print("Konfigurationsdatei fehlt: \(fileName).plist")
            #endif
            return [:]
        }
        return dictionary
    }()

    private static func stringValue(for key: String, default fallback: String) -> String {
        guard let value = config[key] else {
            return fallback
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    static var apiBaseURL: String {
        stringValue(
            for: "api_base_url",
            default: "https://canovr-354203175068.europe-west3.run.app"
        )
    }

    static var stravaClientID: String {
        stringValue(for: "strava_client_id", default: "214640")
    }

    static var stravaCallbackDomain: String {
        stringValue(
            for: "strava_callback_domain",
            default: "canovr-354203175068.europe-west3.run.app"
        )
    }
}
