///
//  DittoService.swift
//  SubscriptionFetch
//
//  Created by Eric Turner on 01/03/24.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Combine
import DittoExportLogs
import DittoSwift
import SwiftUI

class DittoService: ObservableObject {    
    static var shared = DittoService()
    var ditto = DittoInstance.shared.ditto
    let envCollectionName: String
    let envCollectionAttachmentKey: String

    private init() {
        self.envCollectionName = Env.DITTO_COLLECTION_NAME
        self.envCollectionAttachmentKey = Env.DITTO_ATTACHMENT_TOKEN_KEY        
    }

    func docsPublisher(for subscription: DittoSubscription) -> AnyPublisher<[DittoDocument], Never> {
        ditto.store[subscription.collectionName]
            .find(subscription.query)
            .liveQueryPublisher()
            .map { docs, _ in
                return docs
            }
            .eraseToAnyPublisher()
    }
}

class DittoInstance: ObservableObject {
    static var shared = DittoInstance()
    let ditto: Ditto
    
    private static let defaultLoggingOption: DittoLogger.LoggingOptions = .error
    @Published var loggingOption: DittoLogger.LoggingOptions
    private var cancellables = Set<AnyCancellable>()


    init() {
        // make sure our log level is set _before_ starting ditto.
        self.loggingOption = Self.storedLoggingOption()

        ditto = Ditto(identity: .onlinePlayground(
            appID: Env.DITTO_APP_ID, token: Env.DITTO_PLAYGROUND_TOKEN
        ))
        
        $loggingOption
            .sink {[weak self] option in
                guard let self = self else { return }
                saveLoggingOption(option)
                resetLogging()
            }
            .store(in: &cancellables)
        
        // Prevent Xcode previews from syncing: non preview simulators and real devices can sync
        let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isPreview {
            try! ditto.startSync()
        }
    }
}

extension DittoInstance {
    enum UserDefaultsKeys: String {
        case loggingOption = "live.ditto.SubscriptionFetch.userDefaults.loggingOption"
    }
    
    fileprivate func storedLoggingOption() -> DittoLogger.LoggingOptions {
        return Self.storedLoggingOption()
    }
    
    // static function for use in init() at launch
    fileprivate static func storedLoggingOption() -> DittoLogger.LoggingOptions {
        if let logOption = UserDefaults.standard.object(
            forKey: UserDefaultsKeys.loggingOption.rawValue
        ) as? Int {
            return DittoLogger.LoggingOptions(rawValue: logOption)!
        } else {
            return DittoLogger.LoggingOptions(rawValue: defaultLoggingOption.rawValue)!
        }
    }
    
    fileprivate func saveLoggingOption(_ option: DittoLogger.LoggingOptions) {
        UserDefaults.standard.set(option.rawValue, forKey: UserDefaultsKeys.loggingOption.rawValue)
    }

    fileprivate func resetLogging() {
        let logOption = Self.storedLoggingOption()
        switch logOption {
        case .disabled:
            DittoLogger.enabled = false
        default:
            DittoLogger.enabled = true
            DittoLogger.minimumLogLevel = DittoLogLevel(rawValue: logOption.rawValue)!
            if let logFileURL = DittoLogManager.shared.logFileURL {
                DittoLogger.setLogFileURL(logFileURL)
            }
        }
    }
}
