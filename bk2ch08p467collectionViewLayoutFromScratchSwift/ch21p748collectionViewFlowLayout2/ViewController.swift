

import UIKit

/*
I've provided two independent versions of this example, one Swift, one Objective-C,
because the Swift version is prohibitively slow (especially on a device)
*/

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}
extension CGSize {
    init(_ width:CGFloat, _ height:CGFloat) {
        self.init(width:width, height:height)
    }
}
extension CGPoint {
    init(_ x:CGFloat, _ y:CGFloat) {
        self.init(x:x, y:y)
    }
}
extension CGVector {
    init (_ dx:CGFloat, _ dy:CGFloat) {
        self.init(dx:dx, dy:dy)
    }
}



class ViewController : UICollectionViewController {
    
    struct Section {
        var sectionName : String
        var rowData : [String]
    }
    var sections : [Section]!

    lazy var modelCell : Cell = { // load lazily from nib
        () -> Cell in
        let arr = UINib(nibName:"Cell", bundle:nil).instantiate(withOwner:nil)
        return arr[0] as! Cell
        }()

    override func viewDidLoad() {
        let s = try! String(
            contentsOfFile: Bundle.main.path(
                forResource: "states", ofType: "txt")!)
        let states = s.components(separatedBy:"\n")
        let d = Dictionary(grouping: states) {String($0.prefix(1))}
        self.sections = Array(d).sorted{$0.key < $1.key}.map {
            Section(sectionName: $0.key, rowData: $0.value)
        }

        self.navigationItem.title = "States"
        let bb = UIBarButtonItem(title:"Push", style:.plain, target:self, action:#selector(doPush))
        self.navigationItem.rightBarButtonItem = bb
        self.collectionView!.backgroundColor = .white
        self.collectionView!.allowsMultipleSelection = true
        
        // register cell, comes from a nib even though we are using a storyboard
        self.collectionView!.register(UINib(nibName:"Cell", bundle:nil), forCellWithReuseIdentifier:"Cell")
        // register headers (for the other view controller!)
        self.collectionView!.register(UICollectionReusableView.self,
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader,
            withReuseIdentifier:"Header")

        // no supplementary views or anything
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections[section].rowData.count
    }

    
    // headers
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var v : UICollectionReusableView! = nil
        if kind == UICollectionElementKindSectionHeader {
            v = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier:"Header", for: indexPath)
            if v.subviews.count == 0 {
                let lab = UILabel() // we will size it later
                v.addSubview(lab)
                lab.textAlignment = .center
                // look nicer
                lab.font = UIFont(name:"Georgia-Bold", size:22)
                lab.backgroundColor = .lightGray
                lab.layer.cornerRadius = 8
                lab.layer.borderWidth = 2
                lab.layer.masksToBounds = true // has to be added for iOS 8 label
                lab.layer.borderColor = UIColor.black.cgColor
                lab.translatesAutoresizingMaskIntoConstraints = false
                v.addConstraints(
                    NSLayoutConstraint.constraints(withVisualFormat:"H:|-10-[lab(35)]",
                        metrics:nil, views:["lab":lab]))
                v.addConstraints(
                    NSLayoutConstraint.constraints(withVisualFormat:"V:[lab(30)]-5-|",
                        metrics:nil, views:["lab":lab]))
            }
            let lab = v.subviews[0] as! UILabel
            lab.text = self.sections[indexPath.section].sectionName
        }
        return v
    }
    
    // cells
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Cell", for: indexPath) as! Cell
        if cell.lab.text == "Label" { // new cell
            cell.layer.cornerRadius = 8
            cell.layer.borderWidth = 2
            
            cell.backgroundColor = .gray
            
            /*
            // checkmark in top left corner when selected
            let r = UIGraphicsImageRenderer(size:cell.bounds.size)
            let im = r.image {
                ctx in let con = ctx.cgContext
                let shadow = NSShadow()
                shadow.shadowColor = UIColor.darkGray
                shadow.shadowOffset = CGSize(2,2)
                shadow.shadowBlurRadius = 4
                let check2 =
                    NSAttributedString(string:"\u{2714}", attributes:[
                        NSFontAttributeName: UIFont(name:"ZapfDingbatsITC", size:24)!,
                        NSForegroundColorAttributeName: UIColor.green,
                        NSStrokeColorAttributeName: UIColor.red,
                        NSStrokeWidthAttributeName: -4,
                        NSShadowAttributeName: shadow
                        ])
                con.scaleBy(x:1.1, y:1)
                check2.draw(at:CGPoint(2,0))
            }
 */
            
            //            UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
            //            let con = UIGraphicsGetCurrentContext()!
            //            let shadow = NSShadow()
            //            shadow.shadowColor = UIColor.darkGray()
            //            shadow.shadowOffset = CGSize(2,2)
            //            shadow.shadowBlurRadius = 4
            //            let check2 =
            //            AttributedString(string:"\u{2714}", attributes:[
            //                NSFontAttributeName: UIFont(name:"ZapfDingbatsITC", size:24)!,
            //                NSForegroundColorAttributeName: UIColor.green(),
            //                NSStrokeColorAttributeName: UIColor.red(),
            //                NSStrokeWidthAttributeName: -4,
            //                NSShadowAttributeName: shadow
            //                ])
            //            con.scale(x:1.1, y:1)
            //            check2.draw(at:CGPoint(2,0))
            //            let im = UIGraphicsGetImageFromCurrentImageContext()!
            //            UIGraphicsEndImageContext()

            // let iv = UIImageView(image:nil, highlightedImage:im)
//            iv.isUserInteractionEnabled = false
//            cell.addSubview(iv)
        }
        cell.lab.text = self.sections[indexPath.section].rowData[indexPath.row]
        var stateName = cell.lab.text!
        // flag in background! very cute
        stateName = stateName.lowercased()
        stateName = stateName.replacingOccurrences(of:" ", with:"")
        stateName = "flag_\(stateName).gif"
        let im = UIImage(named: stateName)
        let iv = UIImageView(image:im)
        iv.contentMode = .scaleAspectFit
        cell.backgroundView = iv
        
        return cell
    }
    
    @objc func doPush(_ sender: Any?) {
        self.performSegue(withIdentifier:"push", sender: self)
    }
    
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.modelCell.lab.text = self.sections[indexPath.section].rowData[indexPath.row]
        var sz = self.modelCell.container.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        sz.width = ceil(sz.width); sz.height = ceil(sz.height)
        return sz
    }
}
