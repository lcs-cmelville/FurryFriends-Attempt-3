//
//  ContentView.swift
//  FurryFriends
//
//  Created by Russell Gordon on 2022-02-26.
//

import SwiftUI

struct CatView: View {
    
    // MARK: Stored properties
    
    @Environment(\.scenePhase) var scenePhase
    
    // Address for main image
    // Starts as a transparent pixel – until an address for an animal's image is set
    @State var currentImage = URL(string: "https://www.russellgordon.ca/lcs/miscellaneous/transparent-pixel.png")!
    
    @State var currentCat: Cat = Cat(file: "https://www.russellgordon.ca/lcs/miscellaneous/transparent-pixel.png")
    
    @State var favourites: [Cat] = []
    
    @State var currentCatAddedToFavourites: Bool = false
    
    // MARK: Computed properties
    var body: some View {
        
        VStack {
            
            // Shows the main image
            RemoteImageView(fromURL: currentImage)
            
            Button(action: {
                
                Task {
                    await loadNewCat()
                }
                
            }, label: {
                Text("New Cat!")
            })
                .buttonStyle(.bordered)
            
            Image(systemName: "heart.circle")
                .foregroundColor(currentCatAddedToFavourites == true ? .red : .secondary)
                .font(.largeTitle)
                .padding(.bottom)
                .onTapGesture {
                    
                    if currentCatAddedToFavourites == false {
                        
                        favourites.append(currentCat)
                        
                        currentCatAddedToFavourites = true
                        
                    }
                }
            
            
            List(favourites, id: \.self) { currentFavourite in
                Text(currentFavourite.file)
            }
            
            // Push main image to top of screen
            Spacer()
            
        }
        // Runs once when the app is opened
        .task {
            
            // Example images for each type of pet
            let remoteCatImage = "https://purr.objects-us-east-1.dream.io/i/JJiYI.jpg"
            
            // Replaces the transparent pixel image with an actual image of an animal
            // Adjust according to your preference ☺️
            currentImage = URL(string: remoteCatImage)!
            
            await loadNewCat()
            
        }
        
        .onChange(of: scenePhase) { newPhase in
            
            if newPhase == .inactive{
                print("Inactive")
            } else if newPhase == .active {
                print("Active")
            } else {
                print("Background")
                
                // Permanently save the list of tasks
                persistFavourites()
            }
            
        }
        .navigationTitle("Furry Cat Friends")
        
    }
    
    // MARK: Functions
    
    func loadNewCat() async {
        // Assemble the URL that points to the endpoint
        let url = URL(string: "https://aws.random.cat/meow")!
        
        // Define the type of data we want from the endpoint
        // Configure the request to the web site
        var request = URLRequest(url: url)
        // Ask for JSON data
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        // Start a session to interact (talk with) the endpoint
        let urlSession = URLSession.shared
        
        // Try to fetch a new joke
        // It might not work, so we use a do-catch block
        do {
            
            // Get the raw data from the endpoint
            let (data, _) = try await urlSession.data(for: request)
            
            // Attempt to decode the raw data into a Swift structure
            // Takes what is in "data" and tries to put it into "currentJoke"
            //                                 DATA TYPE TO DECODE TO
            //                                         |
            //                                         V
            currentCat = try JSONDecoder().decode(Cat.self, from: data)
            
            currentImage = URL(string: currentCat.file)!
            // Replace the currentImage with a new currentImage based on the link (String) from the API
            
            // Reset the flag that tracks whether the current joke is a favourite
            currentCatAddedToFavourites = false
            
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            // Print the contents of the "error" constant that the do-catch block
            // populates
            print(error)
        }
    }
    
    func persistFavourites() {
        
        // Get a location under which to save the data
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        print(filename)
        
        // Try to encode the data in our list of favourites  JSON
        
        do {
            
            // Create a JSON encoder object
            let  encoder = JSONEncoder()
            
            // Configured the coder to "pretty print" the JSON
            encoder.outputFormatting = .prettyPrinted
            
            // Encode the list of Favourites we collected
            let data = try encoder.encode(favourites)
            
            // rite the JSON to a file in the fineName location we came up with earlier
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            
            // See the data that was written
            print("Save data to the Documetns directory successfully")
            print("========")
            print(String(data: data, encoding: .utf8)!)
            
        } catch {
            print("Unable to write list of favourites to the Document directory")
            print("========")
            print(error.localizedDescription)
        }
        
    }
    
}

struct CatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CatView()
        }
    }
}
