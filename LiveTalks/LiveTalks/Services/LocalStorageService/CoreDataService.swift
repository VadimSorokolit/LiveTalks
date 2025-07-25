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
    func fetchFriend(named name: String, completion: @escaping (Result<Friend?, Error>) -> Void)
    func createChat(_ name: String,
                    completion: @escaping (Result<Friend, Error>) -> Void)
    func createMessage(text: String,
                       isIncoming: Bool,
                       for friend: Friend,
                       completion: ((Result<Message, Error>) -> Void)?) -> Message
    func saveMessage(text: String,
                     isIncoming: Bool,
                     for friend: Friend,
                     completion: ((Error?) -> Void)?)
    func deleteChatWith(_ friend: Friend, completion: ((Error?) -> Void)?)
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
            let request: NSFetchRequest<Friend> = Friend.fetchRequest()
            request.sortDescriptors = [ NSSortDescriptor(key: "name", ascending: true) ]
            request.predicate = NSPredicate(format: "messages.@count > 0")
            
            do {
                let nonEmptyChats = try self.context.fetch(request)
                completion(.success(nonEmptyChats))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchMessages(for friend: Friend, completion: @escaping (Result<[Message], Error>) -> Void) {
        self.context.perform {
            let request: NSFetchRequest<Message> = Message.fetchRequest()
            request.predicate = NSPredicate(format: "friend == %@", friend)
            request.sortDescriptors = [ NSSortDescriptor(key: "date", ascending: true) ]
            
            do {
                let messages = try self.context.fetch(request)
                completion(.success(messages))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchFriend(named name: String, completion: @escaping (Result<Friend?, Error>) -> Void) {
        self.context.perform {
            let req: NSFetchRequest<Friend> = Friend.fetchRequest()
            req.predicate = NSPredicate(format: "name ==[c] %@", name)
            req.fetchLimit = 1
            
            do {
                let results = try self.context.fetch(req)
                completion(.success(results.first))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult 
    func createMessage(text: String,
                       isIncoming: Bool,
                       for friend: Friend,
                       completion: ((Result<Message, Error>) -> Void)?) -> Message {
        let message = Message(context: self.context)
        message.text = text
        message.date = Date()
        message.isIncoming = isIncoming
        message.friend = friend
        
        do {
            try self.context.save()
            completion?(.success(message))
        } catch {
            completion?(.failure(error))
        }
        
        return message
    }
    
    func createChat(_ name: String, completion: @escaping (Result<Friend, Error>) -> Void) {
        self.context.perform {
            let friend = Friend(context: self.context)
            friend.name = name
            
            do {
                try self.context.save()
                
                completion(.success(friend))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func deleteChatWith(_ friend: Friend, completion: ((Error?) -> Void)?) {
        self.context.perform {
            self.context.delete(friend)
            
            do {
                try self.context.save()
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
    
    func saveMessage(text: String,
                     isIncoming: Bool,
                     for friend: Friend,
                     completion: ((Error?) -> Void)?) {
        self.context.perform {
            let message = Message(context: self.context)
            message.text = text
            message.date = Date()
            message.isIncoming = isIncoming
            message.friend = friend
            
            do {
                try self.context.save()
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
    
}
