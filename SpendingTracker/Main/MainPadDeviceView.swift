//
//  MainPadDeviceView.swift
//  SpendingTracker
//
//  Created by omar thamri on 18/12/2022.
//

import SwiftUI

struct MainPadDeviceView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>
    @State var shouldShowAddCardForm = false
    var body: some View {
        NavigationView {
            ScrollView {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .frame(width: 350)
                        }
                    }
                }
            }.navigationTitle("Money Tracker")
                .navigationBarItems(trailing: addCardButton)
                .sheet(isPresented: $shouldShowAddCardForm) {
                    AddCardForm()
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var addCardButton: some View {
        Button {
            shouldShowAddCardForm.toggle()
        } label: {
            Text("+ Card")
        }

    }
    
}

struct MainPadDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        MainPadDeviceView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
