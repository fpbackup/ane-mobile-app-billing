package
{

    import com.funkypanda.mobilebilling.InAppPayments;
    import com.funkypanda.mobilebilling.events.CanMakePurchaseEvent;
    import com.funkypanda.mobilebilling.events.ConsumePurchaseErrorEvent;
    import com.funkypanda.mobilebilling.events.ConsumePurchaseSuccessEvent;
    import com.funkypanda.mobilebilling.events.GetProductInfoErrorEvent;
    import com.funkypanda.mobilebilling.events.GetProductInfoSuccessEvent;
    import com.funkypanda.mobilebilling.events.GetPurchasedItemsSuccessEvent;
    import com.funkypanda.mobilebilling.events.MakePurchaseErrorEvent;
    import com.funkypanda.mobilebilling.events.MakePurchaseSuccessEvent;
    import com.funkypanda.mobilebilling.events.PurchaseDebugEvent;
    import com.funkypanda.mobilebilling.models.Purchase;

    import feathers.controls.Button;
    import feathers.controls.ScrollContainer;
    import feathers.controls.ScrollText;
    import feathers.layout.TiledColumnsLayout;
    import feathers.themes.MetalWorksMobileTheme;

    import flash.events.UncaughtErrorEvent;
    import flash.system.Capabilities;

    import flash.text.TextFormat;

    import starling.core.Starling;

    import starling.display.Sprite;
    import starling.events.Event;

    public class TestApp extends Sprite
    {

        private var service : InAppPayments;

        private var logTF : ScrollText;
        private static const TOP : uint = 405;
        private const container: ScrollContainer = new ScrollContainer();

        private var unconsumedPurchaseReceipt : String;

        public function TestApp()
        {
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }

        protected function addedToStageHandler(event : Event) : void
        {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

            stage.addEventListener(Event.RESIZE, function(evt : Event) : void
            {
                logTF.height = stage.stageHeight - TOP;
                logTF.width = stage.stageWidth;
                container.width = stage.stageWidth;
            });


            Starling.current.nativeStage.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,
            function (e:UncaughtErrorEvent):void
            {
                log("UNCAUGHT ERROR " + e.toString());
            });

            new MetalWorksMobileTheme();

            var layout : TiledColumnsLayout = new TiledColumnsLayout();
            layout.useSquareTiles = false;
            container.layout = layout;
            container.width = stage.stageWidth;
            container.height = TOP;
            addChild(container);

            var button : Button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.setAndroidKey(Constants.GOOGLE_PLAY_PUBLIC_KEY);
            });
            button.label = "setAndroidKey";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo([Constants.ANDROID_SHOP_ITEM1, Constants.ANDROID_SHOP_ITEM2, Constants.ANDROID_SHOP_ITEM3]);
            });
            button.label = "getProductsInfo android";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo([Constants.ANDROID_SHOP_ITEM1, "BAD_ID", Constants.ANDROID_SHOP_ITEM2]);
            });
            button.label = "getProductsInfo android 1 wrong ID";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo([Constants.IOS_SHOP_ITEM1, Constants.IOS_SHOP_ITEM2, Constants.IOS_SHOP_ITEM3]);
            });
            button.label = "getProductsInfo iOS";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo([Constants.IOS_SHOP_ITEM1, "BAD_ID", Constants.IOS_SHOP_ITEM2]);
            });
            button.label = "getProductsInfo iOS 1 wrong ID";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo(["wrong_id", "another_wrong_ID"]);
            });
            button.label = "getProductsInfo all wrong ID";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getCanMakeAPurchase();
            });
            button.label = "getCanMakeAPurchase";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.makePurchase(Constants.IOS_SHOP_ITEM1);
            });
            button.label = "makePurchase good ID iOS";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.makePurchase(Constants.ANDROID_SHOP_ITEM1);
            });
            button.label = "makePurchase good ID android";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.consumePurchase("bad_ID");
            });
            button.label = "consumePurchase wrong ID";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getPurchasedItems();
            });
            button.label = "getPurchasedItems";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                if (unconsumedPurchaseReceipt != null)
                {
                    service.consumePurchase(unconsumedPurchaseReceipt);
                }
                else
                {
                    log("No unconsumed purchase. Either call makePurchase or getPurchasedItems");
                }
            });
            button.label = "consume 1 pending";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.consumePurchase("this_is_a_bad_receipt");
            });
            button.label = "consume wrong ID";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                logTF.text = "";
            });
            button.label = "CLEAR LOG";
            button.validate();
            container.addChild(button);

            logTF = new ScrollText();
            logTF.height = stage.stageHeight - TOP;
            logTF.width = stage.stageWidth;
            logTF.y = TOP;
            logTF.textFormat = new TextFormat(null, 22, 0xdedede);
            addChild(logTF);

            log("Testing application for the payments ANE.");

            try {
                service = InAppPayments.service;
            }
            catch (err : Error)
            {
                log(err + "\n" + err.getStackTrace());
                return;
            }

            // response to getProductsInfo
            service.addEventListener(GetProductInfoSuccessEvent.GET_PRODUCT_INFO_SUCCESS, function (evt : GetProductInfoSuccessEvent) : void
            {
                log(evt.type + " " + evt.products);
            });
            service.addEventListener(GetProductInfoErrorEvent.GET_PRODUCT_INFO_ERROR, function (evt : GetProductInfoErrorEvent) : void
            {
                log(evt.type + " " + evt.message);
            });

            // response to makePurchase
            service.addEventListener(MakePurchaseSuccessEvent.MAKE_PURCHASE_SUCCESS, function (evt : MakePurchaseSuccessEvent) : void
            {
                log("MAKE_PURCHASE_SUCCESS with " + evt.purchases.length + " items");
                for each (var purchase : Purchase in evt.purchases)
                {
                    unconsumedPurchaseReceipt = purchase.receipt;
                    log(purchase.toString());
                }
            });
            service.addEventListener(MakePurchaseErrorEvent.MAKE_PURCHASE_ERROR, function (evt : MakePurchaseErrorEvent) : void
            {
                log(evt.type + " " + evt.message + " CODE: " + evt.error);
            });

            // response to getPurchasedItems
            service.addEventListener(GetPurchasedItemsSuccessEvent.GET_PURCHASED_ITEMS_SUCCESS, function (evt : GetPurchasedItemsSuccessEvent) : void
            {
                unconsumedPurchaseReceipt = null;
                if (isiOS)
                {
                    log("GET_PURCHASED_ITEMS_SUCCESS receipt: " + evt.purchaseReceiptsIOS);
                    unconsumedPurchaseReceipt = evt.purchaseReceiptsIOS;
                }
                else if (isAndroid)
                {
                    log("GET_PURCHASED_ITEMS_SUCCESS with " + evt.purchasesAndroid.length + " items.");
                    for each (var purchase : Purchase in evt.purchasesAndroid)
                    {
                        unconsumedPurchaseReceipt = purchase.receipt;
                        log(purchase.toString());
                    }
                }
            });

            // response to consumePurchase
            service.addEventListener(ConsumePurchaseSuccessEvent.CONSUME_PURCHASE_SUCCESS, function (evt : ConsumePurchaseSuccessEvent) : void
            {
                log(evt.type + " " + evt.message);
            });
            service.addEventListener(ConsumePurchaseErrorEvent.CONSUME_PURCHASE_ERROR, function (evt : ConsumePurchaseErrorEvent) : void
            {
                log(evt.type + " " + evt.message);
            });

            // response to canMakePurchase
            service.addEventListener(CanMakePurchaseEvent.CAN_MAKE_PURCHASE, function (evt : CanMakePurchaseEvent) : void
            {
                log(evt.type + " " + evt.canMakePurchase);
            });

            // debug - can be fired anytime
            service.addEventListener(PurchaseDebugEvent.DEBUG, function (evt : PurchaseDebugEvent) : void
            {
                log(evt.type + " " + evt.message);
            });
        }

        private function log(str : String) : void
        {
            logTF.text += str + "\n";
            trace(str);
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
