//
//  ViewController.swift
//  ListApp5
//
//  Created by Güray Gül on 27.12.2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Load tasks from UserDefaults or use an empty array if not available
    var tasks: [String] = UserDefaults.standard.stringArray(forKey: "tasks") ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        cell.textLabel?.text = task
        return cell
    }
    
    // MARK: Add Button
    @IBAction func didAddBarTapped() {
        let alert = UIAlertController(title: "Add Task", message: nil, preferredStyle: .alert)
        alert.addTextField()
        
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    
            if let textField = alert.textFields?.first, let newTask = textField.text, !newTask.isEmpty {
                self.tasks.append(newTask)
                self.saveTasksToUserDefaults()
                self.tableView.reloadData()
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
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, success) in
            self.tasks.remove(at: indexPath.row)
            self.saveTasksToUserDefaults()
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [delete])
        return swipeActions
    }
    
    // MARK: Move Action
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedTask = tasks.remove(at: sourceIndexPath.row)
        tasks.insert(movedTask, at: destinationIndexPath.row)
        
        saveTasksToUserDefaults()
    }
    
    // MARK: Save tasks to UserDefaults
    func saveTasksToUserDefaults() {
        UserDefaults.standard.set(tasks, forKey: "tasks")
    }
}

