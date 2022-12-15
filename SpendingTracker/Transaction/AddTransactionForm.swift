//
//  AddTransactionForm.swift
//  SpendingTracker
//
//  Created by omar thamri on 15/12/2022.
//

import SwiftUI

struct AddTransactionForm: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var amount = ""
    @State private var date = Date()
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations")) {
                    TextField("Name", text: $name)
                    TextField("Amount", text: $amount)
                    DatePicker("Date", selection: $date,displayedComponents: .date)
                    NavigationLink {
                        Text("new page").navigationTitle("Title")
                    } label: {
                        Text("many to many")
                    }

                }
                Section(header: Text("Photo/Receipt")) {
                    Button {
                        
                    } label: {
                        Text("Select Photo")
                    }

                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarItems(leading: cancelButton, trailing: savelButton)
        }
    }
    
    
    private var savelButton: some View {
        Button {
            
        } label: {
            Text("Save")
        }

    }
    
    private var cancelButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Cancel")
        }

    }
}

struct AddTransactionForm_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionForm()
    }
}
