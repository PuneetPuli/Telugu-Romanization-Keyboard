//
//  KeyboardViewController.swift
//  telugincu
//
//  Created by Puneet Puli on 9/25/24.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    let vowelMap: [String: String] = [
        "a": "అ", "ā": "ఆ", "i": "ఇ", "ī": "ఈ", "u": "ఉ", "ū": "ఊ",
        "r̥": "ఋ", "r̥̄": "ౠ", "l̥": "ఌ", "l̥̄": "ౡ" ,"e": "ఎ", "ē": "ఏ",
        "ai": "ఐ", "o": "ఒ", "ō": "ఓ", "au": "ఔ",
    ]
    let consonantMap: [String: String] = [
        // Consonants
        "ka": "క", "kha": "ఖ", "ga": "గ", "gha": "ఘ", "ṅa": "ఙ",
        "ṭa": "ట", "ṭha": "ఠ", "ḍa": "డ", "ḍha": "ఢ", "ṇa": "ణ",
        "ca": "చ", "cha": "ఛ", "ja": "జ", "jha": "ఝ", "ña": "ఞ",
        "ta": "త", "tha": "థ", "da": "ద", "dha": "ధ", "na": "న",
        "pa": "ప", "pha": "ఫ", "ba": "బ", "bha": "భ", "ma": "మ",
        "ya": "య", "ra": "ర", "la": "ల", "ɭa": "ళ" ,"va": "వ",
        "śa": "శ", "ṣa": "ష" ,"sa": "స", "ha": "హ", "ḻa" :"ఴ", "ksh": "క్ష" ,"ṟa" :"ఱ",
        "ḏa" :"ౚ", "tsa": "ౘ", "dza" :"ౙ"
    ]
    
    let diacriticMap: [String: String] = [
        "ā": "ా", "i": "ి", "ī": "ీ", "u": "ు", "ū": "ూ",
        "e": "ె", "ē": "ే", "ai": "ై", "o": "ొ", "ō": "ో", "au": "ౌ"
    ]
    
    let specialConsonantMap: [String: String] = [
        "f": "్",   // Halant/virama (removes the inherent "a" sound)
        "n̆": "ఁ",  // Chandrabindu (nasal sound)
        "ṁ": "ం",   // Anusvara (nasalization)
        "ḥ": "ః"    // Visarga (aspiration)
    ]
    var transliterationMap: [String: String] = [:]
    let allCharacters = ["a", "ā", "i", "ī", "u", "ū", "e", "ē", "ai", "au",
    "ṁ", "ḥ", "n̆", "k", "ṅ" ,"c", "ṭ", "ḍ", "ṇ", "c", "j", "ñ", "t", "d", "n", "p",
    "b", "m", "y", "r", "l", "ɭ", "v", "ś", "ṣ", "s", "h", "ḻ", "ṟ", "ḏ", "f"]
    
    
    
    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createKeyboardLayout()
            // Add the next keyboard button programmatically if it's not from the storyboard
        self.nextKeyboardButton = UIButton(type: .system)
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)

        self.view.addSubview(self.nextKeyboardButton)
        
        // Apply button constraints
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        createKeyboardLayout()  // Ensure this line is present
        generateTransliterationMap()
        generateTransliterationMap()
    }
    
    
    func createKeyboardLayout() {
        let buttonWidth: CGFloat = 40  // Reduced size to fit more buttons
        let buttonHeight: CGFloat = 40
        let spacing: CGFloat = 5

        var row = 0
        var column = 0
        for latinKey in allCharacters {
            let button = UIButton(type: .system)
            button.setTitle(latinKey, for: .normal)
            button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
            
            let xPosition = CGFloat(column) * (buttonWidth + spacing) + 10
            let yPosition = CGFloat(row) * (buttonHeight + spacing) + 50
            button.frame = CGRect(x: xPosition, y: yPosition, width: buttonWidth, height: buttonHeight)
            
            self.view.addSubview(button)
            
            column += 1
            if column >= 10 {  // Increased number of columns
                column = 0
                row += 2
            }
        }
    }
    @objc func keyTapped(_ sender: UIButton) {
            if let latinKey = sender.title(for: .normal) {
                if let teluguChar = transliterationMap[latinKey] {
                    let proxy = self.textDocumentProxy
                    proxy.insertText(teluguChar)
                }
            }
        }
    
    
    // need to fix this
    
    func generateTransliterationMap() {
        // Add standalone vowels
        transliterationMap = vowelMap
        
        // Generate consonant + vowel combinations
        for (consonant, teluguConsonant) in consonantMap {
            // Consonant with inherent "a" sound
            transliterationMap[consonant] = teluguConsonant
            
            // Apply diacritics for other vowels
            for (vowel, diacritic) in diacriticMap {
                let transliteratedSyllable = teluguConsonant + diacritic
                transliterationMap[consonant + vowel] = transliteratedSyllable
            }
            
            // Handle special consonant forms (virama, nasalization, aspiration)
            transliterationMap[consonant + "∅"] = teluguConsonant + specialConsonantMap["f"]! // Halant (removes implicit 'a')
            transliterationMap[consonant + "n̆"] = teluguConsonant + specialConsonantMap["n̆"]! // Chandrabindu (nasal)
            transliterationMap[consonant + "ṁ"] = teluguConsonant + specialConsonantMap["ṁ"]! // Anusvara (nasal)
            transliterationMap[consonant + "ḥ"] = teluguConsonant + specialConsonantMap["ḥ"]! // Visarga (aspiration)
        }
    }
    
    
    
    override func viewWillLayoutSubviews() {
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    func transliterate(input: String) -> String {
            var output = ""
            var currentIndex = input.startIndex
            var previousConsonant = false // To detect consonant clusters

            while currentIndex < input.endIndex {
                // Try to match multi-letter transliterations (up to 3 characters)
                var matched = false
                for length in stride(from: 3, through: 1, by: -1) {
                    let endIndex = input.index(currentIndex, offsetBy: length, limitedBy: input.endIndex) ?? input.endIndex
                    let substring = String(input[currentIndex..<endIndex])

                    // Check if the substring matches a transliteration
                    if let transliterated = transliterationMap[substring] {
                        if previousConsonant, substring.starts(with: "∅") { // Consonant + halant
                            output += specialConsonantMap["∅"]!
                        } else {
                            output += transliterated
                        }
                        
                        currentIndex = endIndex
                        matched = true

                        // Check if the current character is a consonant
                        if consonantMap.keys.contains(substring) {
                            previousConsonant = true
                        } else {
                            previousConsonant = false
                        }

                        break
                    }
                }

                if !matched {
                    // If no match, use the original character
                    let nextIndex = input.index(after: currentIndex)
                    output += String(input[currentIndex..<nextIndex])
                    currentIndex = nextIndex
                    previousConsonant = false
                }
            }
            return output
        }
    
}
