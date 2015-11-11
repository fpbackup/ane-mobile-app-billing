#import "InAppPurchase_iOS.h"

FREContext AirContext = nil;

void *SelfReference;

NSArray * avaiableProducts = nil;

BOOL hasTransactionObserver = NO;

@implementation InAppPurchase_iOS

//////////////////////////////////////////////////////////////////////////////////////
// INITIALIZATION
//////////////////////////////////////////////////////////////////////////////////////

- (id) init
{
    self = [super init];
    if (self)
    {
        SelfReference = self;
    }
    return self;
}

// this is called when the extension context is created.
void InAppPurchaseContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    *numFunctionsToTest = 6;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);
    
    func[0].name = (const uint8_t*) "getProductInfo";
    func[0].functionData = NULL;
    func[0].function = &getProductsInfo;
    
    func[1].name = (const uint8_t*) "userCanMakeAPurchase";
    func[1].functionData = NULL;
    func[1].function = &userCanMakeAPurchase;
    
    func[2].name = (const uint8_t*) "makePurchase";
    func[2].functionData = NULL;
    func[2].function = &makePurchase;
    
    func[3].name = (const uint8_t*) "consumePurchase";
    func[3].functionData = NULL;
    func[3].function = &consumeTransaction;
    
    func[4].name = (const uint8_t*) "getPurchasedItems";
    func[4].functionData = NULL;
    func[4].function = &getPurchasedItems;
    
    func[5].name = (const uint8_t*) "refreshReceipt";
    func[5].functionData = NULL;
    func[5].function = &refreshReceipt;
    
    
    *functionsToSet = func;
    
    AirContext = ctx;
    
    if ((InAppPurchase_iOS*)SelfReference == nil)
    {
        SelfReference = [[InAppPurchase_iOS alloc] init];
    }
    
}

// This method will set which methods to call when doing the actual initialization.
// The initializer node in the iPhone-ARM platform of the extension.xml file must have the same name as this function
void InAppPurchaseInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
    *extDataToSet = NULL;
    *ctxInitializerToSet = &InAppPurchaseContextInitializer;
}

- (void) addPaymentQueueObserverIfNeeded
{
    if (hasTransactionObserver == NO )
    {
        hasTransactionObserver = YES;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
// CAN MAKE PURCHASE
//////////////////////////////////////////////////////////////////////////////////////

// Users cannot pay if parental control disallows it
FREObject userCanMakeAPurchase(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    
    BOOL canMakePayment = [SKPaymentQueue canMakePayments];
    uint8_t* canMakePaymentString;
    if (canMakePayment)
    {
        canMakePaymentString = (uint8_t*) [@"true" UTF8String];
    }
    else
    {
        canMakePaymentString = (uint8_t*) [@"false" UTF8String];
    }
    [(InAppPurchase_iOS*)SelfReference logDebug: [NSString stringWithFormat:@"User can make a purchase: %s", canMakePayment ? "true" : "false"]];
    FREDispatchStatusEventAsync(context, (uint8_t*) "CAN_MAKE_PURCHASE", canMakePaymentString);
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
// PRODUCT INFO
//////////////////////////////////////////////////////////////////////////////////////

// get what is avaiable to purchase and its details
FREObject getProductsInfo(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    [(InAppPurchase_iOS*)SelfReference logDebug: @"Getting product info"];
    
    FREObject arr = argv[0];
    uint32_t arr_len;
    FREGetArrayLength(arr, &arr_len);
    
    NSMutableSet* productsIdentifiers = [[[NSMutableSet alloc] init] autorelease];
    
    for(int32_t i=arr_len-1; i>=0;i--)
    {
        FREObject element;
        FREGetArrayElementAt(arr, i, &element);
        
        // convert it to NSString
        uint32_t stringLength;
        const uint8_t *string;
        FREGetObjectAsUTF8(element, &stringLength, &string);
        NSString *productIdentifier = [NSString stringWithUTF8String:(char*)string];
        
        [productsIdentifiers addObject:productIdentifier];
    }
    
    //[(InAppPurchase_iOS*)SelfRererence logDebug: [(InAppPurchase_iOS*)SelfRererence dataToJSON:productsIdentifiers]];
    
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:productsIdentifiers];
    
    [(InAppPurchase_iOS*)SelfReference sendRequest:request AndContext:context];
    
    if (avaiableProducts != nil)
    {
        [avaiableProducts release];
        avaiableProducts = nil;
    }
    return nil;
}

// send request to the app store
- (void) sendRequest:(SKRequest*)request AndContext:(FREContext*)ctx
{
    request.delegate = self;
    [request start];
}

// on product info received
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    avaiableProducts = [response.products copy];
    [avaiableProducts retain];
    
    NSMutableArray *products = [[[NSMutableArray alloc] init] autorelease];
    NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc] init] autorelease];
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    for (SKProduct* product in [response products])
    {
        [numberFormatter setLocale:product.priceLocale];
        
        [dictionary removeAllObjects];
        [dictionary setValue:[product productIdentifier] forKey:@"productId"];
        [dictionary setValue:[product localizedTitle] forKey:@"title"];
        [dictionary setValue:[product localizedDescription] forKey:@"description"];
        [dictionary setValue:[numberFormatter stringFromNumber:product.price] forKey:@"priceLocale"];
        
        [products addObject:[dictionary copy]];
    }
    
    NSString* jsonResponse = [self dataToJSON:products];
    
    [self logDebug:[NSString stringWithFormat:@"get product response: %@", jsonResponse]];
    
    FREDispatchStatusEventAsync(AirContext ,(uint8_t*) "GET_PRODUCT_INFO_SUCCESS", (uint8_t*) [jsonResponse UTF8String] );
    
    if ([response invalidProductIdentifiers] != nil && [[response invalidProductIdentifiers] count] > 0)
    {
        NSString* errorString = [self dataToJSON:[response invalidProductIdentifiers]];
        [self logDebug:[NSString stringWithFormat:@"WARNING: tried to query invalid product IDs %@", errorString]];
    }
}

// on product info error
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSString* errorString = [NSString stringWithFormat:@"%@/%@/%@", @"Get products request to Apple failed", error.description, error.debugDescription];
    
    FREDispatchStatusEventAsync(AirContext ,(uint8_t*) "GET_PRODUCT_INFO_ERROR", (uint8_t*) [errorString UTF8String] );
}

//////////////////////////////////////////////////////////////////////////////////////
// MAKE PURCHASE
//////////////////////////////////////////////////////////////////////////////////////

FREObject makePurchase(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    uint32_t stringLength;
    const uint8_t *string1;
    
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &string1) != FRE_OK)
    {
        NSString *err = [(InAppPurchase_iOS*)SelfReference createPurchaseError:@"PURCHASE_ERROR_OTHER" message:@"Cannot parse product ID received from Flash."];
        FREDispatchStatusEventAsync(context, (uint8_t*) "MAKE_PURCHASE_ERROR", (uint8_t*)[err UTF8String]);
        return nil;
    }
    
    NSString *productIdentifier = [NSString stringWithUTF8String:(char*)string1];
    
    if (avaiableProducts == nil || avaiableProducts.count == 0)
    {
        NSString *err = [(InAppPurchase_iOS*)SelfReference createPurchaseError:@"PURCHASE_ERROR_OTHER" message:@"No available products to buy or getProductsInfo was not called"];
        FREDispatchStatusEventAsync(context, (uint8_t*) "MAKE_PURCHASE_ERROR", (uint8_t*)[err UTF8String]);
        return nil;
    }
    
    SKProduct *productToBuy = nil;
    
    for (SKProduct *product in avaiableProducts) {
        if ([product.productIdentifier isEqualToString:productIdentifier])
        {
            productToBuy = product;
        }
    }
    
    if (productToBuy == nil)
    {
        NSString *err = [(InAppPurchase_iOS*)SelfReference createPurchaseError:@"PURCHASE_ERROR_OTHER" message:@"Product not avaiable for purchase"];
        FREDispatchStatusEventAsync(context, (uint8_t*) "MAKE_PURCHASE_ERROR", (uint8_t*)[err UTF8String]);
        return nil;
    }
    
    SKPayment* payment = [SKPayment paymentWithProduct:productToBuy];
    
    [(InAppPurchase_iOS*)SelfReference addPaymentQueueObserverIfNeeded];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    [(InAppPurchase_iOS*)SelfReference logDebug: [NSString stringWithFormat:@"Making purchase for ID: %@", [payment productIdentifier]]];
    
    return nil;
}


// Processes payment events. does NOT consume the payment except if the payment failed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    [self logDebug:[NSString stringWithFormat:@"Payment queue with %lu items updated.", (unsigned long)transactions.count]];
    
    NSMutableArray *successfulPaymentsArr = [[NSMutableArray alloc] init];
    NSMutableArray *errorArr = [[NSMutableArray alloc] init];
    for (SKPaymentTransaction *transaction in transactions)
    {
        [self logDebug:[NSString stringWithFormat:@"Payment with Id: %@ and state: %@ updated", transaction.transactionIdentifier, [PaymentUtils transactionStateToString: transaction.transactionState]]];
        if (transaction.transactionState == SKPaymentTransactionStateFailed)
        {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
            NSString * err = [NSString stringWithFormat:@"error code: %@ description: %@ reason: %@ recovery suggestion: %@", [PaymentUtils errorStateToString: transaction.error.code], transaction.error.localizedDescription, transaction.error.localizedFailureReason, transaction.error.localizedRecoverySuggestion];
            
            NSString *fullError;
            
            if (transaction.error.code == SKErrorPaymentCancelled)
            {
                fullError = [self createPurchaseError:@"PURCHASE_ERROR_CANCELLED" message:err];
            }
            else
            {
                fullError = [self createPurchaseError:@"PURCHASE_ERROR_OTHER" message:err];
            }
            [errorArr addObject:fullError];
        }
        else if (transaction.transactionState == SKPaymentTransactionStatePurchased || transaction.transactionState == SKPaymentTransactionStateRestored)
        {
            // the queue contains duplicates if one tried to purchase the same item multiple times without consuming them
            BOOL isDuplicate = NO;
            for (NSDictionary *existingTransaction in successfulPaymentsArr)
            {
                if ([[existingTransaction valueForKey:@"transactionId"] isEqualToString:transaction.transactionIdentifier])
                {
                    isDuplicate = YES;
                }
            }
            if (isDuplicate == NO)
            {
                NSDictionary* transactionDict = [PaymentUtils transactionToDictionary:transaction];
                
                NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:[receiptUrl path]])
                {
                    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
                    NSString *receiptStr = [receiptData base64EncodedStringWithOptions:0];
                    [transactionDict setValue:receiptStr forKey:@"receipt"];
                }
                else
                {
                    // TODO handle this case!
                    [self logDebug:[NSString stringWithFormat:@"ERROR  Payment has no receipt!"]];
                }
                [successfulPaymentsArr addObject:transactionDict];
            }
        }
    }
    
    
    if (successfulPaymentsArr.count > 0)
    {
        FREDispatchStatusEventAsync(AirContext , (uint8_t*)"MAKE_PURCHASE_SUCCESS", (uint8_t*)[[self dataToJSON:successfulPaymentsArr] UTF8String] );
    }
    
    for (NSString *errorStr in errorArr)
    {
        FREDispatchStatusEventAsync(AirContext , (uint8_t*)"MAKE_PURCHASE_ERROR", (uint8_t*)[errorStr UTF8String] );
    }
}

-(NSString *)createPurchaseError:(NSString *) errorStr message:(NSString *) messageStr
{
    NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc] init] autorelease];
    [dictionary setValue:errorStr forKey:@"error"];
    [dictionary setValue:messageStr forKey:@"message"];
    return [self dataToJSON:dictionary];
}
//////////////////////////////////////////////////////////////////////////////////////
// GET PURCHASED ITEMS
//////////////////////////////////////////////////////////////////////////////////////

FREObject getPurchasedItems(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[receiptUrl path]])
    {
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
        NSString *receiptStr = [receiptData base64EncodedStringWithOptions:0];
        [(InAppPurchase_iOS*)SelfReference logDebug: [NSString stringWithFormat:@"Found receipts"]];
        FREDispatchStatusEventAsync(context , (uint8_t*)"GET_PURCHASED_ITEMS_SUCCESS", (uint8_t*)[receiptStr UTF8String]);
    }
    else
    {
        FREDispatchStatusEventAsync(context, (uint8_t*) "GET_PURCHASED_ITEMS_SUCCESS", (uint8_t*)"");
    }
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
// CONSUME TRANSACTION
//////////////////////////////////////////////////////////////////////////////////////

// Consumes the transaction if it receives the proper ID and transaction state is purchased or restored.
FREObject consumeTransaction(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    uint32_t stringLength;
    const uint8_t *transactionIdFromFlash;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &transactionIdFromFlash) != FRE_OK)
    {
        FREDispatchStatusEventAsync(context ,(uint8_t*)"CONSUME_PURCHASE_ERROR", (uint8_t*)"Bad input parameter");
        return nil;
    }
    NSString *transactionId = [NSString stringWithUTF8String:(char*)transactionIdFromFlash];
    
    NSArray* transactions = [[SKPaymentQueue defaultQueue] transactions];
    
    SKPaymentTransaction* currentTransaction = nil;
    for (SKPaymentTransaction* transaction in transactions)
    {
        if ([[transaction transactionIdentifier] isEqualToString:transactionId])
        {
            currentTransaction = transaction;
            break;
        }
    }
    if (currentTransaction == nil)
    {
        FREDispatchStatusEventAsync(context, (uint8_t*)"CONSUME_PURCHASE_ERROR", (uint8_t*)"Product does not exists among purchased items");
        return nil;
    }
    
    if (([currentTransaction transactionState] == SKPaymentTransactionStatePurchased || [currentTransaction transactionState] == SKPaymentTransactionStateRestored))
    {
        [(InAppPurchase_iOS*)SelfReference addPaymentQueueObserverIfNeeded];
        [[SKPaymentQueue defaultQueue] finishTransaction:currentTransaction];
 
        FREDispatchStatusEventAsync(AirContext ,(uint8_t*) "CONSUME_PURCHASE_SUCCESS", (uint8_t*)"Successful consume." );
        
        [(InAppPurchase_iOS*)SelfReference logDebug:[NSString stringWithFormat:@"Purchase for product ID %@ consumed ", [[currentTransaction payment] productIdentifier]]];
    }
    else
    {
        NSString* errorStr = [NSString stringWithFormat: @"Product payment state is %@, should be PURCHASED or RESTORED", [PaymentUtils transactionStateToString: currentTransaction.transactionState]];
        FREDispatchStatusEventAsync(context, (uint8_t*)"CONSUME_PURCHASE_ERROR", (uint8_t*)[errorStr UTF8String]);
    }
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
// REFRESH RECEIPT
//////////////////////////////////////////////////////////////////////////////////////

FREObject refreshReceipt(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    SKReceiptRefreshRequest *refreshReceiptRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:@{}];
    refreshReceiptRequest.delegate = SelfReference;
    [refreshReceiptRequest start];
    return nil;
}

// on product info finish
- (void)requestDidFinish:(SKRequest *)request
{
    [self logDebug:[NSString stringWithFormat:@"Request finished: %@", request.class]];
    if([request isKindOfClass:[SKReceiptRefreshRequest class]])
    {
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[receiptUrl path]])
        {
            NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
            NSString *receiptStr = [receiptData base64EncodedStringWithOptions:0];
            FREDispatchStatusEventAsync(AirContext , (uint8_t*)"REFRESH_RECEIPT_SUCCESS", (uint8_t*)[receiptStr UTF8String] );
        } else
        {
            NSLog(@"Receipt request done but there is no receipt. This is likely because the user canceled at the login screen");
            // This can happen if the user cancels the login screen for the store.
            // If we get here it means there is no receipt and an attempt to get it failed because the user cancelled the login.
            FREDispatchStatusEventAsync(AirContext , (uint8_t*)"REFRESH_RECEIPT_ERROR", (uint8_t*)"receipt file not found." );
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////
// DESTRUCTOR
//////////////////////////////////////////////////////////////////////////////////////

-(void)dealloc
{
    NSLog(@"Purchase library: Deallocating");
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    hasTransactionObserver = NO;
    SelfReference = nil;
    if (avaiableProducts != nil)
    {
        [avaiableProducts release];
        avaiableProducts = nil;
    }
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////
// MISC
//////////////////////////////////////////////////////////////////////////////////////

-(NSString *)dataToJSON:(id)data
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
    if (!jsonData)
    {
        return [NSString stringWithFormat:@"ERROR Unable to parse JSON %@ %@", error.description, error.debugDescription];
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(void)logDebug:(NSString *) str
{
    NSLog(str, nil);
    FREDispatchStatusEventAsync(AirContext ,(uint8_t*) "DEBUG", (uint8_t*) [str UTF8String] );
}

@end