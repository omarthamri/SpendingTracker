//
//  MainView.swift
//  SpendingTracker
//
//  Created by omar thamri on 12/12/2022.
//

import SwiftUI
import CoreData

struct MainView: View {
    @State private var shouldPresentAddCardForm = false
   
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>
   @State private var cardSelectionIndex = 0
   @State private var selectedCardHash = -1
    
    var body: some View {
        NavigationView {
            ScrollView {
                if !cards.isEmpty {
                    
                    TabView(selection: $selectedCardHash) {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .padding(.bottom,50)
                                .tag(card.hash)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .frame(height: 280)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .onAppear{
                            self.selectedCardHash = cards.first?.hash ?? -1
                        }
                    if let firstIndex = cards.firstIndex(where: {$0.hash == selectedCardHash}) {
                        let card = self.cards[firstIndex]
                        TransactionListView(card: card)
                    }

                } else {
                    EmptyPromptMessage
                }
                Spacer().fullScreenCover(isPresented: $shouldPresentAddCardForm, onDismiss: nil) {
                    AddCardForm(card: nil) { card in
                        self.selectedCardHash = card.hash
                    }
                }
                
            }.navigationTitle("Credit Cards")
                .navigationBarItems(leading: HStack {
                    addItemButton
                    deleteAllButton

                },trailing: addCardButton)
        }
    }
    
    private var EmptyPromptMessage: some View {
        VStack {
            Text("You currently have no card in the system")
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .padding(.vertical)
            Button {
                shouldPresentAddCardForm.toggle()
            } label: {
                Text("+ Add your first card")
                    .foregroundColor(Color(.systemBackground))
            }
            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
            .background(Color(.label))
            .cornerRadius(5)

        }.font(.system(size: 22,weight: .semibold))
    }
    
    private var addItemButton: some View {
        Button(action: {
            withAnimation {
                let viewContext = PersistenceController.shared.container.viewContext
                let card = Card(context: viewContext)
                card.timestamp = Date()

                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }, label: {
            Text("Add Item")
        })
    }
    
    private var deleteAllButton: some View {
        Button (action:{
            cards.forEach{ card in
                viewContext.delete(card)
            }
            do {
                try viewContext.save()
            } catch {
                
            }
        }, label: {
            Text("Delete All")
        })
    }
    
    var addCardButton: some View {
        Button(action: {
            shouldPresentAddCardForm.toggle()
        }, label: {
            Text("+ Card")
                .foregroundColor(.white)
                .font(.system(size: 16 ,weight: .bold))
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .background(Color.black)
                .cornerRadius(5)
        })
    }
}

struct CreditCardView: View {
    let card: Card
    @State private var shouldShowActionSheet = false
    @State var shouldShowEditForm = false
    @State var refreshId = UUID()
    
    private func handleDelete() {
        let viewContext = PersistenceController.shared.container.viewContext
        viewContext.delete(card)
        do {
            try viewContext.save()
        } catch {
            
        }
    }
    
    var body: some View {
        VStack(alignment: .leading,spacing: 16) {
            HStack {
                Text(card.name ?? "")
                    .font(.system(size: 24,weight: .semibold))
                Spacer()
                Button {
                    shouldShowActionSheet.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 28,weight: .bold))
                }
                .actionSheet(isPresented: $shouldShowActionSheet) {
                    .init(title: Text(self.card.name ?? ""), message: Text("options"), buttons: [.destructive(Text("Delete Card"), action: handleDelete),.default(Text("Edit"),action: { shouldShowEditForm.toggle() }),.cancel()])
                }

            }
            HStack {
                Image("visa")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 44)
                Spacer()
                Text("Balance: \(card.limit)$")
                    .font(.system(size: 18,weight: .semibold))
            }
            Text(card.number ?? "")
            Text("Credit Limit: 50,000")
            HStack {Spacer()}
        }
        .foregroundColor(.white)
        .padding()
        .background(
            VStack {
                if let colorData = card.color, let colorUI = UIColor.color(data: colorData), let actualColor = Color(uiColor: colorUI) {
                    LinearGradient(colors: [actualColor.opacity(0.6),actualColor], startPoint: .center, endPoint: .bottom)
                } else {
                    Color.purple
            }
            }
            
        )
        .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(.black.opacity(0.5), lineWidth: 1))
        .cornerRadius(8)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.top,8)
        .fullScreenCover(isPresented: $shouldShowEditForm) {
            AddCardForm(card: card)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, viewContext)
    }
}
