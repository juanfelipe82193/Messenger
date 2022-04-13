//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by Juan Felipe Zorrilla Ocampo on 13/04/22.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
