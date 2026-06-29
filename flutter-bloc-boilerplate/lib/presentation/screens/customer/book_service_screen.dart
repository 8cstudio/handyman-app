import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/presentation/blocs/handyman/handyman_cubit.dart';
import 'package:my_bloc_app/presentation/common/app_widgets.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';

class BookServiceScreen extends StatefulWidget {
  final String serviceId;
  const BookServiceScreen({super.key, required this.serviceId});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final _address = TextEditingController();
  final _notes = TextEditingController();
  DateTime _scheduledAt = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HandymanCubit>(),
      child: BlocListener<HandymanCubit, HandymanState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            context.read<HandymanCubit>().clearSuccessMessage();
            context.go(AppRoute.customerHome.path);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text(AppText.bookNow)),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AppTextField(label: AppText.address, controller: _address),
                const SizedBox(height: 16),
                AppTextField(label: AppText.notes, controller: _notes, maxLines: 3),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text(AppText.dateTime),
                  subtitle: Text(_scheduledAt.toString()),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _scheduledAt,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date == null || !mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
                    );
                    if (time != null) {
                      setState(() {
                        _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      });
                    }
                  },
                ),
                const Spacer(),
                BlocBuilder<HandymanCubit, HandymanState>(
                  builder: (context, state) {
                    return AppButton(
                      label: state.isLoading ? AppText.loading : AppText.bookNow,
                      onPressed: state.isLoading
                          ? null
                          : () => context.read<HandymanCubit>().createBooking(
                                serviceId: widget.serviceId,
                                scheduledAt: _scheduledAt,
                                address: _address.text.trim(),
                                notes: _notes.text.trim(),
                              ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerBookingsScreen extends StatelessWidget {
  const CustomerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HandymanCubit>()..loadBookings(),
      child: const Scaffold(body: Center(child: Text('Use home tab'))),
    );
  }
}
