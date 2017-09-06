

import UIKit

class MySearchController : UISearchController {
//    override var prefersStatusBarHidden : Bool {
//        return true
//    }
    
    // failed experiment
    
//    override init(searchResultsController: UIViewController?) {
//        super.init(searchResultsController: searchResultsController)
//        self.navigationItem.title = "Search"
//    }
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}

class RootViewController : UITableViewController, UISearchBarDelegate {
    struct Section {
        var sectionName : String
        var rowData : [String]
    }
    var sections : [Section]!

    var searcher : UISearchController!
    
    // looks better _with_ the status bar
//    override var prefersStatusBarHidden : Bool {
//        return true
//    }
    
    override func viewDidLoad() {
        let s = try! String(
            contentsOfFile: Bundle.main.path(
                forResource: "states", ofType: "txt")!)
        let states = s.components(separatedBy:"\n")
        let d = Dictionary(grouping: states) {String($0.prefix(1))}
        self.sections = Array(d).sorted{$0.key < $1.key}.map {
            Section(sectionName: $0.key, rowData: $0.value)
        }

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Header")
        
        self.tableView.sectionIndexColor = .white
        self.tableView.sectionIndexBackgroundColor = .red
        // self.tableView.sectionIndexTrackingBackgroundColor = .blue
        self.tableView.backgroundColor = .yellow // but the search bar covers that
        
        
        let src = SearchResultsController(data: self.sections)
        let searcher = MySearchController(searchResultsController: src)
        self.searcher = searcher
        // specify who the search controller should notify when the search bar changes
        searcher.searchResultsUpdater = src
        // put the search controller's search bar into the interface
        let b = searcher.searchBar
        b.sizeToFit()
        b.autocapitalizationType = .none
        
        // how to to put search bar into navigation bar
        var which : Int { return 2 }
        switch which {
        case 1:
            // this does still work in iOS 11
            self.navigationItem.titleView = b // *
            searcher.hidesNavigationBarDuringPresentation = false // *
            self.definesPresentationContext = true // *
        case 2:
            if #available(iOS 11.0, *) {
                // use new "stretchable" navigation bar
                
                // if true (default), user doesn't see search bar unless pulls down
                // self.navigationItem.hidesSearchBarWhenScrolling = false

                self.navigationItem.searchController = searcher
                searcher.hidesNavigationBarDuringPresentation = true // crucial, it seems
                self.definesPresentationContext = true // this doesn't seem to matter
                self.navigationItem.title = "States" // looks better to have a title
                // try with and without this
                self.navigationController!.navigationBar.prefersLargeTitles = true
                
                // one point of this architecture: there's room for other stuff in navbar
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: nil, action: nil)
                
                // hey, check this out
                b.scopeButtonTitles = ["Starts", "Contains"]
                b.showsScopeBar = false
                b.delegate = src
            } else {
                fatalError("don't do this except in iOS 11")
            }
        default: break
        }
        
        // searcher.delegate = self
        // not sure what this was for, but it was ruining everything
        // searcher.modalPresentationStyle = .popover
        // oh, okay, I see what it was for: it was intended as iPad only
        // but it still ruins everything, alas
        
        self.tableView.reloadData()
        self.tableView.scrollToRow(at:
            IndexPath(row: 0, section: 0),
            at:.top, animated:false)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].rowData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath)
        let s = self.sections[indexPath.section].rowData[indexPath.row]
        cell.textLabel!.text = s
        
        // this part is not in the book, it's just for fun
        var stateName = s
        stateName = stateName.lowercased()
        stateName = stateName.replacingOccurrences(of:" ", with:"")
        stateName = "flag_\(stateName).gif"
        let im = UIImage(named: stateName)
        cell.imageView!.image = im
        
        return cell
    }
    
    /*
    
    override func tableView(_ tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
    return self.sectionNames[section]
    }
    
    */
    // this is more "interesting"
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let h = tableView
            .dequeueReusableHeaderFooterView(withIdentifier:"Header")!
        if h.viewWithTag(1) == nil {
            
            h.backgroundView = UIView()
            h.backgroundView?.backgroundColor = .black
            let lab = UILabel()
            lab.tag = 1
            lab.font = UIFont(name:"Georgia-Bold", size:22)
            lab.textColor = .green
            lab.backgroundColor = .clear
            h.contentView.addSubview(lab)
            let v = UIImageView()
            v.tag = 2
            v.backgroundColor = .black
            v.image = UIImage(named:"us_flag_small.gif")
            h.contentView.addSubview(v)
            lab.translatesAutoresizingMaskIntoConstraints = false
            v.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                NSLayoutConstraint.constraints(withVisualFormat:
                    "H:|-5-[lab(25)]-10-[v(40)]",
                    metrics:nil, views:["v":v, "lab":lab]),
                NSLayoutConstraint.constraints(withVisualFormat:
                    "V:|[v]|",
                    metrics:nil, views:["v":v]),
                NSLayoutConstraint.constraints(withVisualFormat:
                    "V:|[lab]|",
                    metrics:nil, views:["lab":lab])
                ].flatMap{$0})
        }
        let lab = h.contentView.viewWithTag(1) as! UILabel
        lab.text = self.sections[section].sectionName
        return h
        
    }
    
    /*
    override func tableView(_ tableView: UITableView!, willDisplayHeaderView view: UIView!, forSection section: Int) {
    println(view) // prove we are reusing header views
    }
    */
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sections.map{$0.sectionName}
    }
}

extension RootViewController : UISearchControllerDelegate {
}
