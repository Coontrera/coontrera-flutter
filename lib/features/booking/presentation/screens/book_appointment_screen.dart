import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../application/booking_controller.dart';
import '../widgets/confirm_step.dart';
import '../widgets/date_picker_step.dart';
import '../widgets/service_picker_step.dart';
import '../widgets/time_slot_grid.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key, this.preselectedServiceId});

  final String? preselectedServiceId;

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  final _notesController = TextEditingController();
  bool _preselectApplied = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);
    final servicesAsync = ref.watch(servicesListProvider);

    if (!_preselectApplied && widget.preselectedServiceId != null) {
      servicesAsync.whenData((services) {
        final match = services.where((s) => s.id == widget.preselectedServiceId);
        if (match.isNotEmpty && !_preselectApplied) {
          _preselectApplied = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.selectService(match.first);
          });
        }
      });
    }

    ref.listen(bookingControllerProvider, (previous, next) {
      if (previous?.confirmedAppointment == null && next.confirmedAppointment != null) {
        _showSuccessAndExit(context, controller);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Consulta'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.canPop() ? context.pop() : context.go(RoutePaths.home),
        ),
      ),
      body: Column(
        children: [
          _StepProgress(currentStep: state.step),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
                      .animate(animation),
                  child: child,
                ),
              ),
              child: _buildStep(context, state, controller, servicesAsync),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    BookingState state,
    BookingController controller,
    AsyncValue servicesAsync,
  ) {
    switch (state.step) {
      case 0:
        return KeyedSubtree(
          key: const ValueKey('step0'),
          child: servicesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Erro ao carregar serviços: $e')),
            data: (services) => ServicePickerStep(
              services: services,
              selectedServiceId: state.selectedService?.id,
              onSelect: controller.selectService,
            ),
          ),
        );
      case 1:
        return KeyedSubtree(
          key: const ValueKey('step1'),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DatePickerStep(
                  selectedDate: state.selectedDate,
                  onDateSelected: controller.selectDate,
                ),
                if (state.selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horários disponíveis',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpace.sm),
                        state.slots.when(
                          loading: () =>
                              const Center(child: Padding(
                                padding: EdgeInsets.all(AppSpace.lg),
                                child: CircularProgressIndicator(),
                              )),
                          error: (e, st) => Text('Erro ao carregar horários: $e'),
                          data: (slots) => TimeSlotGrid(
                            slots: slots,
                            selectedTime: state.selectedTime,
                            onSelect: controller.selectTime,
                          ),
                        ),
                        const SizedBox(height: AppSpace.xl),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      case 2:
        final service = state.selectedService;
        final date = state.selectedDate;
        final time = state.selectedTime;
        if (service == null || date == null || time == null) {
          return const KeyedSubtree(key: ValueKey('step2-empty'), child: SizedBox.shrink());
        }
        return KeyedSubtree(
          key: const ValueKey('step2'),
          child: ConfirmStep(
            service: service,
            date: date,
            time: time,
            notesController: _notesController,
            isSubmitting: state.isSubmitting,
            errorMessage: state.submitError,
            onConfirm: controller.confirm,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showSuccessAndExit(BuildContext context, BookingController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SuccessDialog(
        onDone: () {
          Navigator.of(dialogContext).pop();
          controller.reset();
          context.pushReplacement(RoutePaths.myAppointments);
        },
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep});

  final int currentStep;

  static const _labels = ['Serviço', 'Data e Horário', 'Confirmar'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.sm),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final isActive = index <= currentStep;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index <= currentStep ? colors.primary : colors.border,
                        ),
                      ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? colors.primary : colors.border,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isActive ? colors.onPrimary : colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (index < _labels.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index < currentStep ? colors.primary : colors.border,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _labels[index],
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: colors.success, size: 44),
            ).animate().scale(duration: 450.ms, curve: Curves.elasticOut),
            const SizedBox(height: AppSpace.lg),
            Text('Agendamento realizado!', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpace.sm),
            const Text(
              'Sua consulta foi registrada como pendente de confirmação. Você pode '
              'acompanhar o status em Meus Agendamentos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpace.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: onDone, child: const Text('Ver meus agendamentos')),
            ),
          ],
        ),
      ),
    );
  }
}
