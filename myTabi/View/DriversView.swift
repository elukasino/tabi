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
            ZStack {
                if driverVM.drivers.isEmpty {
                    BackgroundIconView(symbolName: "custom.person.2.slash")
                    ScrollView {
                        Rectangle().opacity(0)
                    }
                } else {
                    List(driverVM.drivers) { driver in
                        NavigationLink {
                            EditDriverView(driver: driver)
                        } label: {
                            Text(driver.firstName)
                        }
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                Task {
                                    await driverVM.deleteDriver(by: driver.id)
                                }
                            }
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
                    if driverVM.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Button {
                            confirmationDialogPresented = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .confirmationDialog("Do you want to delete all drivers?", isPresented: $confirmationDialogPresented, titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                Task {
                                    await driverVM.deleteAllDrivers()
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
            }
            .navigationTitle("Drivers")
            .refreshable {
                Task {
                    await driverVM.fetchAllDrivers()
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
        NavigationStack {
            Form {
                Section {
                    TextField("First name", text: $driverFirstName)
                    TextField("Last name", text: $driverLastName)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if driverVM.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .onDisappear {
                            if !driverVM.errorOccurred {
                                dismiss()
                            }
                        }
                } else {
                    Button {
                        Task {
                            await driverVM.createDriver(firstName: driverFirstName, lastName: driverFirstName)
                        }
                    } label: {
                        Text("Save")
                            .fontWeight(.bold)
                    }
                    .disabled(driverFirstName.isEmpty)
                    .disabled(driverLastName.isEmpty)
                }
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
                        Button(role: .destructive, action: {
                            confirmationDialogPresented = true
                        }, label: {
                            if driverVM.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .onDisappear {
                                        if !driverVM.errorOccurred {
                                            dismiss()
                                        }
                                    }
                            } else {
                                Text("Delete driver")
                            }
                        })
                        .confirmationDialog("Do you want to delete this driver?", isPresented: $confirmationDialogPresented, titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                Task {
                                    await driverVM.deleteDriver(by: driver.id)
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if driverVM.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .onDisappear {
                                if !driverVM.errorOccurred {
                                    dismiss()
                                }
                            }
                    } else {
                        Button {
                            Task {
                                await driverVM.updateDriver(driver)
                            }
                        } label: {
                            Text("Save")
                                .fontWeight(.bold)
                        }
                        .disabled(driver.firstName.isEmpty)
                        .disabled(driver.lastName.isEmpty)
                    }
                }
            }
            .navigationTitle("Edit driver")
        }
    }
}

#Preview {
    DriversView()
        .environmentObject(DriverVM(driverService: AppDependency.shared.driverService))
}
