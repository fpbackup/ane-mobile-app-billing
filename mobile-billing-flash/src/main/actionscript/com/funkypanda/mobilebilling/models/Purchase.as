package com.funkypanda.mobilebilling.models
{

    public class Purchase
    {

        public var productId : String = "";
        public var quantity : int = 1;
        public var transactionDate : Date;
        public var transactionId : String = "";
        /** Send this receipt to consume the purchase */
        public var transactionReceipt : String = "";
        public var rawData : Object;

        public function toString() : String
        {
            return "[Purchase product Id: " + productId + " transaction Id: " + transactionId + "]";
        }
    }
}
