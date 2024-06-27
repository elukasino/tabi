//
//  TripView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 24.06.2024.
//

import SwiftUI
import CoreLocation

/*struct TripView: View {
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
}*/

struct TripView: View {
    @EnvironmentObject var tripVM: TripVM
    @EnvironmentObject var driverVM: DriverVM
    @Environment(\.colorScheme) var colorScheme
    
    @State var trip: Trip
    @State var selectedDriver: String
    
    init(trip: Trip) {
        _trip = State(initialValue: trip)
        _selectedDriver = State(initialValue: trip.driverId ?? "")
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                MapView(startLocation: trip.startLocation, endLocation: trip.endLocation)
                .frame(height: 150)
                .clipShape(CustomRoundedRectangle(corners: [.topLeft, .topRight], radius: 20))
                /*HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Group {
                            Text("Start")
                                .font(.callout)
                                .foregroundColor(.gray)
                            Text(trip.startDateTime)
                                .font(.callout)
                            Text(trip.startLocation.address)
                                .font(.callout)
                                .padding(.bottom)
                        }
                        Group {
                            Text("Destination")
                                .font(.callout)
                                .foregroundColor(.gray)
                            Text(trip.endDateTime)
                                .font(.callout)
                            Text(trip.endLocation.address)
                                .font(.callout)
                                .padding(.bottom)
                            Image("dotted-trip-line")
                                .resizable()
                                .frame(width: 75, height: 20)
                        }
                    }
                    Spacer()
                    VStack(spacing: -10.0) {
                        Text(String(trip.distance))
                            .font(.title)
                            .fontWeight(.black)
                        Text("km")
                            .font(.title)
                            .fontWeight(.black)
                    }
                }*/
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Start")
                            .font(.callout)
                            .foregroundColor(.gray)
                        Text(tripVM.dateToString(date: trip.startDateTime, timeZone: trip.originalTimeZone))
                            .font(.callout)
                        Text(tripVM.timeToString(date: trip.startDateTime, timeZone: trip.originalTimeZone))
                            .font(.callout)
                        Text(trip.startLocation.address)
                            .font(.callout)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "car.fill")
                                .foregroundStyle(.gray)
                                .font(.system(size: 14))
                            Text("\(trip.distance, specifier: trip.distance < 10 ? "%.1f" : "%.0f") km")
                                .font(.callout)
                                .foregroundStyle(.gray)
                        }
                        Image(colorScheme == .light ? "dotted-line" : "dotted-line-dark-mode")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90)
                            .opacity(0.4)
                    }
                    .padding(.top)
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Destination")
                            .font(.callout)
                            .foregroundStyle(.gray)
                        Text(tripVM.dateToString(date: trip.endDateTime, timeZone: trip.originalTimeZone))
                            .font(.callout)
                        Text(tripVM.timeToString(date: trip.endDateTime, timeZone: trip.originalTimeZone))
                            .font(.callout)
                        Text(trip.endLocation.address)
                            .font(.callout)
                    }
                }
                .padding([.leading, .bottom, .trailing])
                .padding(.top, 4)
                Picker("Driver", selection: $selectedDriver) {
                    ForEach(driverVM.drivers) { driver in
                        Text(driver.firstName)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedDriver, {
                    Task {
                        trip.driverId = selectedDriver
                        await tripVM.updateTripDriver(trip)
                    }
                })
            }
            .background(RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .light ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                .shadow(color: colorScheme == .light ? .black.opacity(0.33) : .white.opacity(0.25), radius: 8.0))
            .padding()
        }
    }
}

struct CustomRoundedRectangle: Shape {
    var corners: UIRectCorner = .allCorners
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    TripView(trip: Trip(startDateTime: Date(timeIntervalSinceNow: 0), endDateTime: Date(timeIntervalSinceNow: 2000), originalTimeZone: TimeZone.current, startLocation: Location(address: "Thákurova 9, Praha", coordinate: CLLocationCoordinate2D(latitude: 50.105050295798094, longitude: 14.389895002767982)), endLocation: Location(address: "Dlouhá, Veleň", coordinate: CLLocationCoordinate2D(latitude: 50.17556417431436, longitude: 14.553697441650922)), distance: 250.6))
        .environmentObject(TripVM(tripService: AppDependency.shared.tripService))
        .environmentObject(DriverVM(driverService: AppDependency.shared.driverService))
}
