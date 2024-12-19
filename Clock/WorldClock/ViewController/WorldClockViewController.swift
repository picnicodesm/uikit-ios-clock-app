//
//  ViewController.swift
//  Clock
//
//  Created by 김상민 on 2023/08/13.
//

import UIKit
import Combine

class WorldClockViewController: UIViewController {
   
   @IBOutlet weak var tableview: UITableView!
   
   var dataSource: DataSource!
   
   typealias Item = WorldClock
   enum Section {
      case main
   }
   
   var timer = Timer()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      configureView()
      configureDataSource()
      tableview.delegate = self
      timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timeFunction), userInfo: nil, repeats: true)
   }
   
   @objc func timeFunction() {
      var clockArray: [WorldClock] = []
      var snapshot = self.dataSource.snapshot()
      for clockItem in snapshot.itemIdentifiers {
         var item = clockItem
         let cityName = clockItem.cityName
         guard let identifier = TimeZone.knownTimeZoneIdentifiers.filter({ $0.contains(cityName) }).first else { return }
         
         let dateFormatter = DateFormatter()
         dateFormatter.timeZone = TimeZone(identifier: identifier)
         dateFormatter.dateFormat = "H:mm"
         
         let timeString = dateFormatter.string(from: Date())
         item.time = timeString
         clockArray.append(item)
      }
      WorldClock.list = clockArray
        
      snapshot.deleteItems(snapshot.itemIdentifiers)
      snapshot.appendItems(WorldClock.list, toSection: .main)
      dataSource.apply(snapshot, animatingDifferences: false)
   }
   
   private func configureView() {
      self.navigationController?.navigationBar.topItem?.title = "World Clock"
      self.navigationController?.navigationBar.tintColor = .orange
      self.tabBarController?.tabBar.tintColor = .orange
      self.navigationItem.leftBarButtonItem = editButtonItem
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
   }
   
   private func configureDataSource() {
      dataSource = DataSource(tableView: tableview, cellProvider: { tableView, indexPath, item in
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorldClockCell") as? WorldClockCell else { return UITableViewCell() }
         cell.configure(item)
         return cell
      })
      
      var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
      snapshot.appendSections([.main])
      snapshot.appendItems(WorldClock.list, toSection: .main)
      self.dataSource.apply(snapshot)
      
   }
   
   @objc func addButtonTapped() {
      self.isEditing = false
      let sb = UIStoryboard(name: "Cities", bundle: nil)
      guard let vc = sb.instantiateViewController(withIdentifier: "CitiesViewController") as? CitiesViewController else { return }
      vc.delegate = self
      let navigationVC = UINavigationController(rootViewController: vc)
      self.present(navigationVC, animated: true)
   }
   
   override func setEditing(_ editing: Bool, animated: Bool) {
      super.setEditing(editing, animated: animated)
      self.tableview.setEditing(editing, animated: true)
      for cell in self.tableview.visibleCells {
         if let cell = cell as? WorldClockCell {
            cell.timeLabel.isHidden = editing
         }
      }
   }
}


extension WorldClockViewController {
   class DataSource: UITableViewDiffableDataSource<Section, Item> {
      
      override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
            if let identifierToDelete = itemIdentifier(for: indexPath) {
               WorldClock.list = WorldClock.list.filter { $0 != identifierToDelete }
               var snapshot = self.snapshot()
               snapshot.deleteItems([identifierToDelete])
               apply(snapshot)
            }
         }
      }
      
      override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
         guard let sourceIdentifier = itemIdentifier(for: sourceIndexPath) else { return }
         guard sourceIndexPath != destinationIndexPath else { return }
         let destinationIdentifier = itemIdentifier(for: destinationIndexPath)
         var snapshot = self.snapshot()

         if let destinationIdentifier = destinationIdentifier {
            if let sourceIndex = snapshot.indexOfItem(sourceIdentifier), let destinationIndex = snapshot.indexOfItem(destinationIdentifier) {
               let isAfter = destinationIndex > sourceIndex && snapshot.sectionIdentifier(containingItem: sourceIdentifier) == snapshot.sectionIdentifier(containingItem: destinationIdentifier)
               snapshot.deleteItems([sourceIdentifier])
               if isAfter {
                  snapshot.insertItems([sourceIdentifier], afterItem: destinationIdentifier)
               } else {
                  snapshot.insertItems([sourceIdentifier], beforeItem: destinationIdentifier)
               }
            }
         } else { // It doesn't need it because this tableview has only one section
            let destinationSectionIdentifier = snapshot.sectionIdentifiers[destinationIndexPath.section]
            snapshot.deleteItems([sourceIdentifier])
            snapshot.appendItems([sourceIdentifier], toSection: destinationSectionIdentifier)
         }
         apply(snapshot, animatingDifferences: false)
      }
   }
}

extension WorldClockViewController: UITableViewDelegate {
   
   func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
      super.setEditing(false, animated: true)
   }
   
   func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
      super.setEditing(true, animated: true)
   }
   
}


extension WorldClockViewController: WorldClockDelegate {
   func worldClock(dataReceived data: WorldClock) {
      if WorldClock.list.contains(data) { return }
      
      WorldClock.list.append(data)
      var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
      snapshot.appendSections([.main])
      snapshot.appendItems(WorldClock.list)
      dataSource.apply(snapshot, animatingDifferences: false)
   }
}


