//
//  TripView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 24.06.2024.
//

import SwiftUI
import CoreLocation

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
            LazyVStack(alignment: .leading) {
                MapView(startLocation: trip.startLocation, endLocation: trip.endLocation)
                .frame(height: 150)
                .clipShape(CustomRoundedRectangle(corners: [.topLeft, .topRight], radius: 20))
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
                .padding([.leading, .trailing])
                .padding(.top, 4)
                Group {
                    if driverVM.drivers.count < 6 {
                        Picker("Driver", selection: $selectedDriver) {
                            ForEach(driverVM.drivers) { driver in
                                Text(driver.firstName.isEmpty ? driver.lastName : driver.firstName).tag(driver.id)
                            }
                        }
                        .pickerStyle(.segmented)
                    } else {
                        Picker("Driver", selection: $selectedDriver) {
                            ForEach(driverVM.drivers) { driver in
                                Text(driver.firstName + " " + driver.lastName).tag(driver.id)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .onChange(of: selectedDriver, {
                    Task {
                        trip.driverId = selectedDriver
                        await tripVM.updateTripDriver(trip)
                    }
                })
                .padding()
            } //VStack ends here
            .background(RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .light ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                .shadow(color: colorScheme == .light ? .black.opacity(0.2) : .white.opacity(0.25), radius: 8.0))
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
