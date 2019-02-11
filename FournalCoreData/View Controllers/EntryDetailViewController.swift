//
//  EntryDetailViewController.swift
//  FournalCoreData
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var entryController: EntryController?
    var entry: Entry? {
        didSet { updateViews() }
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextTextView: UITextView!
    

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    
    // MARK: - Update views
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        if let entry = entry {
            title = entry.title
            titleTextField.text = entry.title
            bodyTextTextView.text = entry.bodyText
        } else {
            title = "Create Entry"
        }
    }
    

    // MARK: - Actions
    
    @IBAction func saveBarButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text,
            !title.isEmpty,
            let bodyText = bodyTextTextView.text else { return }
        
        if let entry = entry {
            entryController?.update(entry: entry, title: title, bodyText: bodyText)
        } else {
            entryController?.createEntry(with: title, bodyText: bodyText)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}
