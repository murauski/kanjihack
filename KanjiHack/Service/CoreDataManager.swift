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
    
    func saveNewQuestions(questions: [QuestionDTO]) {
        
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        let userEntity = NSEntityDescription.entity(forEntityName: "Question", in: context)
        
        for item in questions {
            let newQuestion = NSManagedObject(entity: userEntity!, insertInto: context)
            newQuestion.setValue(item.hint1, forKey: "hint1")
            newQuestion.setValue(item.hint2, forKey: "hint2")
            newQuestion.setValue(item.value, forKey: "value")
            newQuestion.setValue(0, forKey: "score")
        }
        
        saveContext()
    }
    
    func getCurrentDeckWithLimit(limit: Int) -> [Question] {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        request.returnsObjectsAsFaults = false
        let sectionSortDescriptor = NSSortDescriptor(key: "score", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = limit
        
        do {
            let result = try context.fetch(request)
            return (result as? [Question])!
            
        } catch {
            print("Failed")
            return []
        }
        
    }
    
    //TODO: Add additional layer for this bussiness logic
    
    func getCurrentLevel() -> Int {
        
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        request.returnsObjectsAsFaults = false
        let sectionSortDescriptor = NSSortDescriptor(key: "score", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = 1
        
        do {
            let result = try context.fetch(request)
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
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        fetchRequest.predicate = NSPredicate(format: "score == %i", level)
        
        do {
            let questionWithLevelCount = try context.count(for: fetchRequest)
            return questionWithLevelCount
        } catch {
            print("CoreData: current label did failed")
            return 0
        }
    }

    func getTotalQuestionsCount() -> Int {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        do {
            let totalScoreCount = try context.count(for: request)
            return totalScoreCount
        } catch {
            print("CoreData: Total Questions count did failed")
            return 0
        }
    }
    
    func resetDB() {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        let deleteAllQuestions = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Question"))
        do {
            try context.execute(deleteAllQuestions)
        }
        catch {
            print(error)
        }
    }

    func saveContext () {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
