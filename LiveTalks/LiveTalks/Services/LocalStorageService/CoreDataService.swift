//
//  CoreDataService.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import Foundation
import CoreData

protocol LocalStorageProtocol: AnyObject {
    func fetchChats(completion: @escaping (Result<[Friend], Error>) -> Void)
    func fetchMessages(for friend: Friend,
                       completion: @escaping (Result<[Message], Error>) -> Void)
    func createMessage(text: String,
                          isIncoming: Bool,
                          for friend: Friend,
                          completion: ((Result<Message, Error>) -> Void)?) -> Message
    func saveChat(name: String, completion: ((Error?) -> Void)?)
    func saveMessage(text: String,
                     isIncoming: Bool,
                     for friend: Friend,
                     completion: ((Error?) -> Void)?)
    func deleteChat(_ friend: Friend, completion: ((Error?) -> Void)?)
    
}

final class CoreDataService: LocalStorageProtocol {
    
    static let shared = CoreDataService()
    
    // MARK: - Initializer
    
    private init() {
        self.persistentContainer = NSPersistentContainer(name: "LiveTalks")
        self.persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data store: \(error)")
            }
        }
    }
    
    // Properties. Private
    
    private let persistentContainer: NSPersistentContainer
    
    private var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    // MARK: - Methods
    
    func fetchChats(completion: @escaping (Result<[Friend], Error>) -> Void) {
        context.perform {
            let req: NSFetchRequest<Friend> = Friend.fetchRequest()
            req.sortDescriptors = [ NSSortDescriptor(key: "name", ascending: true) ]
            do {
                let friends = try self.context.fetch(req)
                completion(.success(friends))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func createMessage(text: String,
                       isIncoming: Bool,
                       for friend: Friend,
                       completion: ((Result<Message, Error>) -> Void)?) -> Message {
        let msg = Message(context: context)
        msg.text = text
        msg.date = Date()
        msg.isIncoming = isIncoming
        msg.friend = friend
        do {
            try context.save()
            completion?(.success(msg))
        } catch {
            completion?(.failure(error))
        }
        return msg
    }
    
    func saveChat(name: String, completion: ((Error?) -> Void)?) {
        context.perform {
            let friend = Friend(context: self.context)
            friend.name = name
            do {
                try self.context.save()
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
    
    func deleteChat(_ friend: Friend, completion: ((Error?) -> Void)?) {
        context.perform {
            self.context.delete(friend)
            do {
                try self.context.save()
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
    
    func fetchMessages(for friend: Friend,
                       completion: @escaping (Result<[Message], Error>) -> Void) {
        context.perform {
            let req: NSFetchRequest<Message> = Message.fetchRequest()
            req.predicate = NSPredicate(format: "friend == %@", friend)
            req.sortDescriptors = [ NSSortDescriptor(key: "date", ascending: true) ]
            do {
                let messages = try self.context.fetch(req)
                completion(.success(messages))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func saveMessage(text: String,
                     isIncoming: Bool,
                     for friend: Friend,
                     completion: ((Error?) -> Void)?) {
        context.perform {
            let msg = Message(context: self.context)
            msg.text = text
            msg.date = Date()
            msg.isIncoming = isIncoming
            msg.friend = friend
            do {
                try self.context.save()
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
    
}
