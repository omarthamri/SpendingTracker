//
//  AddCardForm.swift
//  SpendingTracker
//
//  Created by omar thamri on 13/12/2022.
//

import SwiftUI

struct AddCardForm: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
            }
                .navigationTitle("Add Credit Card")
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                }))
        }
    }
}

struct AddCardForm_Previews: PreviewProvider {
    static var previews: some View {
        AddCardForm()
    }
}
