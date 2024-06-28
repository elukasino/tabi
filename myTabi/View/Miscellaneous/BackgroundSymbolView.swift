//
//  BackgroundSymbolView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 26.06.2024.
//

import SwiftUI

struct BackgroundIconView: View {
    let symbolName: String
    var body: some View {
        Image(symbolName)
            .foregroundStyle(
                .gray.gradient
                .shadow(
                    .inner(color: .black.opacity(0.6), radius: 2, x: 1, y: 1)
                )
                .shadow(
                    .drop(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                )

            )
            .font(.system(size: 100).bold())
            .opacity(0.2)
    }
}

#Preview {
    BackgroundIconView(symbolName: "custom.person.2.slash")
}
