//
//  ContentView.swift
//  NavanTest
//
//  Created by Travis Palmer on 8/5/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel = PostViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage.message)
                            .foregroundColor(.red)
                            .padding()

                        Button(action: {
                            viewModel.fetchPosts()
                        }) {
                            Text("Retry")
                        }
                        .padding()
                    }
                } else {
                    List(viewModel.posts, id: \.id) { post in
                        VStack(alignment: .leading) {
                            Text(post.title)
                                .font(.headline)
                            Text(post.body)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Posts")
            .onAppear {
                if viewModel.posts.isEmpty {
                    viewModel.fetchPosts()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
