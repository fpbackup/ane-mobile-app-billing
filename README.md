Adobe AIR native extension (ANE) to use in app billing for iOS and Android.
===========================================================================

About
----

This native extension adds support for the full purchase flow of in app purchases on iOS and Android. 
Note: Subscriptions are not supported and have not been tested, but they might still work.

How to use
----

First Add the native extension to your project:

Add `mobile-billing-ane/target/mobile-billing.ane` as a dependency to your app.    
In your project's application descriptor add the following under the `<extensions>` node:     


    <extensionID>com.funkypanda.mobile-billing</extensionID>


Add the following for Android (only add to the existing elements, e.g. do not create two manifestAdditions nodes):


    <android>
        <manifestAdditions>
            <![CDATA[
				<manifest>

                    <uses-permission android:name="android.permission.INTERNET"/>
                    <uses-permission android:name="com.android.vending.BILLING" />

                    <application>
			        
                        <activity android:name="com.funkypanda.mobilebilling.activity.PurchaseActivity" 
                                  android:label=""
                                  android:theme="@android:style/Theme.Translucent.NoTitleBar.Fullscreen"/>
                                  
                    </application>
				</manifest>
			]]>
        </manifestAdditions>
    </android>
    
The ANE is now ready to use. For a reference of the API see the source of com.funkypanda.mobilebilling.InAppPayments.as

For a complete working application check out the `testapp` folder.    

How to test payments working with the testing application
----

First set up your application in the Google/Apple developer console. Define here some purchases too.    

Then edit `testapp/src/main/actionscript/Constants.as`, add here your your application's public key (encoded in base64) if you are testing Android and add the product IDs that you defined in the Google Play/Apple console.  

Finally compile the test application with the same keystore/mobileProvision file as you app. Also set the same package name in the app descriptor.   



How to compile from source
----

1. run 'mvn clean install' to compile the .ANE
2. in IntelliJ's left pane right click on InAppPurchase.ane and select synchronize.
3. run or debug it.

To compile the iOS part you need to do this on a Mac with XCode installed.        
To compile the Android part you need to have the Android SDK version 15 installed. You can specify the installation location in `mobile-billing-android/pom.xml`        
You can skip the iOS/Android compilation by commenting out the submodules in the root pom.xml.

License
----

Copyright 2016 FunkypandaGame Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
