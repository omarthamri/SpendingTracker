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
                TransactionGrid()
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

struct TransactionGrid: View {
    var body: some View {
        VStack {
            HStack {
                Text("Transactions")
                Spacer()
                Button {
                    
                } label: {
                    Text("+ Transaction")
                }

            }
            let columns: [GridItem] = [.init(.fixed(100), spacing: 16,alignment: .leading),
                                         .init(.fixed(200), spacing: 16),
                                       .init(.adaptive(minimum: 300, maximum: 800), spacing: 16, alignment: .leading),
                                       .init(.flexible(minimum: 100, maximum: 450), spacing: 16,alignment: .trailing)]
            LazyVGrid(columns: columns) {
                HStack {
                    Text("Date")
                    Image(systemName: "arrow.up.arrow.down")
                }
                Text("Photo / Receipt")
                HStack {
                    Text("Name")
                    Image(systemName: "arrow.up.arrow.down")
                    Spacer()
                }
                HStack {
                    Text("Amount")
                    Image(systemName: "arrow.up.arrow.down")
                }
            }.foregroundColor(Color(.darkGray))
        }
        .font(.system(size: 24,weight: .semibold))
        .padding()
    }
}

struct MainPadDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        MainPadDeviceView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
