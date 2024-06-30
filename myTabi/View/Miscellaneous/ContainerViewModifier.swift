//
//  ContainerViewModifier.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 30.06.2024.
//

import SwiftUI

struct ContainerViewModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .background(RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .light ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                .shadow(color: colorScheme == .light ? .black.opacity(0.15) : .white.opacity(0.2), radius: 8.0))
    }
}

extension View {
    func customContainerStyle() -> some View {
        self.modifier(ContainerViewModifier())
    }
}

