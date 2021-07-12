//
//  ContentView.swift
//  JMBGchecker
//
//  Created by Novica Pavkovic on 22.3.21..
//

import SwiftUI

class NumbersOnly: ObservableObject {
    let characterLimit = 13
    @Published var value = "" {
        didSet{
            let filtered = value.filter { $0.isNumber }
            if value != filtered {
                value = filtered
            }
            if value.count > characterLimit {
                value = String(value.prefix(characterLimit))
            }
        }
    }
}

struct ContentView: View {
    
    @ObservedObject var personalNumber = NumbersOnly()
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            Text("JMBG Provera").font(.title).bold().offset(x: 5, y: -20)
            HStack {
                VStack(alignment: .leading) {
                    Image(systemName: "person.fill").font(.system(size: 55))
                }
            }
            HStack {
                VStack(alignment: .center) {
                    TextField("Unesite JMBG ...", text: $personalNumber.value).padding().keyboardType(.decimalPad)
                }
            }
            Button(action: {
                self.showingAlert = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    Text("Proveri").fontWeight(.semibold).font(.title)
                }.frame(minWidth:0, maxWidth: .infinity).padding().foregroundColor(.white).background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)).cornerRadius(40).padding(.horizontal,20)
            }.alert(isPresented: self.$showingAlert){
                let pomText = Text(checkJMBG(personalNumber: personalNumber).message)
                return Alert(title: pomText)
            }
        }.padding(.horizontal,10).background(Color(.secondarySystemGroupedBackground))
    }
}

func checkJMBG (personalNumber: NumbersOnly) -> (result: Bool, message: String) {
    let niz = Array(personalNumber.value)
    var pomGodina:Int32 = 100 * Int32(String(niz[4]))! + 10 * Int32(String(niz[5]))! + Int32(String(niz[6]))!
    if (niz[4] == "0") { pomGodina+=2000 } else {pomGodina+=1000}
    
    if (personalNumber.value.count == 13) {
        var danUmesecu: [Int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
                
        if(pomGodina<1900) {
            let result = false
            let message = "Unesena godina rodjenja manja od 1900-e !!!"
            return (result, message)
        } else {
            if(pomGodina>Calendar.current.component(.year, from: Date())) {
                let result = false
                let  message = "Unesena godina rodjenja veca od tekuce godine !!!"
                return (result, message)
            }
        }
        
        let pomMesec:Int32 = 10 * Int32(String(niz[2]))! + Int32(String(niz[3]))!
        if (pomMesec>12 || pomMesec < 1) {
            let result = false
            let message = "Pogresno unesen mesec rodjenja !!!"
            return (result, message)
        }

        let pomDan:Int32 = 10 * Int32(String(niz[0]))! + Int32(String(niz[1]))!
        print(pomDan,pomMesec,pomGodina)
        
        if (pomGodina % 4 == 0) {
            danUmesecu[1] = 29
        } else { danUmesecu[1] = 28}
        
        if (pomDan > danUmesecu[Int(pomMesec) - 1] || pomDan < 1) {
                let result = false
                let message = "Pogresno unesen dan rodjenja !!!"
                return (result, message)
        }
        
        // Formula za racunanje kontrolnog zbira ...
        let zbir = 7 * (Int(String(niz[0]))! + Int(String(niz[6]))!) + 6 * (Int(String(niz[1]))! + Int(String(niz[7]))!) + 5 * (Int(String(niz[2]))! + Int(String(niz[8]))!) + 4 * (Int(String(niz[3]))! + Int(String(niz[9]))!) + 3 * (Int(String(niz[4]))! + Int(String(niz[10]))!) + 2 * (Int(String(niz[5]))! + Int(String(niz[11]))!)
        let ostatak = zbir % 11
        var kontrolni = 11 - ostatak
        if kontrolni > 9 {
             kontrolni = 0
        }
        
        
        print(zbir, ostatak, kontrolni)

        if kontrolni != Int(String(niz[12]))! {
            let result = false
            let message = "Uneti maticni broj nije ispravan - Neispravan kontrolni broj !!!"
            return (result,message)
        }

        
    } else {
        let result = false
        let message = "JMBG mora biti ducak 13 karaktera !!!"
        return (result, message)
        
    }
    
    
    let day:String = String(niz[0...1])
    let month:String = String(niz[2...3])

    
    var regija:String
    switch String(niz[7...8]) {
        case "71" : regija = "Beograd"
        case "72" : regija = "Šumadija"
        case "73" : regija = "Niš"
        case "74" : regija = "Južna Morava"
        case "75" : regija = "Zaječar"
        case "76" : regija = "Podunavlje"
        case "77" : regija = "Podrinje i Kolubara"
        case "78" : regija = "Kraljevo"
        case "79" : regija = "Užice"
        case "80" : regija = "Novi Sad"
        case "81" : regija = "Sombor"
        case "82" : regija = "Subotica"
        case "85" : regija = "Zrenjanin"
        case "86" : regija = "Pančevo"
        case "87" : regija = "Kikinda"
        case "88" : regija = "Ruma"
        case "89" : regija = "Sremska Mitrovica"
        case "91" : regija = "Priština"
        case "92" : regija = "Kosovska Mitrovica"
        case "93" : regija = "Peć"
        case "94" : regija = "Đakovica"
        case "95" : regija = "Prizren"
        case "96" : regija = "Kosovsko Pomoravski okrug"
    default:
        regija = ""
    }
    
    var sex:String
    if Int(String(niz[9...11]))! < 500 {
         sex = "muški"
    } else {sex = "ženski"}
    
    return (true, """
Uneti maticni broj je ispravan!
Datum rođenja: \(day).\(month).\(pomGodina)
Regija: \(regija)
Pol: \(sex)
""")
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
