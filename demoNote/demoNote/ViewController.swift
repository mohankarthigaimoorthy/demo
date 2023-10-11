//
//  ViewController.swift
//  demoNote
//
//  Created by Imcrinox Mac on 29/12/1444 AH.
//

import UIKit
import CoreData


class ViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var addnoteButton: UIBarButtonItem!
    
    var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.getNote()
        // Do any additional setup after loading the view.
    }
    func getNote() {
        let noteFetch: NSFetchRequest<Note> = Note.fetchRequest()
        let sortByDate = NSSortDescriptor(key: #keyPath(Note.dateAdded), ascending: false)
        noteFetch.sortDescriptors = [sortByDate]
        do {
            let managedContext = AppDelegate.shareAppDelegate.coreDataStack.managedContext
            let result = try managedContext.fetch(noteFetch)
            notes = result
        }
        catch let error as NSError {
            print("Fetch Error: \(error) description: \(error.userInfo)")
        }
    }

    func configureView() {
        UIHelper().setCustomNavigationTitle(title: "CoreDataNotesExample", navItem: navigationItem)
        UIHelper().setNavigationBar(tintColor: .white, navController: navigationController, navItem: self.navigationItem)
        
        self.table.delegate = self
        self.table.dataSource = self
        self.table.backgroundColor = .gray
        self.table.separatorStyle = .none
        self.table.register(NoteCell.nib, forCellReuseIdentifier: NoteCell.identifier)
    }
    @IBAction func addNoteBtn(_ sender: UIBarButtonItem) {
        
        let addNoteVC = addNoteViewController(nibName: addNoteViewController.identifier, bundle: nil)
        addNoteVC.modalTransitionStyle = .crossDissolve
        addNoteVC.modalPresentationStyle = .custom
        
        addNoteVC.saveNote = { [weak self] noteText, priorityColor in
            guard let self = self else {return}
        
            let managedContext = AppDelegate.shareAppDelegate.coreDataStack.managedContext
            let newNote = Note(context: managedContext)
            newNote.setValue(Date(), forKey: #keyPath(Note.dateAdded))
            newNote.setValue(noteText, forKey: #keyPath(Note.noteText))
            newNote.setValue(priorityColor, forKey: #keyPath(Note.priorityColor))
            self.notes.insert(newNote, at: 0)
            AppDelegate.shareAppDelegate.coreDataStack.saveContext()
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
        present(addNoteVC, animated: true, completion: nil)
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = table.dequeueReusableCell(withIdentifier: NoteCell.identifier, for: indexPath) as? NoteCell else { fatalError("xib doesn't exist") }
        let currentNote = self.notes[indexPath.row]
        cell.contentTxtLbl.text = currentNote.noteText
        cell.priorityview.backgroundColor = currentNote.priorityColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentNote = self.notes[indexPath.row]
        let addNoteVC = addNoteViewController(nibName: addNoteViewController.identifier, bundle: nil)
        addNoteVC.modalTransitionStyle = .crossDissolve
        addNoteVC.modalPresentationStyle = .custom
        addNoteVC.setNotes(text: currentNote.noteText ?? "", priorityColor: currentNote.priorityColor ?? UIColor.clear)
        
        addNoteVC.saveNote = {[weak self] noteText, priorityColor in
            guard let self = self else {return}
            self.notes[indexPath.row].setValue(noteText, forKey: #keyPath(Note.noteText))
            self.notes[indexPath.row].setValue(priorityColor, forKey: #keyPath(Note.priorityColor))
            AppDelegate.shareAppDelegate.coreDataStack.saveContext()
            DispatchQueue.main.async {
                self.table.beginUpdates()
                self.table.reloadRows(at: [indexPath], with: .fade)
                self.table.endUpdates()
            }
        }
        present(addNoteVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = table.dequeueReusableCell(withIdentifier: NoteCell.identifier, for: indexPath) as?
            NoteCell else { fatalError("xib doesn't exist")}
        cell.BGView.backgroundColor = .gray
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = table.dequeueReusableCell(withIdentifier: NoteCell.identifier, for: indexPath) as?
            NoteCell else { fatalError("xib doesn't exist")}
        cell.BGView.backgroundColor = .lightGray
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, complete in
            AppDelegate.shareAppDelegate.coreDataStack.managedContext.delete(self.notes[indexPath.row])
            self.notes.remove(at: indexPath.row)
            AppDelegate.shareAppDelegate.coreDataStack.saveContext()
            self.table.deleteRows(at: [indexPath], with: .automatic)
            complete(true)
        }
        deleteAction.image = UIImage(systemName: "xmark.circle")
        deleteAction.backgroundColor = .systemGray
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
}
