//
//  SoundViewController.swift
//  Clock
//
//  Created by 김상민 on 2023/08/18.
//

import UIKit

class SoundViewController: UIViewController {
    
    var selectedCell: UITableViewCell? = nil
    var selectedSound: String? = nil
    var delegate: AlarmDelegate?
    var dataSource: DataSource!
    typealias Item = String
    enum Section: Int, CaseIterable {
        case vibration
        case songs
        case ringtones
        case noSound
    }
    var sounds: [[String]] = AlarmModel.sounds
    
    var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SoundCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sound"
        tableView.delegate = self
        setTableView()
        configureDataSource()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        makeSoundText()
    }
    
    private func setTableView() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SoundCell") else { return UITableViewCell() }
            var config = cell.defaultContentConfiguration()
            config.text = item
            
            let sectionKind = Section(rawValue: indexPath.section)
            switch sectionKind {
            case .vibration:
                cell.accessoryType = .disclosureIndicator
            case .songs: fallthrough
            case .ringtones: fallthrough
            case .noSound:
                config.image = UIImage(systemName: "checkmark")?.withTintColor(.clear, renderingMode: .alwaysOriginal)
            default: break
            }
            
            if item == "Pick a Song" || item == "Classic" {
                cell.accessoryType = .disclosureIndicator
            } else {
                // 왜 .none을 안해주면 무작위로 indicator가 생기는거지...
                cell.accessoryType = .none
            }

            if self.selectedSound == item || (self.selectedSound == "Radar" && item == "Radar (Default)")  {
                config.image = UIImage(systemName: "checkmark")?.withTintColor(.orange, renderingMode: .alwaysOriginal)
                self.selectedCell = cell
            }
            cell.tintColor = .orange
            cell.contentConfiguration = config
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(sounds[0], toSection: .vibration)
        snapshot.appendItems(sounds[1], toSection: .songs)
        snapshot.appendItems(sounds[2], toSection: .ringtones)
        snapshot.appendItems(sounds[3], toSection: .noSound)
        dataSource.apply(snapshot)
    }
    
    private func makeSoundText() {
        guard let cell = selectedCell else { return }
        if let config = cell.contentConfiguration as? UIListContentConfiguration {
            if var text = config.text {
                if text == "Radar (Default)" {
                    text = "Radar"
                }
                delegate?.setAlarm(sound: text)
            }
        }
    }
}

extension SoundViewController {
    class DataSource: UITableViewDiffableDataSource<Section, Item> {
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            switch Section(rawValue: section) {
            case .songs: return "SONGS"
            case .ringtones: return "RINGTONES"
            case .vibration: fallthrough
            case .noSound: return nil
            default: return nil
                
            }
        }
    }
}

extension SoundViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionKind = Section(rawValue: indexPath.section)
        
        switch sectionKind {
        case .vibration:
            return
        case .songs:
            fallthrough
        case .ringtones:
            if indexPath.item == self.sounds[indexPath.section].count - 1 { return }
            fallthrough
        case .noSound:
            if let selectedCell = selectedCell {
                if var selectedCellConfig = selectedCell.contentConfiguration as? UIListContentConfiguration {
                    selectedCellConfig.image = UIImage(systemName: "checkmark")?.withTintColor(.clear, renderingMode: .alwaysOriginal)
                    selectedCell.contentConfiguration = selectedCellConfig
                }
            }
            
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            if var cellConfig = cell.contentConfiguration as? UIListContentConfiguration {
                cellConfig.image = UIImage(systemName: "checkmark")?.withTintColor(.orange, renderingMode: .alwaysOriginal)
                cell.contentConfiguration = cellConfig
                self.selectedCell = cell
                self.selectedSound = cellConfig.text
            }
        default:
            return
        }
    }
}
