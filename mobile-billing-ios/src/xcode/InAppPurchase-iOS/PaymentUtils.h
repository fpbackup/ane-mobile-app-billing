#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FlashRuntimeExtensions.h"

@interface PaymentUtils : NSObject 

+(NSDictionary *) transactionToDictionary:(SKPaymentTransaction*) transaction;

+(NSString *) errorStateToString:(NSInteger) errorCode;

+(NSString *) transactionStateToString:(SKPaymentTransactionState) state;

@end
