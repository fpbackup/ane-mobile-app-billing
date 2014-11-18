package com.funkypanda.mobilebilling
{

    import com.funkypanda.mobilebilling.events.CanMakePurchaseEvent;
    import com.funkypanda.mobilebilling.events.ConsumePurchaseErrorEvent;
    import com.funkypanda.mobilebilling.events.ConsumePurchaseSuccessEvent;
    import com.funkypanda.mobilebilling.events.GetPurchasedItemsErrorEvent;
    import com.funkypanda.mobilebilling.events.GetPurchasedItemsSuccessEvent;
    import com.funkypanda.mobilebilling.events.PurchaseDebugEvent;
    import com.funkypanda.mobilebilling.events.MakePurchaseErrorEvent;
    import com.funkypanda.mobilebilling.events.GetProductInfoErrorEvent;
    import com.funkypanda.mobilebilling.events.GetProductInfoSuccessEvent;
    import com.funkypanda.mobilebilling.events.MakePurchaseSuccessEvent;
    import com.funkypanda.mobilebilling.models.Product;
    import com.funkypanda.mobilebilling.models.Purchase;
    import com.funkypanda.mobilebilling.models.MakePurchaseError;

    import flash.events.EventDispatcher;
    import flash.events.StatusEvent;
    import flash.external.ExtensionContext;
    import flash.system.Capabilities;

    public class InAppPayments extends EventDispatcher
    {

        public static const EXT_CONTEXT_ID : String = "com.funkypanda.mobile-billing";

        private static var _instance : InAppPayments;
        private static var _extContext : ExtensionContext;

        public static function get service() : InAppPayments
        {
            if (_instance == null)
            {
                _instance = new InAppPayments();
            }
            return _instance;
        }

        /** Usage:
         * InAppPayments.service.addEventListener(..); // The app dispatches events from the "events" package.
         * InAppPayments.service.[command you want to execute];
         */
        public function InAppPayments()
        {
            if (_instance == null)
            {
                try
                {
                    _extContext = ExtensionContext.createExtensionContext(EXT_CONTEXT_ID, null);
                    _extContext.addEventListener(StatusEvent.STATUS, extension_statusHandler);
                }
                catch (e : Error)
                {
                    throw new Error("The native extension context could not be created " + e);
                }
                return;
            }
            throw new Error("The singleton has already been created.");
        }

        /**
         * Initializes the extension, you must call this on Android before anything else
         * ANDROID ONLY, on iOS it does nothing.
         * base64EncodedPublicKey should be your application's public key, encoded in base64.
         * This is used for verification of purchase signatures. You can find your app's base64-encoded
         * public key in your application's page on Google Play Developer Console. Note that this
         * is NOT your "developer public key".
         * This method does not dispatch eny events
         */
        public function setAndroidKey(base64EncodedPublicKey : String) : void
        {
            if (isAndroid)
            {
                _extContext.call("setAndroidKey", base64EncodedPublicKey);
            }
        }

        /** Get the detailed product info from the store.
         *  Params:
         *  products: An Array of String product IDs
         *  Events dispatched as a reply:
         *  GetProductInfoSuccessEvent, GetProductInfoErrorEvent
         */
        public function getProductInfo(products : Array) : void
        {
            if ((products == null) || (products.length == 0))
            {
                dispatchEvent(new GetProductInfoErrorEvent('getProductsInfo() ERROR. No product IDs specified'));
            }
            else
            {
                for (var i : int = 0; i < products.length; i++)
                {
                    if (!(products[i] is String))
                    {
                        dispatchEvent(new GetProductInfoErrorEvent('getProductsInfo() ERROR. Product IDs can only be Strings, ' + products[i] + ' is not one'));
                    }
                }
                _extContext.call("getProductInfo", products);
            }
        }

        /** Checks if the user can make a purchase. User cannot pay for example if parental controls disallow it.
         *  iOS only, on Android it always dispatches CanMakePurchaseEvent with true parameter.
         *  Events dispatched as a reply:
         *  CanMakePurchaseEvent.CAN_MAKE_PURCHASE
         */
        public function getCanMakeAPurchase() : void
        {
            if (isiOS)
            {
                _extContext.call("userCanMakeAPurchase");
            }
            else
            {
                dispatchEvent(new CanMakePurchaseEvent(true));
            }
        }

        /** Makes a purchase. purchaseableID is the "id" field of a Product object.
         *  (Product objects are sent back to the response to getProductsInfo())
         *  Events dispatched as a reply:
         *  MakePurchaseSuccessEvent, MakePurchaseErrorEvent
         */
        public function makePurchase(purchaseableID : String) : void
        {
            if (purchaseableID == null)
            {
                dispatchEvent(new MakePurchaseErrorEvent(MakePurchaseError.PURCHASE_ERROR_OTHER, 'Called makePurchase() with null ID'));
            }
            else
            {
                _extContext.call("makePurchase", purchaseableID);
            }
        }

        /** Consumes a purchase. Once an item has been purchased you *can not* buy it again unless you consume it.
         *  You can either keep an item forever in the purchased state by not consuming it (for example to indicate
         *  that the user has a pro version of your app) or consume thus the user can buy it again (for example the user
         *  buys extra gold, and after purchase you increase his balance on the server).
         *  Params:
         *  receipt String that is held by a Purchase object's transactionReceipt field.
         *          Purchase objects are sent back as the response to makePurchase() and getPurchasedItems().
         *  Events dispatched as a reply:
         *  ConsumePurchaseSuccessEvent, ConsumePurchaseErrorEvent
         */
        public function consumePurchase(receipt : String) : void
        {
            if (receipt == null)
            {
                dispatchEvent(new ConsumePurchaseErrorEvent('Called consumePurchase() with null receipt'));
            }
            else
            {
                _extContext.call("consumePurchase", receipt);
            }
        }

        /** Returns items that have been purchased, but not consumed. (this is called by Apple restoring purchases)
         *  You should call this on every app startup to ensure that the user's inventory is in sync.
         *  Events dispatched as reply:
         *  GetPurchasedItemsSuccessEvent, GetPurchasedItemsErrorEvent
         **/
        public function getPurchasedItems() : void
        {
            _extContext.call("getPurchasedItems");
        }

        /** Call this if you do not plan to use the extension anymore. (should not happen) */
        public function dispose() : void
        {
            _extContext.call("dispose");
            _instance = null;
        }

        //////////////////////////////////////////////////////////////////////////////////////
        // NATIVE LIBRARY RESPONSE HANDLER
        //////////////////////////////////////////////////////////////////////////////////////

        private function extension_statusHandler(event : StatusEvent) : void
        {
            switch (event.code)
            {
                case PurchaseDebugEvent.DEBUG:
                    dispatchEvent(new PurchaseDebugEvent(event.level));
                    break;
                // getProductsInfo() replies
                case GetProductInfoSuccessEvent.GET_PRODUCT_INFO_SUCCESS:
                    dispatchEvent(new GetProductInfoSuccessEvent(createProductsArray(event.level)));
                    break;
                case GetProductInfoErrorEvent.GET_PRODUCT_INFO_ERROR:
                    dispatchEvent(new GetProductInfoErrorEvent(event.level));
                    break;
                // getPurchasedItems() replies
                case GetPurchasedItemsSuccessEvent.GET_PURCHASED_ITEMS_SUCCESS:
                    const res : Object = JSON.parse(event.level);
                    const purchasesArr : Vector.<Purchase> = new Vector.<Purchase>();
                    for each (var purchaseObj : Object in res)
                    {
                        purchasesArr.push(createPurchase(purchaseObj));
                    }
                    dispatchEvent(new GetPurchasedItemsSuccessEvent(purchasesArr));
                    break;
                case GetPurchasedItemsErrorEvent.GET_PURCHASED_ITEMS_ERROR:
                    dispatchEvent(new GetPurchasedItemsErrorEvent(event.level));
                    break;
                // getCanMakeAPurchase() replies
                case CanMakePurchaseEvent.CAN_MAKE_PURCHASE:
                    const canMakePurchase : Boolean = (event.level == "true");
                    dispatchEvent(new CanMakePurchaseEvent(canMakePurchase));
                    break;
                // makePurchase() replies
                case MakePurchaseSuccessEvent.MAKE_PURCHASE_SUCCESS:
                    const result : Object = JSON.parse(event.level);
                    const purchasesArray : Vector.<Purchase> = new Vector.<Purchase>();
                    for each (var purchaseObject : Object in result)
                    {
                        purchasesArray.push(createPurchase(purchaseObject));
                    }
                    dispatchEvent(new MakePurchaseSuccessEvent(purchasesArray));
                    break;
                case MakePurchaseErrorEvent.MAKE_PURCHASE_ERROR:
                    const makePurchaseError : Object = JSON.parse(event.level);
                    const errorEnum : MakePurchaseError = MakePurchaseError.fomString(makePurchaseError.error);
                    dispatchEvent(new MakePurchaseErrorEvent(errorEnum, makePurchaseError.message));
                    break;
                // consumePurchase() replies
                case ConsumePurchaseSuccessEvent.CONSUME_PURCHASE_SUCCESS:
                    dispatchEvent(new ConsumePurchaseSuccessEvent(event.level));
                    break;
                case ConsumePurchaseErrorEvent.CONSUME_PURCHASE_ERROR:
                    dispatchEvent(new ConsumePurchaseErrorEvent(event.level));
                    break;
                default:
                    dispatchEvent(new PurchaseDebugEvent("Unknown event type received from the ANE. Data: " + event.level));
                    break;
            }
        }

        //////////////////////////////////////////////////////////////////////////////////////
        // HELPERS
        //////////////////////////////////////////////////////////////////////////////////////

        private function createProductsArray(productsJSONString : String) : Vector.<Product>
        {
            const result : Object = JSON.parse(productsJSONString);
            const products : Vector.<Product> = new Vector.<Product>();
            for each (var productObject : Object in result)
            {
                var product : Product = new Product();
                product.id = productObject.productId;
                product.title = productObject.title;
                product.description = productObject.description;
                product.priceString = productObject.priceLocale;
                products.push(product);
            }
            return products;
        }

        private function createPurchase(purchaseObject : Object) : Purchase
        {
            const purchase : Purchase = new Purchase();
            purchase.rawData = purchaseObject;
            purchase.productId = purchaseObject.productId;
            purchase.quantity = purchaseObject.quantity;
            const date : Date = new Date();
            date.time = purchaseObject.transactionDate;
            purchase.transactionDate = date;
            purchase.transactionId = purchaseObject.transactionId;
            purchase.transactionReceipt = purchaseObject.transactionReceipt;
            return purchase;
        }

        private static function get isAndroid() : Boolean
        {
            return (Capabilities.manufacturer.indexOf("Android") > -1);
        }

        private static function get isiOS() : Boolean
        {
            return (Capabilities.manufacturer.indexOf("iOS") > -1);
        }

    }
}
