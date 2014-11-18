#import "PaymentUtils.h"

@implementation PaymentUtils

+(NSDictionary *) transactionToDictionary:(SKPaymentTransaction*) transaction
{
    NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc] init] autorelease];
    [dictionary setValue:transaction.payment.productIdentifier forKey:@"productId"];
    [dictionary setValue:[@(transaction.payment.quantity) stringValue] forKey:@"quantity"];
    if (transaction.transactionState == SKPaymentTransactionStatePurchased || transaction.transactionState == SKPaymentTransactionStateRestored)
    {
        [dictionary setValue:[@(floor([transaction.transactionDate timeIntervalSince1970] * 1000)) stringValue] forKey:@"transactionDate"];
        [dictionary setValue:transaction.transactionIdentifier forKey:@"transactionId"];
    }
    if (transaction.transactionState == SKPaymentTransactionStatePurchased)
    {
        [dictionary setValue:[transaction.transactionReceipt base64EncodedStringWithOptions:0] forKey:@"transactionReceipt"];
    }
    return dictionary;
}

+(NSString *) errorStateToString:(NSInteger) errorCode
{
    NSString *result = nil;
    
    switch(errorCode) {
        case SKErrorUnknown:
            result = @"SKErrorUnknown";
            break;
        case SKErrorClientInvalid:
            result = @"SKErrorClientInvalid";
            break;
        case SKErrorPaymentCancelled:
            result = @"SKErrorPaymentCancelled";
            break;
        case SKErrorPaymentInvalid:
            result = @"SKErrorPaymentInvalid";
            break;
        case SKErrorPaymentNotAllowed:
            result = @"SKErrorPaymentNotAllowed";
            break;
        case SKErrorStoreProductNotAvailable:
            result = @"SKErrorStoreProductNotAvailable";
            break;
        default:
            result = @"Unknown_error_state";
            break;
    }
    return result;
}

+(NSString *) transactionStateToString:(SKPaymentTransactionState) state
{
    NSString *result = nil;
    
    switch(state) {                
        case SKPaymentTransactionStateFailed:
            result = @"SKPaymentTransactionStateFailed";
            break;
        case SKPaymentTransactionStatePurchased:
            result = @"SKPaymentTransactionStatePurchased";
            break;
        case SKPaymentTransactionStatePurchasing:
            result = @"SKPaymentTransactionStatePurchasing";
            break;
        case SKPaymentTransactionStateRestored:
            result = @"SKPaymentTransactionStateRestored";
            break;
        default:
            result = @"Unknown_tansaction_state";
            break;
    }
    return result;
}

@end