//
//  DBManager.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 23/12/22.
//

import UIKit

class DBManager {
    init(){
            db = openDatabase()
    }

    let dbPath: String = "data.db"
    var db:OpaquePointer?

    func openDatabase() -> OpaquePointer?
    {
           let bundlePath = Bundle.main.path(forResource: "data", ofType: ".db")
           let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
           let fileManager = FileManager.default
           let fullDestPath = URL(fileURLWithPath: destPath).appendingPathComponent("data.db")
           if fileManager.fileExists(atPath: fullDestPath.path){
               print("Database file is exist")
               print(fileManager.fileExists(atPath: bundlePath!))
               let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                   .appendingPathComponent(dbPath)
               var db: OpaquePointer? = nil
               if sqlite3_open(fileURL.path, &db) != SQLITE_OK
               {
                   print("error opening database")
                   return nil
               }else{
                   print("Successfully opened connection to database at \(dbPath)")
                   return db
               }
           }else{
               do{
                   try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPath.path)
               }catch{
                   print("\n",error)
               }
           }
        return nil
    }
    
    // MARK: - table call_log
     
    func insertLog(dicLog: [String:Any]) {
        let insertStatementString = "insert into call_log(contact_name,charges,call_length,type,created_date,number) values(?,?,?,?,?,?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, ((dicLog["contact_name"] as? String ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, ((dicLog["charges"] as? String ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, ((dicLog["call_length"] as? String ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, ((dicLog["type"] as? String ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, ((dicLog["created_date"] as? String ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, ((dicLog["number"] as? String ?? "") as NSString).utf8String, -1, nil)

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func getAllCallLog() -> [[String:Any]]{
        let queryStatementString = "select * from call_log ORDER BY id DESC;"
        var queryStatement: OpaquePointer? = nil
        var dicDataCallLog = [[String:Any]]()
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let contact_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let charges = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let call_length = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let type = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let created_date = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let number = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))

                
                print("Query Result:")
                let dic = ["id":id,"contact_name":contact_name,"charges":charges,"call_length":call_length,"type":type,"created_date":created_date,"number":number] as! [String:Any]
                dicDataCallLog.append(dic)
                print("\(contact_name) | \(charges) | \(call_length)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        return dicDataCallLog

    }
    
    func deleteCallLog(number:String) {
        let deleteStatementStirng = "DELETE FROM call_log WHERE id = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, (number as NSString).utf8String, -1, nil)
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
                print(DBManager().getAllCallLog())
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    
    // MARK: - table favorite
    
    func insertFavorite(dicFavorite: [String:Any]){
        let insertStatementString = "insert into favorite(isfavorite,number) values(?,?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, ((dicFavorite["isfavourite"] as? String ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, ((dicFavorite["number"] as? String ?? "") as NSString).utf8String, -1, nil)

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    
    func getAllFavorite() -> [[String:Any]]{
        let queryStatementString = "select * from favorite ORDER BY number DESC;"
        var queryStatement: OpaquePointer? = nil
        var dicDataFavorite = [[String:Any]]()
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
               let isfavorite = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
               let number = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))

               print("Query Result:")
               let dic = ["number":number,"isfavorite":isfavorite] as! [String:Any]
               dicDataFavorite.append(dic)
               print(dic)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        return dicDataFavorite
    }
    
    func deleteByFavorite(number:String) {
        let deleteStatementStirng = "DELETE FROM favorite WHERE number = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, (number as NSString).utf8String, -1, nil)
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
                print(DBManager().getAllFavorite())
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    
    // MARK: - table recording
    
    func insertrecording(dicrecording: [String:Any]) {
        let insertStatementString = "insert into recording(date,number,name,audio_name,audioPath) values(?,?,?,?,?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, ((dicrecording["date"] as? String ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, ((dicrecording["number"] as? String ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, ((dicrecording["name"] as? String ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, ((dicrecording["audio_name"] as? String ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, ((dicrecording["audioPath"] as? String ?? "") as NSString).utf8String, -1, nil)

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    
    func getAllRecording() -> [[String:Any]]{
        let queryStatementString = "select * from recording ORDER BY name DESC;"
        var queryStatement: OpaquePointer? = nil
        var dicDataFavorite = [[String:Any]]()
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
               let data = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
               let number = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
               let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
               let audio_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
               let audioPath = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                
               let dic = ["data":data,"number":number,"name":name,"audio_name":audio_name,"audioPath":audioPath] as! [String:Any]
               dicDataFavorite.append(dic)
               print(dic)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        return dicDataFavorite
    }
    
    
    func deleteByRecording(audio_name:String) {
        let deleteStatementStirng = "DELETE FROM recording WHERE audio_name = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, (audio_name as NSString).utf8String, -1, nil)
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    
    func GetAllContry()  -> [[String:Any]]{
        let queryStatementString = "select * from countries;"
        var queryStatement: OpaquePointer? = nil
        var dicData = [[String:Any]]()
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
               let shortname = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
               let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
               let phoneCode = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                
               let dic = ["shortname":shortname,"name":name,"phoneCode":phoneCode] as! [String:Any]
               dicData.append(dic)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        return dicData
    }
    
    
    func GetAllStatesName(phoneCode: String) -> [[String:Any]] {
        
        let queryStatementString = "select * from states WHERE country_id = \(phoneCode);"
        var queryStatement: OpaquePointer? = nil
        var dicDataFavorite = [[String:Any]]()
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
               let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
               let contryId = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
               let dic = ["name":name,"country_id":contryId] as! [String:Any]
               dicDataFavorite.append(dic)
               print(dic)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        return dicDataFavorite
        
    }
    
    
    func GetAllCityName(stateId: String) -> [[String:Any]] {
        
        let queryStatementString = "select * from cities WHERE state_id = \(stateId);"
        var queryStatement: OpaquePointer? = nil
        var dicDataFavorite = [[String:Any]]()
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
               let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
               let state_id = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
               let dic = ["name":name,"state_id":state_id] as! [String:Any]
               dicDataFavorite.append(dic)
               print(dic)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        return dicDataFavorite
        
    }
 
}
