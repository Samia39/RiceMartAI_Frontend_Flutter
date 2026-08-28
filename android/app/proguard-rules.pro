# Flutter Stripe / Stripe SDK ProGuard & R8 rules
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.stripe.android.**
-keep class com.stripe.android.** { *; }
