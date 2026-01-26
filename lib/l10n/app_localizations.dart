import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Dora Admin'**
  String get appTitle;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Arabic language name in Arabic
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// Language picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Language label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get loginTitle;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your products'**
  String get loginSubtitle;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get loginPhoneLabel;

  /// Phone number field hint
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get loginPhoneHint;

  /// Phone number validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get loginPhoneError;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get loginPasswordError;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {length} characters'**
  String loginPasswordLengthError(int length);

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// Products screen title
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// Products search results title
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get productsSearchResults;

  /// Search field hint
  ///
  /// In en, this message translates to:
  /// **'Search products by name...'**
  String get productsSearchHint;

  /// Search button tooltip
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get productsSearchTooltip;

  /// Close search button tooltip
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get productsCloseSearchTooltip;

  /// Search results count message
  ///
  /// In en, this message translates to:
  /// **'Found {count} {count, plural, =1{result} other{results}} for \"{query}\"'**
  String productsSearchResultsCount(int count, String query);

  /// Clear search button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get productsClear;

  /// No products found in search
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get productsNoProductsFound;

  /// Try different search message
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get productsTryDifferentSearch;

  /// No products empty state
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get productsNoProductsYet;

  /// Add first product message
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first product'**
  String get productsAddFirstProduct;

  /// Pull to refresh hint
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get productsPullToRefresh;

  /// End of list message
  ///
  /// In en, this message translates to:
  /// **'End of list'**
  String get productsEndOfList;

  /// Delete product dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get productsDeleteTitle;

  /// Delete product confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String productsDeleteMessage(String name);

  /// Product deleted success message
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productsDeleteSuccess;

  /// Product delete failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product'**
  String get productsDeleteFailed;

  /// Deleting product progress message
  ///
  /// In en, this message translates to:
  /// **'Deleting product...'**
  String get productsDeletingProgress;

  /// Edit button tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get productsEditTooltip;

  /// Delete button tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get productsDeleteTooltip;

  /// Edit product form title
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get productFormEditTitle;

  /// New product form title
  ///
  /// In en, this message translates to:
  /// **'New Product'**
  String get productFormNewTitle;

  /// Product image label
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get productFormImageLabel;

  /// Product image label with required indicator
  ///
  /// In en, this message translates to:
  /// **'Product Image *'**
  String get productFormImageRequired;

  /// Product image validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a product image'**
  String get productFormImageError;

  /// Product name field label
  ///
  /// In en, this message translates to:
  /// **'Product Name *'**
  String get productFormNameLabel;

  /// Product name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get productFormNameHint;

  /// Product name validation error
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get productFormNameError;

  /// Product description field label
  ///
  /// In en, this message translates to:
  /// **'Description *'**
  String get productFormDescriptionLabel;

  /// Product description field hint
  ///
  /// In en, this message translates to:
  /// **'Enter product description'**
  String get productFormDescriptionHint;

  /// Product description validation error
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get productFormDescriptionError;

  /// Product price field label
  ///
  /// In en, this message translates to:
  /// **'Price (Optional)'**
  String get productFormPriceLabel;

  /// Product price field hint
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get productFormPriceHint;

  /// Product price validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get productFormPriceError;

  /// Update product button text
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get productFormUpdateButton;

  /// Create product button text
  ///
  /// In en, this message translates to:
  /// **'Create Product'**
  String get productFormCreateButton;

  /// Product update success message
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productFormUpdateSuccess;

  /// Product create success message
  ///
  /// In en, this message translates to:
  /// **'Product created successfully'**
  String get productFormCreateSuccess;

  /// Product not found error title
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productFormNotFound;

  /// Product not found error message
  ///
  /// In en, this message translates to:
  /// **'The product may have been deleted'**
  String get productFormNotFoundMessage;

  /// Notifications screen title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No notifications empty state
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsNoNotificationsYet;

  /// Add first notification message
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to send your first notification'**
  String get notificationsAddFirst;

  /// Notification status: sent
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get notificationsStatusSent;

  /// Notification status: scheduled
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get notificationsStatusScheduled;

  /// Notification status: pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get notificationsStatusPending;

  /// Notification status: failed
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get notificationsStatusFailed;

  /// Scheduled notification time message
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {date} at {time}'**
  String notificationsScheduledFor(String date, String time);

  /// Sent notification time message
  ///
  /// In en, this message translates to:
  /// **'Sent on {date} at {time}'**
  String notificationsSentOn(String date, String time);

  /// Notification created date
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String notificationsCreated(String date);

  /// Send notification screen title
  ///
  /// In en, this message translates to:
  /// **'Send Notification'**
  String get sendNotificationTitle;

  /// Notification message field label
  ///
  /// In en, this message translates to:
  /// **'Message *'**
  String get sendNotificationMessageLabel;

  /// Notification message field hint
  ///
  /// In en, this message translates to:
  /// **'Enter notification message'**
  String get sendNotificationMessageHint;

  /// Notification message validation error
  ///
  /// In en, this message translates to:
  /// **'Message is required'**
  String get sendNotificationMessageError;

  /// Schedule notification toggle label
  ///
  /// In en, this message translates to:
  /// **'Schedule Notification'**
  String get sendNotificationScheduleToggle;

  /// Scheduled notification subtitle
  ///
  /// In en, this message translates to:
  /// **'Notification will be sent at the selected time'**
  String get sendNotificationScheduledSubtitle;

  /// Immediate notification subtitle
  ///
  /// In en, this message translates to:
  /// **'Send notification immediately'**
  String get sendNotificationImmediateSubtitle;

  /// Schedule date/time label
  ///
  /// In en, this message translates to:
  /// **'Schedule Date & Time'**
  String get sendNotificationScheduleDateLabel;

  /// Schedule date/time hint
  ///
  /// In en, this message translates to:
  /// **'Tap to select date and time'**
  String get sendNotificationScheduleDateHint;

  /// Schedule date/time validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a date and time for scheduled notification'**
  String get sendNotificationScheduleDateError;

  /// Schedule notification button
  ///
  /// In en, this message translates to:
  /// **'Schedule Notification'**
  String get sendNotificationScheduleButton;

  /// Send notification button
  ///
  /// In en, this message translates to:
  /// **'Send Notification'**
  String get sendNotificationSendButton;

  /// Notification scheduled success message
  ///
  /// In en, this message translates to:
  /// **'Notification scheduled successfully'**
  String get sendNotificationScheduledSuccess;

  /// Notification sent success message
  ///
  /// In en, this message translates to:
  /// **'Notification sent successfully'**
  String get sendNotificationSentSuccess;

  /// Admin ID display
  ///
  /// In en, this message translates to:
  /// **'Admin #{id}'**
  String drawerAdminId(int id);

  /// Admin default label
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get drawerAdmin;

  /// Products menu item
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get drawerProducts;

  /// Notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get drawerNotifications;

  /// Change password menu item
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get drawerChangePassword;

  /// Logout menu item
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get drawerLogout;

  /// Change password screen title
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// Change password screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Update your password to keep your account secure.'**
  String get changePasswordSubtitle;

  /// Current password field label
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get changePasswordCurrentPasswordLabel;

  /// Current password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get changePasswordCurrentPasswordHint;

  /// Current password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get changePasswordCurrentPasswordError;

  /// New password field label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordNewPasswordLabel;

  /// New password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get changePasswordNewPasswordHint;

  /// New password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get changePasswordNewPasswordError;

  /// Validation error when new password equals current password
  ///
  /// In en, this message translates to:
  /// **'New password must be different from the current password'**
  String get changePasswordNewSameAsCurrentError;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get changePasswordConfirmPasswordLabel;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Re-enter the new password'**
  String get changePasswordConfirmPasswordHint;

  /// Confirm password validation error
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get changePasswordConfirmPasswordError;

  /// Validation error when passwords do not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get changePasswordPasswordsDoNotMatch;

  /// Change password submit button
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get changePasswordButton;

  /// Change password success message
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get changePasswordSuccess;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Go back button
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get commonGoBack;

  /// Connection timeout error
  ///
  /// In en, this message translates to:
  /// **'Connection timeout. Please check your internet connection and try again.'**
  String get errorConnectionTimeout;

  /// Unable to connect error
  ///
  /// In en, this message translates to:
  /// **'Unable to connect. Please check your internet connection and try again.'**
  String get errorUnableToConnect;

  /// Request cancelled error
  ///
  /// In en, this message translates to:
  /// **'Request was cancelled.'**
  String get errorRequestCancelled;

  /// Certificate error
  ///
  /// In en, this message translates to:
  /// **'Security certificate error. Please try again later.'**
  String get errorCertificate;

  /// No internet error
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network settings.'**
  String get errorNoInternet;

  /// Unexpected error
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorUnexpected;

  /// 400 Bad Request error
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your input and try again.'**
  String get errorInvalidRequest;

  /// 401 Unauthorized error
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get errorSessionExpired;

  /// 403 Forbidden error
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get errorPermissionDenied;

  /// 404 Not Found error
  ///
  /// In en, this message translates to:
  /// **'The requested resource was not found.'**
  String get errorNotFound;

  /// 429 Too Many Requests error
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get errorTooManyRequests;

  /// 500/502/503 Server error
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServerError;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorGeneric;

  /// Login failed error
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get errorLoginFailed;

  /// No refresh token error
  ///
  /// In en, this message translates to:
  /// **'No refresh token available. Please login again.'**
  String get errorNoRefreshToken;

  /// Token refresh failed error
  ///
  /// In en, this message translates to:
  /// **'Token refresh failed. Please login again.'**
  String get errorTokenRefreshFailed;

  /// Image picker source chooser title
  ///
  /// In en, this message translates to:
  /// **'Choose Image Source'**
  String get imagePickerChooseSource;

  /// Camera option
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get imagePickerCamera;

  /// Gallery option
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get imagePickerGallery;

  /// Featured option
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get productFormFeaturedLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
