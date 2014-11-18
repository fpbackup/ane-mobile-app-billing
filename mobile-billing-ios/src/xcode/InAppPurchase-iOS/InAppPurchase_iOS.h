#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "FlashRuntimeExtensions.h"
#import "PaymentUtils.h"

@interface InAppPurchase_iOS : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

- (void) sendRequest:(SKRequest*)request AndContext:(FREContext*)ctx;

- (NSString *) dataToJSON:(id) data;

- (void)logDebug:(NSString *) str;

@end