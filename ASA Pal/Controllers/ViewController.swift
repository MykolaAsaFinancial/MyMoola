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
    
    var tabType: TabType = .UserInfo
    var viewModel: ASATransactionViewModel = ASATransactionViewModel()
    var loader: ASALoader = ASALoader.view()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupTable()

        scrollViewMain.delegate = self
        scrollViewMain.showsHorizontalScrollIndicator = false
        
        setupTableTransactions()
        setUpTransactionViewModel()
        
        hideShowNoData()
        hideShowNoDataTransactions()
        callPersonalInfoAPI()
    }

}


// MARK:- Actions
extension ViewController {
    @IBAction func refreshAction(_ sender: UIButton) {
        if tabType == .UserInfo {
            // Refresh User info
            // Do nothing
            callPersonalInfoAPI()
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
            if viewModel.transactions.value.count == 0 {
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
        hideShowNoData()
    }
    
    func hideShowNoData() {
        if viewModel.accounts.value.count == 0 {
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
        hideShowNoDataTransactions()
    }
    
    func hideShowNoDataTransactions() {
        if viewModel.transactions.value.count == 0 {
            noRecordsViewTransactions.isHidden = false
            tblViewTransactions.isHidden = true
        }
        else {
            noRecordsViewTransactions.isHidden = true
            tblViewTransactions.isHidden = false
        }
    }
    
    func setUpTransactionViewModel() {
        
        // Loader
        viewModel.isLoader.bind{[unowned self] in
            if $0 {
                // Show loader
                loader.show(inView: self.view)
                loader.loaderLabel.isHidden = false
            }
            else {
                // Hide Loader
                loader.hide()
            }
        }
        
        viewModel.transactions.bind { response in
            self.reloadTableTransactions()
        }
        
        viewModel.accounts.bind({ data in
            self.reloadTable()
        })
        
        viewModel.error.bind { error in
            self.reloadTableTransactions()
            self.reloadTable()
        }
    }
    
    func refreshTransactions() {
        viewModel.getTransactions()
    }
    
    func callPersonalInfoAPI() {
        viewModel.getAccounts()
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblView {
            return viewModel.accounts.value.count
        }
        else {
            return viewModel.transactions.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        if tableView == tblView {
            cell.lblDesc.numberOfLines = 0
            
            let dataModel = viewModel.accounts.value[indexPath.row]
            cell.lblDesc.text = dataModel.subTitle
            cell.lblBalance.text = dataModel.desc
            cell.lblDesc.textColor = .green
            cell.lblBalance.textColor = .green
            cell.lblTitle.text = dataModel.title
        }
        else {
            cell.lblDesc.numberOfLines = 0
            
            if indexPath.row < viewModel.transactions.value.count {
                let transaction = viewModel.transactions.value[indexPath.row]
                cell.lblTitle.text = transaction.subTitle
                cell.lblDesc.text = transaction.title
                cell.lblBalance.text = transaction.desc
            }
        }
        
        let itemsCount = tableView == tblView ? viewModel.accounts.value.count : viewModel.transactions.value.count
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
            if viewModel.transactions.value.count == 0 {
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
