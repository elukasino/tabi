//
//  TripView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 24.06.2024.
//

import SwiftUI

struct TripView: View {
    @EnvironmentObject var tripVM: TripVM
    @EnvironmentObject var driverVM: DriverVM
    var trip: Trip
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(trip.startLocation) to \(trip.endLocation)")
                    .font(.headline)
                Text("Distance: \(trip.distance) km")
                    .font(.subheadline)
            }
            Spacer()
            
            if let driverId = trip.driverId, let driver = driverVM.getDriver(by: driverId) {
                Text(driver.firstName + " " + driver.lastName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Text("Unassigned")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    TripView(trip: Trip(startDateTime: "1.1.2000", endDateTime: "3.4.2005", startLocation: "Praha", endLocation: "Brno", distance: 250.6))
        .environmentObject(TripVM(tripService: AppDependency.shared.tripService))
        .environmentObject(DriverVM(driverService: AppDependency.shared.driverService))
}
