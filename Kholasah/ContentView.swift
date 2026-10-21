import SwiftUI
import Playgrounds

struct ContentView: View {
    var body: some View {
        
        ZStack{
            Color(
                red: 242.0 / 255,
                green: 238.0 / 255,
                blue:234.0 / 255)
                .ignoresSafeArea()
            VStack{
                
                Image(.pic2)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("خُلاصة")
                    .foregroundStyle(Color(red: 0.392, green: 0.098, blue: 0.055, opacity: 1.00))
                    .font(.system( size: 35, weight: .bold))
            
                
                Text("Kholasah")
                
                    .foregroundStyle(Color(red: 0.392, green: 0.098, blue: 0.055, opacity: 1.00))
                    .fontWeight(.bold)
                    .font(.system(size: 35))
                    .font(.system( size: 35, weight: .regular))
                
               
                
            }
            
            
            
            
        }
        
        
        
        
        
        
        
       
    }
}

#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
