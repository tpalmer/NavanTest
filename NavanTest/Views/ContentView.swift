//
//  ContentView.swift
//  NavanTest
//
//  Created by Travis Palmer on 8/5/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PostViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isConnected {
                    List(viewModel.posts) { post in
                        VStack(alignment: .leading) {
                            Text(post.title)
                                .font(.headline)
                            Text(post.body)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text("No Internet Connection")
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Posts")
            .alert(item: $viewModel.errorMessage) { errorMessage in
                Alert(title: Text("Error"), message: Text(errorMessage.message), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                // Fetch posts only when the view appears
                viewModel.fetchPosts()
            }
        }
    }
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
