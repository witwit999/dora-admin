// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'دورا الإدارة';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get language => 'اللغة';

  @override
  String get loginTitle => 'تسجيل دخول المسؤول';

  @override
  String get loginSubtitle => 'سجل الدخول لإدارة منتجاتك';

  @override
  String get loginPhoneLabel => 'رقم الهاتف';

  @override
  String get loginPhoneHint => 'اسم المستخدم';

  @override
  String get loginPhoneError => 'الرجاء إدخال اسم المستخدم';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginPasswordError => 'الرجاء إدخال كلمة المرور';

  @override
  String loginPasswordLengthError(int length) {
    return 'يجب أن تكون كلمة المرور $length أحرف على الأقل';
  }

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get productsTitle => 'المنتجات';

  @override
  String get productsSearchResults => 'نتائج البحث';

  @override
  String get productsSearchHint => 'ابحث عن المنتجات بالاسم...';

  @override
  String get productsSearchTooltip => 'البحث عن المنتجات';

  @override
  String get productsCloseSearchTooltip => 'إغلاق البحث';

  @override
  String productsSearchResultsCount(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نتائج',
      one: 'نتيجة',
    );
    return 'تم العثور على $count $_temp0 لـ \"$query\"';
  }

  @override
  String get productsClear => 'مسح';

  @override
  String get productsNoProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get productsTryDifferentSearch => 'جرب مصطلح بحث مختلف';

  @override
  String get productsNoProductsYet => 'لا توجد منتجات بعد';

  @override
  String get productsAddFirstProduct => 'انقر على زر + لإضافة منتجك الأول';

  @override
  String get productsPullToRefresh => 'اسحب لأسفل للتحديث';

  @override
  String get productsEndOfList => 'نهاية القائمة';

  @override
  String get productsDeleteTitle => 'حذف المنتج';

  @override
  String productsDeleteMessage(String name) {
    return 'هل أنت متأكد من حذف \"$name\"؟';
  }

  @override
  String get productsDeleteSuccess => 'تم حذف المنتج بنجاح';

  @override
  String get productsDeleteFailed => 'فشل حذف المنتج';

  @override
  String get productsDeletingProgress => 'جاري حذف المنتج...';

  @override
  String get productsEditTooltip => 'تعديل';

  @override
  String get productsDeleteTooltip => 'حذف';

  @override
  String get productFormEditTitle => 'تعديل المنتج';

  @override
  String get productFormNewTitle => 'منتج جديد';

  @override
  String get productFormImageLabel => 'صورة المنتج';

  @override
  String get productFormImageRequired => 'صورة المنتج *';

  @override
  String get productFormImageError => 'الرجاء اختيار صورة للمنتج';

  @override
  String get productFormNameLabel => 'اسم المنتج *';

  @override
  String get productFormNameHint => 'أدخل اسم المنتج';

  @override
  String get productFormNameError => 'اسم المنتج مطلوب';

  @override
  String get productFormDescriptionLabel => 'الوصف *';

  @override
  String get productFormDescriptionHint => 'أدخل وصف المنتج';

  @override
  String get productFormDescriptionError => 'الوصف مطلوب';

  @override
  String get productFormPriceLabel => 'السعر (اختياري)';

  @override
  String get productFormPriceHint => '0.00';

  @override
  String get productFormPriceError => 'الرجاء إدخال سعر صحيح';

  @override
  String get productFormUpdateButton => 'تحديث المنتج';

  @override
  String get productFormCreateButton => 'إنشاء المنتج';

  @override
  String get productFormUpdateSuccess => 'تم تحديث المنتج بنجاح';

  @override
  String get productFormCreateSuccess => 'تم إنشاء المنتج بنجاح';

  @override
  String get productFormNotFound => 'المنتج غير موجود';

  @override
  String get productFormNotFoundMessage => 'قد يكون المنتج قد تم حذفه';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsNoNotificationsYet => 'لا توجد إشعارات بعد';

  @override
  String get notificationsAddFirst => 'انقر على زر + لإرسال إشعارك الأول';

  @override
  String get notificationsStatusSent => 'تم الإرسال';

  @override
  String get notificationsStatusScheduled => 'مجدول';

  @override
  String get notificationsStatusPending => 'قيد الانتظار';

  @override
  String get notificationsStatusFailed => 'فشل';

  @override
  String notificationsScheduledFor(String date, String time) {
    return 'مجدول لـ $date في $time';
  }

  @override
  String notificationsSentOn(String date, String time) {
    return 'تم الإرسال في $date في $time';
  }

  @override
  String notificationsCreated(String date) {
    return 'تم الإنشاء: $date';
  }

  @override
  String get sendNotificationTitle => 'إرسال إشعار';

  @override
  String get sendNotificationMessageLabel => 'الرسالة *';

  @override
  String get sendNotificationMessageHint => 'أدخل رسالة الإشعار';

  @override
  String get sendNotificationMessageError => 'الرسالة مطلوبة';

  @override
  String get sendNotificationScheduleToggle => 'جدولة الإشعار';

  @override
  String get sendNotificationScheduledSubtitle =>
      'سيتم إرسال الإشعار في الوقت المحدد';

  @override
  String get sendNotificationImmediateSubtitle => 'إرسال الإشعار فوراً';

  @override
  String get sendNotificationScheduleDateLabel => 'تاريخ ووقت الجدولة';

  @override
  String get sendNotificationScheduleDateHint => 'انقر لاختيار التاريخ والوقت';

  @override
  String get sendNotificationScheduleDateError =>
      'الرجاء اختيار تاريخ ووقت للإشعار المجدول';

  @override
  String get sendNotificationScheduleButton => 'جدولة الإشعار';

  @override
  String get sendNotificationSendButton => 'إرسال الإشعار';

  @override
  String get sendNotificationScheduledSuccess => 'تم جدولة الإشعار بنجاح';

  @override
  String get sendNotificationSentSuccess => 'تم إرسال الإشعار بنجاح';

  @override
  String drawerAdminId(int id) {
    return 'المسؤول #$id';
  }

  @override
  String get drawerAdmin => 'المسؤول';

  @override
  String get drawerProducts => 'المنتجات';

  @override
  String get drawerNotifications => 'الإشعارات';

  @override
  String get drawerChangePassword => 'تغيير كلمة المرور';

  @override
  String get drawerLogout => 'تسجيل الخروج';

  @override
  String get changePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get changePasswordSubtitle =>
      'قم بتحديث كلمة المرور للحفاظ على أمان حسابك.';

  @override
  String get changePasswordCurrentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get changePasswordCurrentPasswordHint => 'أدخل كلمة المرور الحالية';

  @override
  String get changePasswordCurrentPasswordError =>
      'الرجاء إدخال كلمة المرور الحالية';

  @override
  String get changePasswordNewPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get changePasswordNewPasswordHint => 'أدخل كلمة مرور جديدة';

  @override
  String get changePasswordNewPasswordError => 'الرجاء إدخال كلمة مرور جديدة';

  @override
  String get changePasswordNewSameAsCurrentError =>
      'يجب أن تكون كلمة المرور الجديدة مختلفة عن كلمة المرور الحالية';

  @override
  String get changePasswordConfirmPasswordLabel => 'تأكيد كلمة المرور الجديدة';

  @override
  String get changePasswordConfirmPasswordHint =>
      'أعد إدخال كلمة المرور الجديدة';

  @override
  String get changePasswordConfirmPasswordError =>
      'الرجاء تأكيد كلمة المرور الجديدة';

  @override
  String get changePasswordPasswordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get changePasswordButton => 'تحديث كلمة المرور';

  @override
  String get changePasswordSuccess => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonGoBack => 'رجوع';

  @override
  String get errorConnectionTimeout =>
      'انتهت مهلة الاتصال. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorUnableToConnect =>
      'تعذر الاتصال. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorRequestCancelled => 'تم إلغاء الطلب.';

  @override
  String get errorCertificate =>
      'خطأ في شهادة الأمان. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get errorNoInternet =>
      'لا يوجد اتصال بالإنترنت. يرجى التحقق من إعدادات الشبكة.';

  @override
  String get errorUnexpected => 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

  @override
  String get errorInvalidRequest =>
      'طلب غير صالح. يرجى التحقق من المدخلات والمحاولة مرة أخرى.';

  @override
  String get errorSessionExpired => 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorPermissionDenied => 'ليس لديك إذن لتنفيذ هذا الإجراء.';

  @override
  String get errorNotFound => 'المورد المطلوب غير موجود.';

  @override
  String get errorTooManyRequests =>
      'عدد كبير جداً من الطلبات. يرجى الانتظار لحظة والمحاولة مرة أخرى.';

  @override
  String get errorServerError =>
      'خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get errorGeneric => 'حدث خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get errorLoginFailed => 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNoRefreshToken =>
      'لا يوجد رمز تحديث. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorTokenRefreshFailed =>
      'فشل تحديث الرمز. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get imagePickerChooseSource => 'اختر مصدر الصورة';

  @override
  String get imagePickerCamera => 'الكاميرا';

  @override
  String get imagePickerGallery => 'المعرض';

  @override
  String get productFormFeaturedLabel => 'مميز';
}
