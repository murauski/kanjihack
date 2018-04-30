//
//  CoreDataStackManager.swift
//  KanjiHack
//
//  Created by Anthony Marchenko on 4/29/18.
//  Copyright © 2018 Anthony Marchenko. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let sharedManager = CoreDataManager()
    
    private init() {} // Prevent clients from creating another instance.
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "KanjiHack")
        
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveNewQuestions(questions: [QuestionDTO]) -> SyncStatusDTO {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        var addedQuestions = 0
        var updatedQuestions = 0
        var deletedQuestions = 0
        
        //Synchronization logic
        //1. Mark all questons as not sync
        markAllQuestionsAsNotSynchronized()
        
        
        for item in questions {
            
            do {
                //2. Update question or create a new one
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
                request.returnsObjectsAsFaults = true
                request.predicate = NSPredicate(format: "value == %@", item.value)
                let fetchedResults = try managedContext.fetch(request) as! [Question]
                
                let newQuestionItem = fetchedResults.first
                
                if let existingQuestion = newQuestionItem {
                    // update
                    
                    if existingQuestion.hint1 != item.hint1 || existingQuestion.hint2 != item.hint2 {
                        existingQuestion.setValue(item.hint1, forKey: "hint1")
                        existingQuestion.setValue(item.hint2, forKey: "hint2")
                        
                        updatedQuestions += 1
                    }
                    
                    existingQuestion.setValue(NSNumber(value: true), forKey: "isSync")
                    
                } else {
                    let userEntity = NSEntityDescription.entity(forEntityName: "Question", in: managedContext)
                    let newQuestion = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                    newQuestion.setValue(item.hint1, forKey: "hint1")
                    newQuestion.setValue(item.hint2, forKey: "hint2")
                    newQuestion.setValue(item.value, forKey: "value")
                    newQuestion.setValue(0, forKey: "score")
                    newQuestion.setValue(NSNumber(value: true), forKey: "isSync")
                    
                    addedQuestions += 1
                }
                
            } catch {
                print("CoreData: something went wrong with syncon")
            }
        }
        
        
        // 3. Delete all not sync items
        deletedQuestions = deleteAllNotSyncQuestion()

        
        return SyncStatusDTO(added: addedQuestions, updated: updatedQuestions, deleted: deletedQuestions, total: getTotalQuestionsCount())
    }
    
    func markAllQuestionsAsNotSynchronized() {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        request.returnsObjectsAsFaults = true
        
        do {
            let result = try managedContext.fetch(request) as! [Question]
            for item in result {
                item.setValue(NSNumber(value: false), forKey: "isSync")
            }
        } catch {
            print("CoreData: something went wrong with not updated")
        }
    }
    
    func deleteAllNotSyncQuestion() -> Int {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        request.returnsObjectsAsFaults = true
        request.predicate = NSPredicate(format: "isSync == %@", NSNumber(value: false))
        
        do {
            let objects = try managedContext.fetch(request) as! [Question]

            for object in objects {
                managedContext.delete(object)
            }
            
            return objects.count
        } catch {
            print("CoreData: Delete all previous logic")
            return 0
        }
    }
    
    func getCurrentDeckWithLimit(limit: Int) -> [Question] {
    	let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        request.returnsObjectsAsFaults = true
        let sectionSortDescriptor = NSSortDescriptor(key: "score", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = limit
        
        do {
            let result = try managedContext.fetch(request)
            return (result as? [Question])!
            
        } catch {
            print("Failed")
            return []
        }
        
    }
    
    //TODO: Add additional layer for this bussiness logic
    
    func getCurrentLevel() -> Int {
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        request.returnsObjectsAsFaults = true
        let sectionSortDescriptor = NSSortDescriptor(key: "score", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = 1
        
        do {
            let result = try managedContext.fetch(request)
            let questions = (result as? [Question])!
            
            guard questions.first != nil else {
                
                return 0
            }
            
            return Int(Double((questions.first?.score)!))
        } catch {
            print("CoreData: get current level did failed")
            return 0
        }
    }
    
    func getQuestionsCountForLevel(level: Int) -> Int {
       
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        fetchRequest.predicate = NSPredicate(format: "score == %i", level)
        
        do {
            let questionWithLevelCount = try managedContext.count(for: fetchRequest)
            return questionWithLevelCount
        } catch {
            print("CoreData: current label did failed")
            return 0
        }
    }
    
    func getTotalQuestionsCount() -> Int {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        do {
            let totalScoreCount = try managedContext.count(for: request)
            return totalScoreCount
        } catch {
            print("CoreData: Total Questions count did failed")
            return 0
        }
    }
    
    func resetDB() {

        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let deleteAllQuestions = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Question"))
        do {
            try managedContext.execute(deleteAllQuestions)
            saveContext()
        }
        catch {
            print(error)
        }
    }
    
    func saveContext () {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        if managedContext.hasChanges {
            do {
                try managedContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
