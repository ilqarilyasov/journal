//
//  EntryTableViewCell.swift
//  FournalCoreData
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var entry: Entry? {
        didSet { updateViews() }
    }
    
    
    // MARK: - Helper
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - Outlets

    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    
    // MARK: - Update views
    
    private func updateViews() {
        guard let entry = entry,
            let date = entry.timestamp else { return }
        
        titleTextLabel.text = entry.title
        bodyTextLabel.text = entry.bodyText
        timestampLabel.text = formatter.string(from: date)
    }

}
