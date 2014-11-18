package com.funkypanda.mobilebilling;


public class FlashConstants {

    ////////////////////////////////////////////////////////////////////// event codes
    // dispatched anytime when the extension is running
    final public static String CODE_DEBUG = "DEBUG";

    // response to getProductsInfo
    final public static String GET_PRODUCT_INFO_SUCCESS = "GET_PRODUCT_INFO_SUCCESS"; //returns a JSON array of Products
    final public static String GET_PRODUCT_INFO_ERROR = "GET_PRODUCT_INFO_ERROR"; //returns a String

    // response to makePurchase
    final public static String MAKE_PURCHASE_SUCCESS = "MAKE_PURCHASE_SUCCESS"; // returns a JSON array of Purchase objects
    final public static String MAKE_PURCHASE_ERROR = "MAKE_PURCHASE_ERROR"; // returns a JSON object with "error" and "message" fields

    // response to getPurchasedItems
    final public static String GET_PURCHASED_ITEMS_SUCCESS = "GET_PURCHASED_ITEMS_SUCCESS"; //returns a JSON array of Purchase objects
    final public static String GET_PURCHASED_ITEMS_ERROR = "GET_PURCHASED_ITEMS_ERROR"; // returns a String

    // response to consumePurchase
    final public static String CONSUME_PURCHASE_SUCCESS = "CONSUME_PURCHASE_SUCCESS"; // returns a String
    final public static String CONSUME_PURCHASE_ERROR = "CONSUME_PURCHASE_ERROR"; // returns a String

    public enum MakePurchaseError {
        PURCHASE_ERROR_CANCELLED("PURCHASE_ERROR_CANCELLED"),
        PURCHASE_ERROR_OTHER("PURCHASE_ERROR_OTHER");

        private final String text;

        private MakePurchaseError(final String text) {
            this.text = text;
        }

        @Override
        public String toString() {
            return text;
        }
    }

    // function names
    final public static String FUNCTION_SET_ANDROID_KEY = "setAndroidKey";
    final public static String FUNCTION_GET_PRODUCT_INFO = "getProductInfo";
    final public static String FUNCTION_MAKE_PURCHASE = "makePurchase";
    final public static String FUNCTION_GET_PURCHASED_ITEMS = "getPurchasedItems";
    final public static String FUNCTION_CONSUME_PURCHASE = "consumePurchase";

}
