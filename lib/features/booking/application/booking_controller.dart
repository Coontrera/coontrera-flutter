import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_time_formatters.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/service.dart';
import '../../../data/models/time_slot.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/repositories/repository_exceptions.dart';
import '../../auth/application/auth_controller.dart';

class BookingState {
  const BookingState({
    this.step = 0,
    this.selectedService,
    this.selectedDate,
    this.selectedTime,
    this.notes = '',
    this.slots = const AsyncValue.data([]),
    this.isSubmitting = false,
    this.submitError,
    this.confirmedAppointment,
  });

  final int step;
  final Service? selectedService;
  final DateTime? selectedDate;
  final String? selectedTime;
  final String notes;
  final AsyncValue<List<TimeSlot>> slots;
  final bool isSubmitting;
  final String? submitError;
  final Appointment? confirmedAppointment;

  bool get canGoToStep2 => selectedService != null;
  bool get canGoToStep3 => selectedDate != null && selectedTime != null;

  BookingState copyWith({
    int? step,
    Service? selectedService,
    DateTime? selectedDate,
    String? selectedTime,
    bool clearSelectedTime = false,
    String? notes,
    AsyncValue<List<TimeSlot>>? slots,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    Appointment? confirmedAppointment,
  }) {
    return BookingState(
      step: step ?? this.step,
      selectedService: selectedService ?? this.selectedService,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: clearSelectedTime ? null : (selectedTime ?? this.selectedTime),
      notes: notes ?? this.notes,
      slots: slots ?? this.slots,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      confirmedAppointment: confirmedAppointment ?? this.confirmedAppointment,
    );
  }
}

class BookingController extends StateNotifier<BookingState> {
  BookingController(this.ref) : super(const BookingState());

  final Ref ref;

  void selectService(Service service) {
    state = state.copyWith(selectedService: service, step: 1);
  }

  Future<void> selectDate(DateTime date) async {
    final day = AppDateFormat.stripTime(date);
    state = state.copyWith(
      selectedDate: day,
      clearSelectedTime: true,
      slots: const AsyncValue.loading(),
    );
    try {
      final slots = await ref.read(availabilityRepositoryProvider).getAvailableSlots(day);
      if (state.selectedDate != day) return;
      state = state.copyWith(slots: AsyncValue.data(slots));
    } catch (e, st) {
      state = state.copyWith(slots: AsyncValue.error(e, st));
    }
  }

  void selectTime(String time) {
    state = state.copyWith(selectedTime: time, step: 2);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void goToStep(int step) {
    state = state.copyWith(step: step);
  }

  Future<void> confirm() async {
    final service = state.selectedService;
    final date = state.selectedDate;
    final time = state.selectedTime;
    final user = ref.read(authControllerProvider).valueOrNull;
    if (service == null || date == null || time == null || user == null) return;

    state = state.copyWith(isSubmitting: true, clearSubmitError: true);
    try {
      final appointment = await ref.read(appointmentRepositoryProvider).book(
            clientId: user.id,
            serviceId: service.id,
            date: date,
            timeSlot: time,
            notes: state.notes.isEmpty ? null : state.notes,
          );
      state = state.copyWith(isSubmitting: false, confirmedAppointment: appointment);
    } on BookingException catch (e) {
      state = state.copyWith(isSubmitting: false, submitError: e.message);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: 'Não foi possível concluir o agendamento. Tente novamente.',
      );
    }
  }

  void reset() {
    state = const BookingState();
  }
}

final bookingControllerProvider =
    StateNotifierProvider.autoDispose<BookingController, BookingState>(
  (ref) => BookingController(ref),
);
