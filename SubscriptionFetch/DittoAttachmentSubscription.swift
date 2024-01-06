///
//  DittoSubscription+Extension.swift
//  SubscriptionFetch
//
//  Created by Eric Turner on 01/03/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import Combine
import DittoSwift
import Foundation

public final class DittoAttachmentSubscription {
    let subscription: DittoSubscription
    private let ditto = DittoInstance.shared.ditto
    private let dataFetcher: AttachmentAutoFetcher
    private var cancellable = AnyCancellable({})
    
    init(with sub: DittoSubscription, tokenKey: String) {
        self.subscription = sub
        self.dataFetcher = AttachmentAutoFetcher(ditto: ditto, tokenKey: tokenKey)
        self.cancellable = ditto.store[subscription.collectionName]
            .find(subscription.query)
            .liveQueryPublisher()
            .sink {[weak self] docs, _ in
                guard let self = self else { return }
                dataFetcher.fetchAttachmentData(in: docs, collName: subscription.collectionName)
            }
    }
}
