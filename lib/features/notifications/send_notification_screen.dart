import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dora_admin/l10n/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/notifications_provider.dart';
import '../../shared/widgets/main_scaffold.dart';

class SendNotificationScreen extends ConsumerStatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  ConsumerState<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends ConsumerState<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  bool _isScheduled = false;
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final initialDate = _selectedDateTime ?? now.add(const Duration(days: 1));
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDateTime ?? now.add(const Duration(hours: 1)),
        ),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_formKey.currentState!.validate()) {
      if (_isScheduled && _selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.sendNotificationScheduleDateError),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final success = await ref.read(notificationsProvider.notifier).sendNotification(
        message: _messageController.text.trim(),
        scheduledAt: _isScheduled ? _selectedDateTime : null,
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isScheduled
                  ? l10n.sendNotificationScheduledSuccess
                  : l10n.sendNotificationSentSuccess,
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (mounted) {
        // Get error from provider state
        final error = ref.read(notificationsProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? l10n.errorUnexpected),
            backgroundColor: AppTheme.errorColor,
            action: SnackBarAction(
              label: l10n.commonRetry,
              textColor: Colors.white,
              onPressed: _handleSubmit,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return MainScaffold(
      title: l10n.sendNotificationTitle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Message field
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: l10n.sendNotificationMessageLabel,
                  hintText: l10n.sendNotificationMessageHint,
                  prefixIcon: const Icon(Icons.message_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                maxLength: AppConstants.maxNotificationMessageLength,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.sendNotificationMessageError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Schedule toggle
              Card(
                child: SwitchListTile(
                  title: Text(l10n.sendNotificationScheduleToggle),
                  subtitle: Text(
                    _isScheduled
                        ? l10n.sendNotificationScheduledSubtitle
                        : l10n.sendNotificationImmediateSubtitle,
                  ),
                  value: _isScheduled,
                  onChanged: (value) {
                    setState(() {
                      _isScheduled = value;
                      if (!value) {
                        _selectedDateTime = null;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Date/Time picker (if scheduled)
              if (_isScheduled) ...[
                Card(
                  child: InkWell(
                    onTap: _selectDateTime,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.sendNotificationScheduleDateLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedDateTime != null
                                      ? '${dateFormat.format(_selectedDateTime!)} at ${timeFormat.format(_selectedDateTime!)}'
                                      : l10n.sendNotificationScheduleDateHint,
                                  style: TextStyle(
                                    color: _selectedDateTime != null
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isScheduled ? l10n.sendNotificationScheduleButton : l10n.sendNotificationSendButton,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
