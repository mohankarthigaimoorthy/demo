//
//  addNoteViewController.swift
//  demoNote
//
//  Created by Imcrinox Mac on 29/12/1444 AH.
//

import UIKit

class addNoteViewController: UIViewController {

    @IBOutlet weak var noteBGView: UIView!
    @IBOutlet weak var noteLBl: UILabel!
    @IBOutlet weak var noteTxtView: UITextView!
    @IBOutlet weak var priorityLBl: UILabel!
    @IBOutlet weak var LowpriorityView: UIView!
    @IBOutlet weak var MediumPriorityView: UIView!
    @IBOutlet weak var HighpriorityView: UIView!
    @IBOutlet weak var addNoteBtn: UIButton!
  
    private var keyboarShown: Bool = false
    private var noteViewAlreadyAnimated: Bool = false
    private var noteBgviewOriginY: CGFloat = 0
    private var noteBGViewOriginYWithKeyboard: CGFloat = 0
    private var allowTapBGToClose: Bool? = true
    
    class var identifier: String { return String(describing: self)}
    
    var saveNote: ((_ noteText: String, _ priorityColor: UIColor) -> Void)?
    
    private var savedNote: String?
    private var selectedPriority: UIColor?
    
    func setNotes(text: String = "", priorityColor: UIColor = .clear) {
        savedNote = text
        selectedPriority = priorityColor
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func initView(){
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onBaseTapOnly))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.noteBGView.backgroundColor = .gray
        self.noteBGView.layer.cornerRadius = 12
        self.noteBGView.clipsToBounds = true
        
        self.noteLBl.text = "Notes"
        self.noteLBl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        self.noteLBl.textColor = .black
        
        self.noteTxtView.text = savedNote
        self.noteTxtView.clipsToBounds = true
        self.noteTxtView.layer.borderColor = UIColor.white.cgColor
        self.noteTxtView.backgroundColor = .lightGray
        self.noteTxtView.layer.borderWidth = 2.0
        self.noteTxtView.layer.cornerRadius = 12
        self.noteTxtView.autocorrectionType = .no
        self.noteTxtView.font = UIFont.systemFont(ofSize: 14)
        self.noteTxtView.tintColor = .white
        self.noteTxtView.textColor = .white
        self.noteTxtView.contentInset = UIEdgeInsets(top: 0, left: 1, bottom: 2, right: 1)
        
        self.priorityLBl.text = "Priority"
        self.priorityLBl.textColor = .white
        self.priorityLBl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        LowpriorityView.backgroundColor = .green
        MediumPriorityView.backgroundColor = .orange
        HighpriorityView.backgroundColor = .red
        
        let priorityViews = [LowpriorityView, MediumPriorityView, HighpriorityView]
        
        for i in 0 ..< priorityViews.count {
            guard let priorityView = priorityViews[i] else {return}
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(selectedPriority(_:)))
            tapGes.numberOfTapsRequired = 1
            priorityView.tag = i
            priorityView.addGestureRecognizer(tapGes)
            
            priorityView.clipsToBounds = true
            priorityView.layer.cornerRadius = 15
            priorityView.layer.borderColor = UIColor.white.cgColor
        }
        setselectedPriority()
        
        self.addNoteBtn.setTitleColor(.white, for: .normal)
        self.addNoteBtn.setTitle("Add/Update Note", for: .normal)
        self.addNoteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.addNoteBtn.backgroundColor  = .tintColor
        self.addNoteBtn.layer.cornerRadius = 22.5
        self.addNoteBtn.addTarget(self, action: #selector(self.addNoteButtonTapped), for: .touchUpInside)
    }
    
    func setselectedPriority() {
        guard let selectedProiority = selectedPriority else { return }
        switch selectedProiority {
        case .green :
            priorityLBl.text = "Low Priority"
            LowpriorityView.layer.borderWidth = 2
        case .orange:
            priorityLBl.text = "Medium Priority"
            MediumPriorityView.layer.borderWidth = 2
        case .red:
            priorityLBl.text = "Hight Priority"
            HighpriorityView.layer.borderWidth = 2
        default:
            break
        }
    }
    
    @objc func selectedPriority(_ sender: UITapGestureRecognizer) {
        if sender.view!.tag == 0 {
            selectedPriority = LowpriorityView.backgroundColor
            priorityLBl.text = "Low Priority"
            LowpriorityView.layer.borderWidth = 2
            MediumPriorityView.layer.borderWidth = 0
            HighpriorityView.layer.borderWidth = 0
        } else if sender.view!.tag == 1 {
            selectedPriority = MediumPriorityView.backgroundColor
            priorityLBl.text = "Medium Priority"
            LowpriorityView.layer.borderWidth = 0
            MediumPriorityView.layer.borderWidth = 2
            HighpriorityView.layer.borderWidth = 0
        } else if sender.view!.tag == 2 {
            selectedPriority = HighpriorityView.backgroundColor
            priorityLBl.text = "High Priority"
            LowpriorityView.layer.borderWidth = 0
            MediumPriorityView.layer.borderWidth = 0
            HighpriorityView.layer.borderWidth = 2
        }
    }
    
    @objc func addNoteButtonTapped() {
        self.dismissKeyboard()
        
        if !noteTxtView.text.trimmingCharacters(in: .whitespaces).isEmpty, selectedPriority != nil {
            saveNote?(noteTxtView.text, selectedPriority!)
            DispatchQueue.main.async {
                self.closeAnim()
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let beginFrameValue = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)!
        let beginFrame = beginFrameValue.cgRectValue
        let endFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!
        let endFrame = endFrameValue.cgRectValue
        
        if beginFrame.equalTo(endFrame) {
            return
        }
        
        if let KeyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            self.keyboarShown = true
            self.moveViewForKeyboard(frame: KeyboardFrame)
        }
    }
    
    func moveViewForKeyboard(frame: NSValue) {
        let KeyboardRectangle = frame.cgRectValue
        let distance = self.noteBGView.frame.maxY - KeyboardRectangle.minY
        if distance >= -8 {
            DispatchQueue.main.async{
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    let bottomSafeAreaPadding = self.view?.window?.safeAreaInsets.bottom
                    let bottomPadding: CGFloat = -45 + (bottomSafeAreaPadding ?? 0.0)
                    self.noteBGView.frame.origin.y -= distance - bottomPadding
                    self.noteBGViewOriginYWithKeyboard = self.noteBGView.frame.origin.y
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboarShown = false
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.noteBGView.frame.origin.y = self.noteBgviewOriginY
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func closeAnim() {
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            
            self.noteBGView.frame = CGRect(x: self.view.frame.width
                                           / 2 - self.noteBGView.frame.width / 2, y: self.view.frame.height + self.noteBGView.frame.height, width: self.noteBGView.frame.width, height: self.noteBGView.frame.height)
            self.noteBGView.superview?.layoutIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.noteViewAlreadyAnimated {
            self.noteBGView.frame = CGRect(x: self.view.frame.width / 2 - self.noteBGView.frame.width / 2, y: self.view.frame.height + self.noteBGView.frame.height, width: self.noteBGView.frame.width, height: self.noteBGView.frame.height
            )
            self.noteBGView.superview?.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.noteBGView.frame = CGRect(x: self.view.frame.width / 2 - self.noteBGView.frame.width
                                               / 2, y: self.view.frame.height / 2 - self.noteBGView.frame.height / 2, width: self.noteBGView.frame.width, height: self.noteBGView.frame.height)
                self.noteBGView.superview?.layoutIfNeeded()
            })
            
            self.noteBgviewOriginY = self.noteBGView.frame.origin.y
            self.noteViewAlreadyAnimated = true
        }
        self.noteBGView.frame.origin.y = self.keyboarShown ? self.noteBGViewOriginYWithKeyboard : self.noteBgviewOriginY
    }
}

extension addNoteViewController: UIGestureRecognizerDelegate {
    
    @objc func onBaseTapOnly(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let allowTapBGToClose = allowTapBGToClose, allowTapBGToClose {
                if self.keyboarShown {
                    self.dismissKeyboard()
                }
                else {
                    DispatchQueue.main.async {
                        self.closeAnim()
                    }
                }
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.noteBGView))! {
            return self.keyboarShown
        }
        return true
    }
}
