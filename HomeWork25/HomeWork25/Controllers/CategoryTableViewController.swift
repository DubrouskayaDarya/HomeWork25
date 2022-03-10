//
//  CategoryTableViewController.swift
//  HomeWork25
//
//  Created by Дарья Дубровская on 9.03.22.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {

    var categories = [CategoryModel]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }


    @IBAction func addCategoruButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new categories", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Category"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first,
                let text = textField.text,
                text != "",
                let self = self {
                let newCategory = CategoryModel(context: self.context)
                newCategory.name = text
                self.categories.append(newCategory)
                self.saveCategories()
                self.tableView.insertRows(at: [IndexPath(row: self.categories.count - 1, section: 0)], with: .automatic)
            }
        }

        alert.addAction(cancel)
        alert.addAction(addAction)

        self.present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: nil)

    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            if let name = categories[indexPath.row].name {
                let request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
                request.predicate = NSPredicate(format: "name==\(name)")

                if let categories = try? context.fetch(request) {
                    for category in categories {
                        context.delete(category)
                    }

                    self.categories.remove(at: indexPath.row)
                    saveCategories()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toDoListTableViewController = segue.destination as? ToDoListTableViewController, let indexPath = tableView.indexPathForSelectedRow {
            toDoListTableViewController.selectedCategory = categories[indexPath.row]
        }
    }

    private func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error save context")
        }
    }

    private func loadCategories(with request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetch context")
        }
        tableView.reloadData()
    }
}
