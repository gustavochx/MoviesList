//
//  MoviesListApp.swift
//  MoviesList
//
//  Created by Gustavo Henrique Frota Soares on 20/10/26.
//

import SwiftUI

@main
struct MoviesListApp: App {
    @State private var appCoordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            appCoordinator.makeRootView()
        }
    }
}
