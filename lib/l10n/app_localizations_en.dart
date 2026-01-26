// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dora Admin';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get language => 'Language';

  @override
  String get loginTitle => 'Admin Login';

  @override
  String get loginSubtitle => 'Sign in to manage your products';

  @override
  String get loginPhoneLabel => 'Phone Number';

  @override
  String get loginPhoneHint => 'username';

  @override
  String get loginPhoneError => 'Please enter your username';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordError => 'Please enter your password';

  @override
  String loginPasswordLengthError(int length) {
    return 'Password must be at least $length characters';
  }

  @override
  String get loginButton => 'Login';

  @override
  String get productsTitle => 'Products';

  @override
  String get productsSearchResults => 'Search Results';

  @override
  String get productsSearchHint => 'Search products by name...';

  @override
  String get productsSearchTooltip => 'Search products';

  @override
  String get productsCloseSearchTooltip => 'Close search';

  @override
  String productsSearchResultsCount(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'results',
      one: 'result',
    );
    return 'Found $count $_temp0 for \"$query\"';
  }

  @override
  String get productsClear => 'Clear';

  @override
  String get productsNoProductsFound => 'No products found';

  @override
  String get productsTryDifferentSearch => 'Try a different search term';

  @override
  String get productsNoProductsYet => 'No products yet';

  @override
  String get productsAddFirstProduct =>
      'Tap the + button to add your first product';

  @override
  String get productsPullToRefresh => 'Pull down to refresh';

  @override
  String get productsEndOfList => 'End of list';

  @override
  String get productsDeleteTitle => 'Delete Product';

  @override
  String productsDeleteMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get productsDeleteSuccess => 'Product deleted successfully';

  @override
  String get productsDeleteFailed => 'Failed to delete product';

  @override
  String get productsDeletingProgress => 'Deleting product...';

  @override
  String get productsEditTooltip => 'Edit';

  @override
  String get productsDeleteTooltip => 'Delete';

  @override
  String get productFormEditTitle => 'Edit Product';

  @override
  String get productFormNewTitle => 'New Product';

  @override
  String get productFormImageLabel => 'Product Image';

  @override
  String get productFormImageRequired => 'Product Image *';

  @override
  String get productFormImageError => 'Please select a product image';

  @override
  String get productFormNameLabel => 'Product Name *';

  @override
  String get productFormNameHint => 'Enter product name';

  @override
  String get productFormNameError => 'Product name is required';

  @override
  String get productFormDescriptionLabel => 'Description *';

  @override
  String get productFormDescriptionHint => 'Enter product description';

  @override
  String get productFormDescriptionError => 'Description is required';

  @override
  String get productFormPriceLabel => 'Price (Optional)';

  @override
  String get productFormPriceHint => '0.00';

  @override
  String get productFormPriceError => 'Please enter a valid price';

  @override
  String get productFormUpdateButton => 'Update Product';

  @override
  String get productFormCreateButton => 'Create Product';

  @override
  String get productFormUpdateSuccess => 'Product updated successfully';

  @override
  String get productFormCreateSuccess => 'Product created successfully';

  @override
  String get productFormNotFound => 'Product not found';

  @override
  String get productFormNotFoundMessage => 'The product may have been deleted';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsNoNotificationsYet => 'No notifications yet';

  @override
  String get notificationsAddFirst =>
      'Tap the + button to send your first notification';

  @override
  String get notificationsStatusSent => 'Sent';

  @override
  String get notificationsStatusScheduled => 'Scheduled';

  @override
  String get notificationsStatusPending => 'Pending';

  @override
  String get notificationsStatusFailed => 'Failed';

  @override
  String notificationsScheduledFor(String date, String time) {
    return 'Scheduled for $date at $time';
  }

  @override
  String notificationsSentOn(String date, String time) {
    return 'Sent on $date at $time';
  }

  @override
  String notificationsCreated(String date) {
    return 'Created: $date';
  }

  @override
  String get sendNotificationTitle => 'Send Notification';

  @override
  String get sendNotificationMessageLabel => 'Message *';

  @override
  String get sendNotificationMessageHint => 'Enter notification message';

  @override
  String get sendNotificationMessageError => 'Message is required';

  @override
  String get sendNotificationScheduleToggle => 'Schedule Notification';

  @override
  String get sendNotificationScheduledSubtitle =>
      'Notification will be sent at the selected time';

  @override
  String get sendNotificationImmediateSubtitle =>
      'Send notification immediately';

  @override
  String get sendNotificationScheduleDateLabel => 'Schedule Date & Time';

  @override
  String get sendNotificationScheduleDateHint => 'Tap to select date and time';

  @override
  String get sendNotificationScheduleDateError =>
      'Please select a date and time for scheduled notification';

  @override
  String get sendNotificationScheduleButton => 'Schedule Notification';

  @override
  String get sendNotificationSendButton => 'Send Notification';

  @override
  String get sendNotificationScheduledSuccess =>
      'Notification scheduled successfully';

  @override
  String get sendNotificationSentSuccess => 'Notification sent successfully';

  @override
  String drawerAdminId(int id) {
    return 'Admin #$id';
  }

  @override
  String get drawerAdmin => 'Admin';

  @override
  String get drawerProducts => 'Products';

  @override
  String get drawerNotifications => 'Notifications';

  @override
  String get drawerChangePassword => 'Change Password';

  @override
  String get drawerLogout => 'Logout';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordSubtitle =>
      'Update your password to keep your account secure.';

  @override
  String get changePasswordCurrentPasswordLabel => 'Current Password';

  @override
  String get changePasswordCurrentPasswordHint => 'Enter your current password';

  @override
  String get changePasswordCurrentPasswordError =>
      'Please enter your current password';

  @override
  String get changePasswordNewPasswordLabel => 'New Password';

  @override
  String get changePasswordNewPasswordHint => 'Enter a new password';

  @override
  String get changePasswordNewPasswordError => 'Please enter a new password';

  @override
  String get changePasswordNewSameAsCurrentError =>
      'New password must be different from the current password';

  @override
  String get changePasswordConfirmPasswordLabel => 'Confirm New Password';

  @override
  String get changePasswordConfirmPasswordHint => 'Re-enter the new password';

  @override
  String get changePasswordConfirmPasswordError =>
      'Please confirm your new password';

  @override
  String get changePasswordPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get changePasswordButton => 'Update Password';

  @override
  String get changePasswordSuccess => 'Password updated successfully';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonGoBack => 'Go Back';

  @override
  String get errorConnectionTimeout =>
      'Connection timeout. Please check your internet connection and try again.';

  @override
  String get errorUnableToConnect =>
      'Unable to connect. Please check your internet connection and try again.';

  @override
  String get errorRequestCancelled => 'Request was cancelled.';

  @override
  String get errorCertificate =>
      'Security certificate error. Please try again later.';

  @override
  String get errorNoInternet =>
      'No internet connection. Please check your network settings.';

  @override
  String get errorUnexpected =>
      'An unexpected error occurred. Please try again.';

  @override
  String get errorInvalidRequest =>
      'Invalid request. Please check your input and try again.';

  @override
  String get errorSessionExpired => 'Session expired. Please log in again.';

  @override
  String get errorPermissionDenied =>
      'You do not have permission to perform this action.';

  @override
  String get errorNotFound => 'The requested resource was not found.';

  @override
  String get errorTooManyRequests =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get errorServerError => 'Server error. Please try again later.';

  @override
  String get errorGeneric => 'An error occurred. Please try again.';

  @override
  String get errorLoginFailed => 'Login failed. Please try again.';

  @override
  String get errorNoRefreshToken =>
      'No refresh token available. Please login again.';

  @override
  String get errorTokenRefreshFailed =>
      'Token refresh failed. Please login again.';

  @override
  String get imagePickerChooseSource => 'Choose Image Source';

  @override
  String get imagePickerCamera => 'Camera';

  @override
  String get imagePickerGallery => 'Gallery';

  @override
  String get productFormFeaturedLabel => 'Featured';
}
