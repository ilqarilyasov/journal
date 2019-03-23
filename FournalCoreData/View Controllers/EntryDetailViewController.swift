//
//  EntryDetailViewController.swift
//  FournalCoreData
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {
    
    // State restoration
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(entry, forKey: "Entry")
        coder.encode(titleTextField.text, forKey: "titleTextField")
        coder.encode(bodyTextTextView.text, forKey: "bodyTextTextView")
        coder.encode(moodSegmentedControl.selectedSegmentIndex, forKey: "moodSegmentedControl")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let resoredEntry = coder.decodeObject(forKey: "Entry") as? Entry {
            self.entry = resoredEntry
        }
        
        if let title = coder.decodeObject(forKey: "titleTextField") as? String {
            self.titleTextField.text = title
        }
        
        if let body = coder.decodeObject(forKey: "bodyTextTextView") as? String {
            self.bodyTextTextView.text = body
        }
        
        if let index = coder.decodeObject(forKey: "moodSegmentedControl") as? Int {
            self.moodSegmentedControl.selectedSegmentIndex = index
        }
    }
    
    override func applicationFinishedRestoringState() {
        self.titleTextField.text = titleTextField.text
        self.bodyTextTextView.text = bodyTextTextView.text
        self.moodSegmentedControl.selectedSegmentIndex = moodSegmentedControl.selectedSegmentIndex
    }
    
    // MARK: - Properties
    
    var entryController: EntryController?
    var entry: Entry? {
        didSet { updateViews() }
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextTextView: UITextView!
    @IBOutlet weak var moodSegmentedControl: UISegmentedControl!
    

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
            
            guard let moodString = entry.mood,
                let mood = Mood(rawValue: moodString),
                let moodIndex = Mood.allCases.index(of: mood) else { return }
            
            moodSegmentedControl.selectedSegmentIndex = moodIndex
        } else {
            title = "Create Entry"
            moodSegmentedControl.selectedSegmentIndex = 1
        }
    }
    

    // MARK: - Actions
    
    @IBAction func saveBarButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty,
            let bodyText = bodyTextTextView.text else { return }
        
        let index = moodSegmentedControl.selectedSegmentIndex
        let mood = Mood.allCases[index]
        
        if let entry = entry {
            entryController?.update(entry: entry, title: title, bodyText: bodyText, mood: mood)
        } else {
            entryController?.createEntry(with: title, bodyText: bodyText, mood: mood)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
//    override func updateViewConstraints() {
//        super.updateViewConstraints()
//        
//        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
//            let label = UILabel()
//            label.frame = CGRect(x: 0, y: 0, width: 400, height: 50)
//            label.font = UIFont.boldSystemFont(ofSize: 16)
//            label.backgroundColor = .clear
//            label.textColor = .black
//            label.numberOfLines = 2
//            label.text = title
//            label.adjustsFontSizeToFitWidth = true
//            navigationItem.titleView = label
//        }
//    }
    
}
