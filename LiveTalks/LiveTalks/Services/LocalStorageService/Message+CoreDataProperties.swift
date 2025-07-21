//
//  Message+CoreDataProperties.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import Foundation
import CoreData

extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var text: String?
    @NSManaged public var date: Date?
    @NSManaged public var isIncoming: Bool
    @NSManaged public var friend: Friend?

}

extension Message : Identifiable {}
