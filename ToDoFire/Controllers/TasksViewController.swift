//
//  TasksViewController.swift
//  ToDoFire
//
//  Created by ruslan on 22.05.2021.
//

import UIKit
import Firebase

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: User!
    var ref: DatabaseReference!
    var tasks = Array<Task>()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        guard let currentUser = Auth.auth().currentUser else { return }
        user = User(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(user.uid).child("tasks")
    }
    
    // MARK: - Fetching data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value) { [weak self] snapshot in
            var _tasks = Array<Task>()
            for item in snapshot.children {
                let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(task)
            }
            
            self?.tasks = _tasks
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = tasks[indexPath.row]
        let taskTitle = task.title
        let taskStatus = task.completed
        cell.textLabel?.text = taskTitle
        
        toggleCompletion(of: cell, with: taskStatus)
        
        return cell
    }
    
    // MARK: - Removing data
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    
    // MARK: - Completion marking
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
        let taskStatus = !task.completed
        
        toggleCompletion(of: cell, with: taskStatus)
        task.ref?.updateChildValues(["completed" : taskStatus])
    }
    
    func toggleCompletion(of cell: UITableViewCell, with taskStatus: Bool) {
        cell.accessoryType = taskStatus ? .checkmark : .none
    }
    
    // MARK: - Saving data
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "New task", message: "Add a new task", preferredStyle: .alert)
        alertController.addTextField()
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first, textField.text != "" else {
                let alertControllerOfError = UIAlertController(title: "Error", message: "Please add something", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
                    self?.present(alertController, animated: true)
                }
                alertControllerOfError.addAction(ok)
                self?.present(alertControllerOfError, animated: true)
                return
            }
            
            let task = Task(title: textField.text!, userId: (self?.user.uid)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.convertToDict())            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        
        alertController.addAction(save)
        alertController.addAction(cancel)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Signing out
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
}
