import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_time_formatters.dart';
import '../../../../data/models/app_user.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/service.dart';
import '../../../appointments/presentation/widgets/appointment_card.dart';

class DayAppointmentsList extends StatelessWidget {
  const DayAppointmentsList({
    super.key,
    required this.date,
    required this.appointments,
    required this.servicesById,
    required this.clientsById,
    required this.onTapAppointment,
  });

  final DateTime date;
  final List<Appointment> appointments;
  final Map<String, Service> servicesById;
  final Map<String, AppUser> clientsById;
  final void Function(Appointment) onTapAppointment;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppDateFormat.dayMonthYear.format(date),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpace.md),
            if (appointments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpace.lg),
                child: Text('Nenhum agendamento neste dia.'),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: appointments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpace.sm),
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final client = clientsById[appointment.clientId];
                    return AppointmentCard(
                      appointment: appointment,
                      service: servicesById[appointment.serviceId],
                      subtitle: client?.name,
                      onTap: () => onTapAppointment(appointment),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
