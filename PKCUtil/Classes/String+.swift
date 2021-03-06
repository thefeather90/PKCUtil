//
//  String.swift
//  ClubfulIOS
//
//  Created by guanho on 2016. 8. 21..
//  Copyright © 2016년 guanho. All rights reserved.
//

import Foundation

public extension String {
    //초성 자동완성을 위해 .plist가져오기
    public var koreanInitialDict: [String: String]{
        guard let plist = Bundle(for: PKCUtil.self).path(forResource: "KoreanInitial", ofType: "plist") else {
            return [:]
        }
        guard let dict = NSDictionary(contentsOfFile: plist) as? [String: String] else {
            return [:]
        }
        return dict
    }
    
    
    //로컬라이즈
    public var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    
    //로컬라이즈
    public func localizedWithComment(_ comment:String = "") -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
    
    
    //substring 추가
    public func substring(from:Int = 0, to:Int = -1) -> String {
        var toTmp = to
        if toTmp < 0 {
            toTmp = self.characters.count + toTmp
        }
        //from toTmp+1
        let range = self.characters.index(self.startIndex, offsetBy: from)..<self.characters.index(self.startIndex, offsetBy: toTmp+1)
        return self.substring(with: range)
    }
    
    //substring
    public func substring(from:Int = 0, length:Int) -> String {
        let range = self.characters.index(self.startIndex, offsetBy: from)..<self.characters.index(self.startIndex, offsetBy: from+length)
        return self.substring(with: range)
    }
    
    public func range() -> Range<Index>{
        let range = self.characters.index(self.startIndex, offsetBy: 0)..<self.characters.index(self.startIndex, offsetBy: self.characters.count-1)
        return range
    }
    
    
    //url을 쿼리로 인코딩하기(특수문자를 등을 인코딩)
    public func queryValue() -> String{
        guard let value = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else{
            return ""
        }
        return value
    }
    
    
    //json형으로 되어있는 스트링을 JSON으로 만들기
    public func parseJSON() -> AnyObject{
        guard let data = (self).data(using: String.Encoding.utf8) else{
            return "" as AnyObject
        }
        var jsonResult :Any
        do {
            jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            return jsonResult as AnyObject
        } catch let error as NSError {
            print("parseJSON error \(error)")
            jsonResult = "" as AnyObject
        }
        return jsonResult as AnyObject
    }
    
    
    
    //확장자 구하기
    public func getExt(_ defaultExt : ExtType = .png) -> ExtType{
        if self.uppercased().range(of: "PNG") != nil{
            return .png
        }else if self.uppercased().range(of: "JPEG") != nil || self.uppercased().range(of: "JPG") != nil{
            return .jpeg
        }else {
            return defaultExt
        }
    }
    
    
    //base64 문자열 디코딩
    public func base64Decoding() -> Data{
        guard let imageData = Data(base64Encoded: self, options:NSData.Base64DecodingOptions(rawValue: 0)) else{
            return Data()
        }
        return imageData
    }
    
    
    
    
    
    //Initial Auto Complete 초성 자동완성
    public func makeInitail() -> String{
        var out = ""
        for (index, _) in self.characters.enumerated() {
            let oneChar: UniChar = NSString(string: self).character(at: index)
            if (oneChar >= 0xAC00 && oneChar <= 0xD7A3){
                let value = ((oneChar - 0xAC00)/28)/21 + 0x1100
                self.koreanInitialDict.keys.forEach({ (key) in
                    out = "\(out)\(self.compareInitialKey(value, key: key))"
                })
            }
        }
        return out
    }
    
    private func compareInitialKey(_ value: UInt16, key: String) -> String{
        var result = ""
        if value == UInt16(key) {
            if let value = self.koreanInitialDict[key]{
                result = "\(value)"
            }
        }
        return result
    }
    
    
    //초성 자동완성 글자 비교하기
    public func isContains(_ string: String, noneSearch: Bool = true) -> Bool{
        if string.characters.count == 1 && string.makeInitail() == ""{
            return PKCUtil.isValidateKorean(string) ? self.makeInitail().contains(string) : self.contains(string)
        }else{
            return string.characters.count == 0 ? noneSearch : self.contains(string)
        }
    }
}
