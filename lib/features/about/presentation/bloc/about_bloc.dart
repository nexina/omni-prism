import 'package:flutter_bloc/flutter_bloc.dart';
import 'about_event.dart';
import 'about_state.dart';

/// BLoC for the About page
class AboutBloc extends Bloc<AboutEvent, AboutState> {
  AboutBloc() : super(const AboutState()) {
    on<LaunchUrlEvent>(_onLaunchUrl);
  }

  Future<void> _onLaunchUrl(LaunchUrlEvent event, Emitter<AboutState> emit) async {
    // URL launching is handled by the UI directly
  }
}