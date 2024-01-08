//
//  ViewController.swift
//  ListApp5
//
//  Created by Güray Gül on 27.12.2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Load tasks from UserDefaults or use an empty array if not available
    private var tasks = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get items from CoreData
        fetchData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = self.tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        cell.textLabel?.text = task.name
        return cell
    }
    
    // MARK: Fetching Data
    func fetchData() {
        // Fetch the data from CoreData to display in the tableview
        do {
            let request = ToDoListItem.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
            tasks = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            // error handling
        }
    }
    
    // MARK: Add Button
    @IBAction func didAddBarTapped() {
        let alert = UIAlertController(title: "Add Task", message: nil, preferredStyle: .alert)
        alert.addTextField()
        
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            
            if let textField = alert.textFields?.first, let newTask = textField.text, !newTask.isEmpty {
                
                let newItem = ToDoListItem(context: self.context)
                newItem.name = newTask
                newItem.order = Int64(self.tasks.count) // Adding new items to the bottom of the list
                
                self.tasks.append(newItem)
                
                self.saveData()
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
            // Do nothing
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Edit Button
    @IBAction func didEditBarTapped() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didEditBarTapped))
        }
        else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didEditBarTapped))
        }
    }
    
    // MARK: Swipe Delete Action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            // Which task to remove
            let taskToRemove = self.tasks[indexPath.row]
            
            // Remove the task
            self.context.delete(taskToRemove)
            
            self.saveData()
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [delete])
        return swipeActions
    }
    
    // MARK: Move Action
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let movedTask = self.tasks.remove(at: sourceIndexPath.row)
        tasks.insert(movedTask, at: destinationIndexPath.row)
        
        updateOrderValues()
        saveData()
    }
    
    func updateOrderValues() {
        for (index, task) in tasks.enumerated() {
            task.order = Int64(index)
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: Edit Action
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Which task to edit
        let taskToEdit = self.tasks[indexPath.row]
        
        // Create Alert
        let alert = UIAlertController(title: "Edit Task", message: "Edit Task", preferredStyle: .alert)
        alert.addTextField()
        
        let textField = alert.textFields?.first
        textField?.text = taskToEdit.name
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { (action) in
            
            // Get the textfield for the alert
            let textField = alert.textFields?.first
            
            // Edit task property of tasks object
            taskToEdit.name = textField?.text
            
            self.saveData()
        }
        alert.addAction(saveButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Save Data
    func saveData() {
        do {
            try self.context.save()
        }
        catch {
            // Error handling
        }
        self.fetchData()
    }
}

