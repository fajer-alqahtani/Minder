//
//  MedicationView.swift
//  Minder
//
//  Created by Areeg Altaiyah on 24/11/2025.
//

import SwiftUI

struct MedicationView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                MedicineName()
                MedicineDosage()
                MedicineTime()
                Spacer()
                ConfirmButton()
            }
            .padding(25)
            //Navigation details
            .navigationBarTitle("Add Medication")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}

// -----Medicine name and the text field-----

struct MedicineName : View {
    @State public var MedicineName: String = ""
    var body: some View {
        VStack(alignment: .leading) {
            Text("Medicine Name").font(.title3).bold()
            TextField("", text: $MedicineName)
                .padding()
                .background(Color.accent.opacity(0.10))
                .cornerRadius(12)
        }
        .padding(.bottom,20)
    }
}

// -----Medicine dosage and stepper-----

struct MedicineDosage: View {
    @State private var value: Int = 0
    var body: some View {
        HStack {
            //Dosage and the Stepper
            Text("Dosage").font(.title3).bold()
            LabeledStepper("", description: "", value: $value).font(.title3).bold()
        } .padding(.bottom,20)

    }
}

// -----Medicine Time-----

struct MedicineTime : View {
    enum TimeOfDay {
        case morning
        case night
    }

    @State private var selected: TimeOfDay? = nil
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Time").font(.title3).bold()
            HStack{
                //Morning button
                Button {
                    selected = .morning
                } label: {
                    Label {
                        Text("Morning")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(Color.black)
                    } icon: {
                        Image(systemName: "sun.max.fill")
                            .foregroundStyle(Color.ourYellow).font(.title3).bold()
                    }
                }
                .frame(width: 148, height: 56)
                .background(selected == .morning ? Color.ourYellow.opacity(0.2) : Color.accent.opacity(0.1))
                .cornerRadius(65)
                .overlay(
                    RoundedRectangle(cornerRadius: 65)
                        .stroke(selected == .morning ? Color.ourYellow : Color.clear, lineWidth: 3)
                )
                
                Spacer()
                //Night button
                Button {
                    selected = .night
                } label: {
                    Label {
                        Text("Night")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(Color.black)
                    } icon: {
                        Image(systemName: "moon.fill")
                            .foregroundStyle(Color.accent).font(.title3).bold()
                    }
                }
                .frame(width: 148, height: 56)
                .background(selected == .night ? Color.accent.opacity(0.3) : Color.accent.opacity(0.1))
                .cornerRadius(65)
                .overlay(
                    RoundedRectangle(cornerRadius: 65)
                        .stroke(selected == .night ? Color.accent : Color.clear, lineWidth: 3)
                )
            }.padding(.horizontal,25)
        }
    }
}

struct ConfirmButton: View {
    var body: some View {
        Button {
            // Add confirm action here
        } label: {
            Text("Confirm")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.white)
        }
            .frame(width: 354, height: 56)
            .background(.ourGrey)
            .cornerRadius(43)
        
    }
}

#Preview {
    MedicationView()
}

