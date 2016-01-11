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

    import flash.text.TextFormat;

    import starling.core.Starling;

    import starling.display.Sprite;
    import starling.events.Event;

    public class TestApp extends Sprite
    {
        public static const GOOGLE_PLAY_PUBLIC_KEY : String = "TODO GET KEY";

        private var service : InAppPayments;

        private var logTF : ScrollText;
        private static const TOP : uint = 445;
        private const container: ScrollContainer = new ScrollContainer();

        private var unconsumedPurchase : Purchase;

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
                service.setAndroidKey(GOOGLE_PLAY_PUBLIC_KEY);
            });
            button.label = "setAndroidKey";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo(["item_1_Android", "item_2_Android", "item_3_Android"]);
            });
            button.label = "getProductsInfo android";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo(["item_1_Android", "BAD_ID", "item_2_Android"]);
            });
            button.label = "getProductsInfo android 1 wrong ID";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo(["item_1_iOS", "item_2_iOS", "item_3_iOS"]);
            });
            button.label = "getProductsInfo iOS";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo(["item_1_iOS", "BAD_ID", "item_2_iOS"]);
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
                service.makePurchase("general_150000_299_ipad");
            });
            button.label = "makePurchase good ID iOS";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.makePurchase("at_gp_reg_2_499");
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
                if (unconsumedPurchase != null)
                {
                    service.consumePurchase(unconsumedPurchase.receipt);
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

            log("Testing application for the payments ANE. It uses the rinoa client credentials.");

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
                    unconsumedPurchase = purchase;
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
                log("GET_PURCHASED_ITEMS_SUCCESS, receipt: " + evt.purchaseReceipts);
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

    }
}
