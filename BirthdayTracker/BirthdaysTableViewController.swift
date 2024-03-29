//
//  BirthdaysTableViewController.swift
//  BirthdayTracker
//
//  Created by Евгений Латышев on 7/12/19.
//  Copyright © 2019 Evgeny Latyshev. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class BirthdaysTableViewController: UITableViewController {
  var birthdays = [Birthday] ()
  let dateFormatter = DateFormatter()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .none
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let fetchRequest = Birthday.fetchRequest() as NSFetchRequest<Birthday>
    
    let sortDescriptor1 = NSSortDescriptor(key: "lastName", ascending: true)
    let sortDescriptor2 = NSSortDescriptor(key: "firstName", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
    do {
      birthdays = try context.fetch(fetchRequest)
    } catch let error {
      print("Could not save because of\(error).")
    }
    tableView.reloadData()
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return birthdays.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "birthdayCellIdentifier", for: indexPath)
    let birthday = birthdays[indexPath.row]
    
    let firstName = birthday.firstName ?? " "
    let lastName = birthday.lastName ?? " "
    cell.textLabel?.text = firstName + " " + lastName
    
    if let date = birthday.birthdate as Date? {
      cell.detailTextLabel?.text = dateFormatter.string(from: date)
    } else {
      cell.detailTextLabel?.text = " "
    }
    return cell
  }

  // Override to support conditional editing of the table view.
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if birthdays.count > indexPath.row {
      let birthday = birthdays[indexPath.row]
      // Delete notification
      if let identifier = birthday.birthdayId {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
      }
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      context.delete(birthday)
      birthdays.remove(at: indexPath.row)
      do {
        try context.save()
      } catch let error {
        print("Could not save because of \(error)")
      }
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
}
