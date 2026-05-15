import 'package:flutter/material.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class DeleteAccountSheet extends StatefulWidget {
  const DeleteAccountSheet({super.key});

  @override
  State<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<DeleteAccountSheet> {
  late Future<ApiResponse<List<DeleteAccountReasonItem?>>> _reasonsFuture;
  final TextEditingController _otherController = TextEditingController();
  DeleteAccountReasonItem? _selectedReason;

  @override
  void initState() {
    super.initState();
    _reasonsFuture = ApiMiddleware.profile.getDeleteAccountReasons();
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _select(DeleteAccountReasonItem reason) => setState(() => _selectedReason = reason);

  void _continue() {
    final reason = _selectedReason;
    if (reason == null) return;
    final text = reason.reasonId == 6 ? _otherController.text.trim() : reason.reasonName;
    if (reason.reasonId == 6 && text.isEmpty) {
      _toast('Please specify your reason');
      return;
    }
    Navigator.pop(context);
    _confirm(context, reasonId: reason.reasonId, reason: text.isEmpty ? reason.reasonName : text);
  }

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), behavior: SnackBarBehavior.floating),
  );

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(IAMSizes.md, 0, IAMSizes.md, IAMSizes.md),
        padding: const EdgeInsets.all(IAMSizes.lg),
        decoration: _sheetDecoration(dark),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _headerIcon(),
            const SizedBox(height: IAMSizes.md),
            Text('Delete Account', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: IAMSizes.xs),
            Text("We're sorry to see you go. Please tell us why.", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: dark ? Colors.white70 : IAMColors.darkGrey)),
            const SizedBox(height: IAMSizes.lg),
            FutureBuilder<ApiResponse<List<DeleteAccountReasonItem?>>>(
              future: _reasonsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
                }
                final reasons = snapshot.data?.data;
                if (snapshot.hasError || snapshot.data?.success != true || reasons == null) {
                  return SizedBox(
                    height: 120,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.refresh, color: IAMColors.darkGrey),
                          const SizedBox(height: IAMSizes.sm),
                          Text('Failed to load reasons', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: IAMSizes.sm),
                          TextButton(onPressed: () => setState(() => _reasonsFuture = ApiMiddleware.profile.getDeleteAccountReasons()), child: const Text('Retry')),
                        ],
                      ),
                    ),
                  );
                }
                final list = reasons.whereType<DeleteAccountReasonItem>().toList();
                return Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...list.map((r) {
                          final sel = _selectedReason?.reasonId == r.reasonId;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: IAMSizes.sm),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _select(r),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: IAMSizes.md, vertical: IAMSizes.sm + 4),
                                  decoration: BoxDecoration(
                                    color: sel ? IAMColors.error.withValues(alpha: dark ? 0.20 : 0.08) : (dark ? IAMColors.black : const Color(0xFFFAF8F2)),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: sel ? IAMColors.error.withValues(alpha: 0.50) : (dark ? IAMColors.darkerGrey : const Color(0xFFF0E8D7))),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: sel ? IAMColors.error : (dark ? IAMColors.darkGrey : IAMColors.borderPrimary), width: sel ? 6 : 2)),
                                      ),
                                      const SizedBox(width: IAMSizes.md),
                                      Expanded(child: Text(r.reasonName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: sel ? FontWeight.w600 : FontWeight.w500, color: sel ? IAMColors.error : null))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        if (_selectedReason?.reasonId == 6) ...[
                          const SizedBox(height: IAMSizes.sm),
                          TextField(
                            controller: _otherController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Please tell us more...',
                              filled: true,
                              fillColor: dark ? IAMColors.black : const Color(0xFFFAF8F2),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: dark ? IAMColors.darkerGrey : const Color(0xFFF0E8D7))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: dark ? IAMColors.darkerGrey : const Color(0xFFF0E8D7))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: IAMColors.error)),
                              contentPadding: const EdgeInsets.all(IAMSizes.md),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: IAMSizes.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReason != null ? _continue : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: IAMColors.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  disabledBackgroundColor: IAMColors.error.withValues(alpha: 0.30),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIcon() => Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(color: IAMColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18)),
    child: const Icon(Iconsax.warning_2, color: IAMColors.error, size: 28),
  );

  BoxDecoration _sheetDecoration(bool dark) => BoxDecoration(
    color: dark ? IAMColors.dark : Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: dark ? IAMColors.darkerGrey : const Color(0xFFF1E8D2)),
    boxShadow: [BoxShadow(color: IAMColors.black.withValues(alpha: 0.14), blurRadius: 28, offset: const Offset(0, 16))],
  );
}

Future<void> showDeleteAccountConfirmation(BuildContext context, {required int reasonId, required String reason}) async {
  final dark = IAMHelperFunctions.isDarkMode(context);
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: dark ? IAMColors.dark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: IAMColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: const Icon(Iconsax.warning_2, color: IAMColors.error, size: 32)),
          const SizedBox(height: 20),
          Text('Are you sure?', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text('This will permanently delete your account and all associated data. This action cannot be undone.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: dark ? Colors.white70 : IAMColors.darkGrey, height: 1.4)),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), side: BorderSide(color: dark ? IAMColors.darkerGrey : const Color(0xFFE3D6AD)), foregroundColor: dark ? Colors.white : IAMColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48), backgroundColor: IAMColors.error, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Yes, Delete'),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;
  _showLoadingOverlay(context);
  final res = await ApiMiddleware.profile.deleteAccount(reasonId: reasonId, reason: reason);
  if (!context.mounted) return;
  Navigator.pop(context);
  if (res.success) {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: dark ? IAMColors.dark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 64, height: 64, decoration: BoxDecoration(color: IAMColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: const Icon(Iconsax.tick_circle, color: IAMColors.success, size: 32)),
            const SizedBox(height: 20),
            Text('Account Deleted', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('Your account has been successfully deleted.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: dark ? Colors.white70 : IAMColors.darkGrey)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { Navigator.pop(context); AuthController.instance.logout(); },
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48), backgroundColor: IAMColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message), behavior: SnackBarBehavior.floating));
  }
}

void _showLoadingOverlay(BuildContext context) {
  showDialog<void>(context: context, barrierDismissible: false, builder: (context) => const PopScope(canPop: false, child: Center(child: CircularProgressIndicator())));
}

void _confirm(BuildContext context, {required int reasonId, required String reason}) => showDeleteAccountConfirmation(context, reasonId: reasonId, reason: reason);
