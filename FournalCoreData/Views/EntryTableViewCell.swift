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
    
    
    // MARK: - Outlets

    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var bodyTextLabel: UILabel!
    @IBOutlet weak var titleAndTimestampSV: UIStackView!
    
    
    // MARK: - Update views
    
    private func updateViews() {
        guard let entry = entry,
            let timestamp = entry.timestamp else { return }
        
        titleTextLabel.text = entry.title
        bodyTextLabel.text = entry.bodyText
        timestampLabel.text = timestamp.dateString()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            titleAndTimestampSV.axis = .vertical
        } else {
            titleAndTimestampSV.axis = .horizontal
        }
    }

}


extension Date {
    func dateString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
}
