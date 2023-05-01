//
//  IAPHelper.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 17/01/23.
//
import StoreKit

class IAPHelper: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    static let shared = IAPHelper()
    var products = [SKProduct]()
    var purchaseCompletion: ((Bool) -> Void)?

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    func startPurchase(productId: String, completion: @escaping (Bool) -> Void) {
        purchaseCompletion = completion
        requestProductInfo(productIds: [productId])
    }
    
    func restorePurchase(productId: String, completion: @escaping (Bool) -> Void) {
        purchaseCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions(withApplicationUsername: productId)
    }

    private func requestProductInfo(productIds: [String]) {
        let request = SKProductsRequest(productIdentifiers: Set(productIds))
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        if products.count == 0 {
            purchaseCompletion?(false)
        } else {
            let payment = SKPayment(product: products[0])
            SKPaymentQueue.default().add(payment)
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                print("Purchasing...")
            case .purchased:
                print("Purchased")
                SKPaymentQueue.default().finishTransaction(transaction)
                purchaseCompletion?(true)
            case .failed:
                print("Failed")
                SKPaymentQueue.default().finishTransaction(transaction)
                purchaseCompletion?(false)
            case .restored:
                if transaction.payment.productIdentifier == "productId" {
                    purchaseCompletion?(true)
                }
            default:
                break
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("Transactions removed from queue")
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("Restore failed with error: \(error.localizedDescription)")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("Restore completed")
        // Notify the user that the restore was successful
    }
}
