//
//  CoreDataService.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import Foundation
import CoreData

protocol LocalStorageProtocol: AnyObject {
    /**
     Retrieves all chat friends stored locally.
     
     - Parameter completion: A closure called with the result containing an array of `Friend` objects on success,
     or an `Error` on failure.
     */
    func fetchChats(completion: @escaping (Result<[Friend], Error>) -> Void)
    
    /**
     Retrieves all messages for the specified friend from local storage.
     
     - Parameters:
     - friend: The `Friend` whose messages should be fetched.
     - completion: A closure called with the result containing an array of `Message` objects on success,
     or an `Error` on failure.
     */
    func fetchMessages(for friend: Friend,
                       completion: @escaping (Result<[Message], Error>) -> Void)
    
    /**
     Looks up and retrieves a friend by their name from local storage.
     
     - Parameters:
     - name: The name of the friend to search for.
     - completion: A closure called when the operation completes.
     On success, it returns an optional `Friend` (nil if no match was found).
     On failure, it returns an `Error` describing what went wrong.
     */
    func fetchFriend(named name: String, completion: @escaping (Result<Friend?, Error>) -> Void)
    
    /**
     Creates a new chat session with the specified name and stores it in local storage.
     
     - Parameters:
     - name: The name to assign to the new chat.
     - completion: A closure that is called when the operation finishes.
     On success, it returns the newly created `Friend` instance.
     On failure, it returns an `Error` describing the problem.
     */
    func createChat(_ name: String,
                    completion: @escaping (Result<Friend, Error>) -> Void)
    
    /**
     Creates a new message for the specified friend and stores it in local storage.
     
     - Parameters:
     - text: The text content of the message.
     - isIncoming: A Boolean indicating whether the message is incoming (`true`) or outgoing (`false`).
     - friend: The `Friend` instance to which this message belongs.
     - completion: An optional closure that is called when the operation completes.
     On success, it returns the newly created `Message`.
     On failure, it returns an `Error` describing what went wrong.
     
     - Returns: The newly created `Message` object, regardless of whether a completion handler is provided.
     */
    func createMessage(text: String,
                       isIncoming: Bool,
                       for friend: Friend,
                       completion: ((Result<Message, Error>) -> Void)?) -> Message
    
    /**
     Saves a message to local storage without returning the message object.
     
     - Parameters:
     - text: The text content of the message to save.
     - isIncoming: A Boolean indicating whether the message is incoming (`true`) or outgoing (`false`).
     - friend: The `Friend` instance associated with this message.
     - completion: An optional closure that is called when the save operation completes.
     If an error occurs, it is passed to the closure; otherwise, `nil` is passed on success.
     */
    func saveMessage(text: String,
                     isIncoming: Bool,
                     for friend: Friend,
                     completion: ((Error?) -> Void)?)
    
    /**
     Deletes the chat associated with the specified friend from local storage.
     
     - Parameters:
     - friend: The `Friend` whose chat should be deleted.
     - completion: An optional closure called with an `Error` if the delete operation fails, or `nil` on success.
     */
    func deleteChatWith(_ friend: Friend, completion: ((Error?) -> Void)?)
}

final class CoreDataService: LocalStorageProtocol {
    
    // MARK: - Properties. Public
    
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
    
    // MARK: - Properties. Private
    
    private let persistentContainer: NSPersistentContainer
    
    private var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    // MARK: - Methods. Public
    
    func fetchChats(completion: @escaping (Result<[Friend], Error>) -> Void) {
        self.context.perform {
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
    
    func createChat(_ name: String,
                    completion: @escaping (Result<Friend, Error>) -> Void) {
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
