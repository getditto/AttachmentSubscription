///
//  ContentView.swift
//  SubscriptionFetch
//
//  Created by Eric Turner on 01/03/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import Combine
import DittoSwift
import SwiftUI

class ContentVM: ObservableObject {
    @Published var docs = [DittoDocument]()
    @Published var presentSettingsView = false
    @Published var isLoading = true
    let attachmentSubscription: DittoAttachmentSubscription //auto-fetching subscription    
    private var docsCancellable = AnyCancellable({}) //this view's sync observer

    init() {
        let dittoService = DittoService.shared
        let sub = dittoService.ditto.store[dittoService.envCollectionName].findAll().subscribe()
        self.attachmentSubscription = DittoAttachmentSubscription(
            with: sub,
            tokenKey: dittoService.envCollectionAttachmentKey
        )
        self.docsCancellable = dittoService.docsPublisher(for: sub)
            .receive(on: DispatchQueue.main)
            .sink {[weak self] dittoDocs in
                guard let self = self else { return }
                isLoading = false
                docs = dittoDocs
            }
    }    
}

struct ContentView: View {
    @StateObject private var vm = ContentVM()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(vm.docs, id: \.id) { doc in
                        Text(doc.id.string ?? "dummy")
                    }
                }
            }
            .padding()
            .fullScreenCover(isPresented: $vm.isLoading) {
                ZStack {
                    Spacer()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black, ignoresSafeAreaEdges: .all).opacity(0.5)

                    VStack {
                        Text("Syncing...").font(.largeTitle)
                            .padding(.bottom, 48)
                        ProgressView()
                            .tint(.white)
                            .controlSize(.large)
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading ) {
                    Button {
                        vm.presentSettingsView = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $vm.presentSettingsView) {
                DittoToolsListView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
