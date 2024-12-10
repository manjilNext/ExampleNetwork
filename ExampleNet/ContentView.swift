//
//  ContentView.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var testNetwork = TestNetwork()
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                Text("Loading...")
                    .padding()
            } else {
                List(testNetwork.catImages, id: \.id) { catModel in
                    VStack {
                        if let urlString = catModel.url, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Text("No Image")
                        }
                        if let id = catModel.id {
                            Text(id)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await refreshImages()
                }
            }
        }
        .task {
            await loadInitialData()
        }
        .padding()
    }

    private func loadInitialData() async {
        isLoading = true
        await testNetwork.fetchCatImages()
        isLoading = false
    }

    private func refreshImages() async {
        await testNetwork.fetchCatImages()
    }
}
