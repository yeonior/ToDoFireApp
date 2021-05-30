//
//  Task.swift
//  ToDoFire
//
//  Created by ruslan on 27.05.2021.
//

import Foundation
import Firebase

struct Task {
    
    let title: String
    let userId: String
    let ref: DatabaseReference?
    var completed = false
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String:AnyObject]
        title = snapshotValue["title"] as! String
        userId = snapshotValue["userId"] as! String
        ref = snapshot.ref
        completed = snapshotValue["completed"] as! Bool
    }
    
    func convertToDict() -> Any {
        return ["title": title, "userId": userId, "completed": completed]
    }
}
