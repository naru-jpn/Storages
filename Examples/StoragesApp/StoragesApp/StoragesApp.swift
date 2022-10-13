//
//  StoragesApp.swift
//  StoragesApp
//
//  Created by Naruki Chigira on 2022/10/11.
//

import Storages
import SwiftUI

@main
struct StoragesApp: App {
    var body: some Scene {
        WindowGroup {
            StorageBrowser(source: .home)
        }
    }
}
