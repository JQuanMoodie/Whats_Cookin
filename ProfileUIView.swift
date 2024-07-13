//
//  ProfileUIView.swift
//  UserProfile
//
//  Created by Jevon Williams on 7/9/24.
//

import SwiftUI
import PhotosUI
struct ProfileUIView: View {
    @StateObject var viewModel = ProfileViewModel()
    @State private var isOnline: Bool = UserDefaults.standard.bool(forKey: "isOnlineStatus")
    @State private var navigateToSettings = false
    @State private var showViewController = false
    @State private var bioInput: String = UserDefaults.standard.string(forKey: "userInput") ?? ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        
        NavigationStack{
            VStack{
                 HStack{
                    Button(action: {
                        dismiss() // Dismiss the view and go back
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.blue)
                    }.padding()
                    
                     Spacer()
                }
                NavigationLink("Go to Detail View", destination: DetailView())
               
                PhotosPicker(selection: $viewModel.selectedItem) {
                    if let profileImage = viewModel.profileImage{
                        profileImage.resizable()
                            .scaledToFill()
                            .frame(width:80, height: 80)
                            .clipShape(Circle())
                    }
                    else{
                        Image(systemName: "person.circle.fill").resizable()
                            .frame(width:80, height: 80)
                        .foregroundColor(Color(.systemGray4))                }
                    
                }
                Text("John Doe").font(.title2)
                    .fontWeight(.semibold)
                TextField("Bio", text: $bioInput).padding()
                    .background(Color.clear)
                    .frame(width:300,height:100)
                    .keyboardType(.alphabet)
                    .font(.system(size:20))
                    .onAppear {
                    // Load the saved input when the view appears
                    bioInput = UserDefaults.standard.string(forKey: "userInput") ?? ""
                                        }
                    .onDisappear {
                // Save the user input to UserDefaults when the view disappears
                    UserDefaults.standard.set(bioInput, forKey: "userInput")
                                        }
                
                List{
                    
                    Section{
                        Text(isOnline ? "Ready To Cook!" : "Offline")
                            .font(.system(size:20))
                            .padding()
                            .foregroundColor(.red)
                        Button(action:{
                            
                            isOnline.toggle()
                            UserDefaults.standard.set(isOnline, forKey: "isOnlineStatus")
                        }){
                            
                            Text(isOnline ? "Offline" : "Ready To Cook!")
                                .font(.system(size:20))
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                    }.foregroundColor(.black)
                    
                }.onAppear{
                    // Load the saved status when the view appears
                    isOnline = UserDefaults.standard.bool(forKey: "isOnlineStatus")
                    }            }
            
            
        }
        
    }
}

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Detail View")
           
        }
        .navigationTitle("Detail Page")
    }
}


#Preview {
    ProfileUIView()
}


