//
//  NoteCell.swift
//  demoNote
//
//  Created by Imcrinox Mac on 29/12/1444 AH.
//

import UIKit

class NoteCell: UITableViewCell {

    @IBOutlet weak var BGView: UIView!
    @IBOutlet weak var contentTxtLbl: UILabel!
    @IBOutlet weak var priorityview: UIView!
    
    class var identifier: String { return String(describing: self)}
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureView()

    }

    func configureView()
    {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.BGView.backgroundColor = .darkGray
        self.BGView.layer.cornerRadius = 8
        
        contentTxtLbl.textColor = .white
        priorityview.layer.cornerRadius = 4
    }
}
