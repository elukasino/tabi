//
//  DriversView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import SwiftUI

struct DriversView: View {
    @EnvironmentObject var driverVM: DriverVM
    
    @State var addDriverSheetPresented = false
    @State var confirmationDialogPresented = false
    
    var body: some View {
        NavigationStack {
            List(driverVM.drivers) { driver in
                NavigationLink {
                    EditDriverView(driver: driver)
                } label: {
                    Text(driver.firstName)
                }
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        Task {
                            /*await*/ driverVM.removeDriver(by: driver.id)
                        }
                    }
                }
            }
            .sheet(isPresented: $addDriverSheetPresented) {
                NavigationView {
                    AddDriverView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        addDriverSheetPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        confirmationDialogPresented = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .confirmationDialog("Do you want to delete all drivers?", isPresented: $confirmationDialogPresented, titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            Task {
                                /*await*/ driverVM.removeAllDrivers()
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    
                }
            }
            .navigationTitle("Drivers")
            .refreshable {
                Task {
                    //await driverVM.fetchDrivers()
                }
            }
            .alert(isPresented: $driverVM.errorOccurred) {
                Alert(title: Text("Error"), message: Text(driverVM.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct AddDriverView: View {
    @EnvironmentObject var driverVM: DriverVM
    @Environment(\.dismiss) var dismiss
    
    @State var driverFirstName: String = ""
    @State var driverLastName: String = ""
    
    var body: some View {
        VStack {
            Form {
                TextField("First name", text: $driverFirstName)
                TextField("Last name", text: $driverLastName)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        /*await*/ driverVM.addDriver(firstName: driverFirstName, lastName: driverFirstName)
                        dismiss()
                    }
                } label: {
                    Text("Save")
                        .fontWeight(.bold)
                }
                .disabled(driverFirstName.isEmpty)
                .disabled(driverLastName.isEmpty)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert(isPresented: $driverVM.errorOccurred) {
            Alert(title: Text("Error"), message: Text(driverVM.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("Add driver")
    }
}

struct EditDriverView: View {
    @EnvironmentObject var driverVM: DriverVM
    @Environment(\.dismiss) var dismiss
    
    @State var driver: Driver
    @State var confirmationDialogPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        TextField("First name", text: $driver.firstName)
                        TextField("Last name", text: $driver.lastName)
                    }
                    Section {
                        Button("Delete driver", role: .destructive) {
                            confirmationDialogPresented = true
                        }
                        .confirmationDialog("Do you want to delete this driver?", isPresented: $confirmationDialogPresented, titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                Task {
                                    /*await*/ driverVM.removeDriver(by: driver.id)
                                    dismiss()
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            /*await*/ driverVM.updateDriver(driver)
                            dismiss()
                        }
                    } label: {
                        Text("Save")
                            .fontWeight(.bold)
                    }
                    .disabled(driver.firstName.isEmpty)
                    .disabled(driver.lastName.isEmpty)
                    
                }
            }
            .navigationTitle(driver.firstName)
        }
    }
}

#Preview {
    DriversView()
        .environmentObject(DriverVM(driverService: AppDependency.shared.driverService))
}
