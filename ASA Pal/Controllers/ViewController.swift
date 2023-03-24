//
//  ViewController.swift
//  ASA Pal
//
//  Created by Vakul Saini on 15/11/21.
//

import UIKit
import Alamofire

enum TabType: Int {
    case UserInfo = 0
    case TransactionInfo
}

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollViewMain: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var noRecordsView: DesignableView!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var tblViewTransactions: UITableView!
    @IBOutlet weak var noRecordsViewTransactions: DesignableView!
    
    var dict: [String:String] = [:]
    var dataModels: [DataModel] = []
    var tabType: TabType = .UserInfo
    
    var transactions: [ASATransaction] = []
    var transactionsViewModel: ASATransactionViewModel?
    
    var loader: ASALoader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupTable()
        dict = AppDelegate.shared.params
        syncModels()
        
        reloadTable()
        noRecordsView.isHidden = true
        tblView.isHidden = false
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        //            self.hideShowNoData()
        //        }
        
        loader = ASALoader.view()
        scrollViewMain.delegate = self
        scrollViewMain.showsHorizontalScrollIndicator = false
        setupTableTransactions()
        setUpTransactionViewModel()
        hideShowNoDataTransactions()
        
        
        callPersonalInfoAPI()
    }
    
    
    func syncModels() {
        dataModels.removeAll()
        if let value = dict["First Name"] {
            dataModels.append(DataModel(title: "First Name", desc: value))
        }
        if let value = dict["Last Name"] {
            dataModels.append(DataModel(title: "Last Name", desc: value))
        }
        if let value = dict["Email"] {
            dataModels.append(DataModel(title: "Email", desc: value))
        }
        if let value = dict["AsaConsumerCode"] {
            dataModels.append(DataModel(title: "ASA Consumer ID", desc: value))
        }
        if let value = dict["AsaFintechCode"] {
            dataModels.append(DataModel(title: "ASA Fintech ID", desc: value))
        }
        if let value = dict["FintechName"] {
            let decoded_value = value.replacingOccurrences(of: "+", with: " ")
            dataModels.append(DataModel(title: "Fintech Name", desc: decoded_value))
        }
        
        for (key, value) in dict {
            if dataModels.filter({ $0.desc == value.replacingOccurrences(of: "+", with: " ") }).first != nil {
                // Already exists
                continue
            }
            
            dataModels.append(DataModel(title: key.capitalized, desc: value))
        }
    }
    
    
    func callPersonalInfoAPI() {
        
        guard let consumerCode = dict["AsaConsumerCode"] else { return }
        
        
        // Check if alreday have details for this consumer
        if let details = AppDelegate.shared.getDetailsForConsumerCode(consumerCode: consumerCode) {
            self.dict.merge(details) {(current, _) in current}
            self.syncModels()
            self.reloadTable()
            return
        }
        
        
        loader?.show(inView: self.view)
        loader?.loaderLabel.isHidden = true
        var headers = HTTPHeaders()
        headers.appendCommonHeaders()
        headers.add(name: "asaConsumerCode", value: consumerCode)
        
        // let url = "https://asaconectgatewayuat.azure-api.net/consumer"
        let url = APIStaticData.BASE_URL + "/consumer"
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).response { response in
            print("->", response)
            switch response.result{
            case .success(let data):
                let strStatus = String.init(data: data!, encoding: String.Encoding.init(rawValue: 0))
                print("->>", strStatus!)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    DispatchQueue.main.async {
                        print("JSONSerialization", json)
                        let jsonDict = json as? [String: Any] ?? [:]
                        let data = jsonDict["data"] as? [String: Any] ?? [:]
                        let firstName = data["firstName"] as? String ?? ""
                        let lastName = data["lastName"] as? String ?? ""
                        let emailID = data["emailAddress"] as? String ?? ""
                                                    
                        
                        /*let consumerID = ((json as AnyObject)["data"] as! AnyObject)["asaConsumerCode"] as! Int
                        let fintechID = (((((json as AnyObject)["data"] as! AnyObject).object(forKey: "consumerFiAccountDetails") as! NSArray)[0] as! NSDictionary).object(forKey: "consumerFIAccountID") as! String)
                        let fintechName = (((((json as AnyObject)["data"] as! AnyObject).object(forKey: "consumerFiAccountDetails") as! NSArray)[0] as! NSDictionary).object(forKey: "description") as! String)*/
                        
                        if !firstName.isEmpty && !lastName.isEmpty && !emailID.isEmpty {
                            let details = ["First Name": firstName,
                                       "Last Name": lastName,
                                       "Email": emailID]
                            AppDelegate.shared.saveDetailsForConsumerCode(details: details, consumerCode: consumerCode)
                            self.dict.merge(details) {(current, _) in current}
                        }
                        
                        
                        /*self.arrUserInfo.add(["heading":"First Name", "value":firstName])
                        self.arrUserInfo.add(["heading":"Last Name", "value":lastName])
                        self.arrUserInfo.add(["heading":"Email ID", "value":emailID])
                        self.arrUserInfo.add(["heading":"ASA Consumer ID", "value":"\(consumerID)"])
                        self.arrUserInfo.add(["heading":"ASA Fintech ID", "value":fintechID])
                        self.arrUserInfo.add(["heading":"Fintech Name", "value":fintechName])*/
                        
                        self.syncModels()
                        self.reloadTable()
                    }
                } catch {}
                break
            case .failure(_):
                break
            }
            
            self.loader?.hide()
        }
    }
    
}


// MARK:- Actions
extension ViewController {
    @IBAction func refreshAction(_ sender: UIButton) {
        if tabType == .UserInfo {
            // Refresh User info
            // Do nothing
        }
        else {
            // Refresh Transactions
            refreshTransactions()
        }
    }
    
    @IBAction func pageControlAction(_ sender: UIPageControl) {
        let page = sender.currentPage
        let pointX = scrollViewMain.bounds.width * CGFloat(page)
        scrollViewMain.setContentOffset(CGPoint(x: pointX, y: 0), animated: true)
        if page == 1 {
            hideShowNoDataTransactions()
            tabType = .TransactionInfo
            if transactions.count == 0 {
                refreshTransactions()
            }
        }
        else {
            hideShowNoData()
            tabType = .UserInfo
        }
    }
}


// MARK:- UserInfo
extension ViewController {
    func setupTable() {
        tblView.separatorStyle = .none
        tblView.backgroundColor = .clear
        tblView.backgroundView = nil
        tblView.delegate = self
        tblView.dataSource = self
        tblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20 , right: 0)
    }
    
    func reloadTable() {
        tblView.reloadData()
    }
    
    func hideShowNoData() {
        if dataModels.count == 0 {
            noRecordsView.isHidden = false
            tblView.isHidden = true
        }
        else {
            noRecordsView.isHidden = true
            tblView.isHidden = false
        }
    }
}


// MARK:- Transactions
extension ViewController {
    func setupTableTransactions() {
        tblViewTransactions.separatorStyle = .none
        tblViewTransactions.backgroundColor = .clear
        tblViewTransactions.backgroundView = nil
        tblViewTransactions.delegate = self
        tblViewTransactions.dataSource = self
        tblViewTransactions.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    func reloadTableTransactions() {
        tblViewTransactions.reloadData()
    }
    
    func hideShowNoDataTransactions() {
        if transactions.count == 0 {
            noRecordsViewTransactions.isHidden = false
            tblViewTransactions.isHidden = true
        }
        else {
            noRecordsViewTransactions.isHidden = true
            tblViewTransactions.isHidden = false
        }
    }
    
    func setUpTransactionViewModel() {
        transactionsViewModel = ASATransactionViewModel()
        guard let viewModel = transactionsViewModel else { return }
        
        // Loader
        viewModel.isLoader.bind{[unowned self] in
            if $0 {
                // Show loader
                loader?.show(inView: self.view)
                loader?.loaderLabel.isHidden = false
            }
            else {
                // Hide Loader
                loader?.hide()
            }
        }
        
        viewModel.data.bind { data in
            if let transactionData = data.data, let transactions = transactionData.transactions {
                self.transactions = transactions
            }
            else {
                self.transactions = []
            }
            self.reloadTableTransactions()
            self.hideShowNoDataTransactions()
        }
        
        viewModel.error.bind { error in
            // _ = self.showAlert(title: "", message: error.localizedDescription)
            self.transactions = []
            self.reloadTableTransactions()
            self.hideShowNoDataTransactions()
        }
    }
    
    func refreshTransactions() {
        guard let viewModel = transactionsViewModel else { return }
        guard let consumerCode = dict["AsaConsumerCode"], let fintechCode = dict["AsaFintechCode"] else { return }
        viewModel.getTransactions(consumerCode: consumerCode, fintechCode: fintechCode)
    }
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblView {
            return dataModels.count
        }
        else {
            return transactions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        if tableView == tblView {
            cell.lblBalance.isHidden = true
            cell.lblDesc.numberOfLines = 0
            
            let dataModel = dataModels[indexPath.row]
            if dataModel.title == "First Name" || dataModel.title == "Last Name" || dataModel.title == "Email"{
               
                cell.lblDesc.text = "Not Shared"
                cell.lblDesc.textColor = .red
            }else{
                
                cell.lblDesc.text = dataModel.desc
                cell.lblDesc.textColor = .green
            }
            cell.lblTitle.text = dataModel.title
        }
        else {
            cell.lblDesc.numberOfLines = 2
            cell.lblBalance.isHidden = false
            cell.lblTitle.text = "-"
            cell.lblDesc.text  = "-"
            cell.lblBalance.text  = "-"
            
            if indexPath.row < transactions.count {
                // Transaction Date
                let transaction = transactions[indexPath.row]
                let postDateStr = transaction.transactionPostDate ?? ""
                AppDelegate.shared.dateFormatter.dateFormat = "MM/dd/yyyy"
                if let date = AppDelegate.shared.dateFormatter.date(from: postDateStr) {
                    AppDelegate.shared.dateFormatter.dateFormat = "MMMM dd, yyyy"
                    cell.lblTitle.text = AppDelegate.shared.dateFormatter.string(from: date)
                }
                
                // Transaction Memo
                if let memo = transaction.transactionMemo {
                    cell.lblDesc.text = memo
                }
            
                // Balance
                if let balance = transaction.balanceChange {
                    cell.lblBalance.text = balance.toCurrency()
                    if balance < 0 {
                        // Negative
                        cell.lblBalance.textColor = .red
                    }
                    else {
                        // Positive
                        cell.lblBalance.textColor = cell.lblDesc.textColor
                    }
                }
            }
        }
        
        let itemsCount = tableView == tblView ? dataModels.count : transactions.count
        setUpCellUIForItemsCount(cell: cell, itemsCount: itemsCount, indexPath: indexPath)
        
        return cell
    }
    
    
    func setUpCellUIForItemsCount(cell: TableViewCell, itemsCount: Int, indexPath: IndexPath) {
        cell.containerView.layer.cornerRadius = 20
        if itemsCount == 1 {
            cell.layoutConstraintTopSpacing.constant = 20
            cell.layoutConstraintBottomSpacing.constant = 17
            cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        else if itemsCount == 2 {
            if indexPath.row == 0 {
                cell.layoutConstraintTopSpacing.constant = 20
                cell.layoutConstraintBottomSpacing.constant = 17
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            else {
                cell.layoutConstraintTopSpacing.constant = 0
                cell.layoutConstraintBottomSpacing.constant = 17
                cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }
        else {
            // First row top corners
            if indexPath.row == 0 {
                cell.layoutConstraintTopSpacing.constant = 20
                cell.layoutConstraintBottomSpacing.constant = 17
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            // Last row bottom corners
            else if indexPath.row == itemsCount - 1 {
                cell.layoutConstraintTopSpacing.constant = 0
                cell.layoutConstraintBottomSpacing.constant = 17
                cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            // Middle row no corners
            else {
                cell.layoutConstraintTopSpacing.constant = 0
                cell.layoutConstraintBottomSpacing.constant = 17
                cell.containerView.layer.cornerRadius = 0
            }
        }
    }
}


// MARK:- ScrollView
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != scrollViewMain { return }
        
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        pageControl.currentPage = Int(page)
        if page == 1 {
            hideShowNoDataTransactions()
            tabType = .TransactionInfo
            if transactions.count == 0 {
                refreshTransactions()
            }
        }
        else {
            hideShowNoData()
            tabType = .UserInfo
        }
    }
}


class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    
    @IBOutlet weak var containerView: DesignableView!
    @IBOutlet weak var layoutConstraintTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var layoutConstraintBottomSpacing: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        lblTitle.numberOfLines = 0
        lblDesc.numberOfLines = 0
    }
}


extension Double {
    func toCurrency() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_US")
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}


class DataModel: NSObject {
    var title: String = ""
    var desc: String = ""
    convenience init(title: String, desc: String) {
        self.init()
        self.title = title
        self.desc = desc
    }
}
