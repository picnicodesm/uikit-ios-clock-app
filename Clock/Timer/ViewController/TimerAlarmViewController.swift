//
//  TimerAlarmViewController.swift
//  Clock
//
//  Created by 김상민 on 2023/08/28.
//

import UIKit

class TimerAlarmViewController: UIViewController {
    
    var selectedCell: UITableViewCell? = nil
    var selectedRing: String? = nil
    var delegate: TimerDelegate?
    var tableView: UITableView = {
        var tableView = UITableView(frame: CGRect(), style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RingCell")
        
        return tableView
    }()
    
    //MARK: - DataSource
    var dataSource: DataSource!
    typealias Item = String
    enum Section: Int {
        case main
        case noRing
    }
    let rings: [String] = RingModel.rings
    let noRing: [String] = RingModel.noRing
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationButtons()
        setTableView()
        configureDataSource()
    }
    
    private func setNavigationButtons() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Set", style: .plain, target: self, action: #selector(setButtonTapped))
    }
    
    private func setTableView() {
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { tableView, indexPath, item in
            let sectionKind = Section(rawValue: indexPath.section)
            let cell = UITableViewCell(style: .default, reuseIdentifier: "RingCell")
            var config = cell.defaultContentConfiguration()
            config.text = item
            
            if item.contains(self.selectedRing!) {
                config.image = UIImage(systemName: "checkmark")?.withTintColor(.orange, renderingMode: .alwaysOriginal)
                self.selectedCell = cell
                self.selectedRing = item
            } else {
                config.image = UIImage(systemName: "checkmark")?.withTintColor(.clear, renderingMode: .alwaysOriginal)
            }
                cell.contentConfiguration = config
            
            if sectionKind == .main && indexPath.item == self.rings.count - 1 {
                cell.accessoryType = .disclosureIndicator
            }

            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main, .noRing])
        snapshot.appendItems(rings, toSection: .main)
        snapshot.appendItems(noRing, toSection: .noRing)
        dataSource.apply(snapshot)
    }
   
    @objc func setButtonTapped() {
        guard let selectedCellConfig = selectedCell?.contentConfiguration as? UIListContentConfiguration    else { return }
        delegate?.timer(ring: selectedCellConfig.text!)
        dismiss(animated: true)
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
}

extension TimerAlarmViewController {
    class DataSource: UITableViewDiffableDataSource<Section, Item> {}
}

extension TimerAlarmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        if indexPath.item == rings.count - 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if let selectedCell = selectedCell {
            if var selectedCellConfig = selectedCell.contentConfiguration as? UIListContentConfiguration {
                selectedCellConfig.image = UIImage(systemName: "checkmark")?.withTintColor(.clear, renderingMode: .alwaysOriginal)
                selectedCell.contentConfiguration = selectedCellConfig
            }
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if var cellConfig = cell.contentConfiguration as? UIListContentConfiguration {
            cellConfig.image = UIImage(systemName: "checkmark")?.withTintColor(.orange, renderingMode: .alwaysOriginal)
            self.selectedRing = cellConfig.text
            cell.contentConfiguration = cellConfig
            self.selectedCell = cell
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
