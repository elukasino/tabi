//
//  SummaryView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import SwiftUI

struct SummaryView: View {
    var body: some View {
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .navigationTitle("Summary")
            Image(systemName: "person.2.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.blue, .red)
        }
    }
}

#Preview {
    SummaryView()
}
