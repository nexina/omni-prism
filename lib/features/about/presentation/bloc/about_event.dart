/// Events for AboutBloc
sealed class AboutEvent {
  const AboutEvent();
}

/// Launch a URL
class LaunchUrlEvent extends AboutEvent {
  final String url;

  const LaunchUrlEvent(this.url);
}