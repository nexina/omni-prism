#include "my_application.h"

#include <glib.h>

// Sets environment parameters before GTK and the Flutter engine start, since
// both read them only once during initialization. Values already set by the
// caller are never overridden.
static void setup_environment() {
  // Use a custom fontconfig file if one exists, e.g. to limit the font set.
  // OMNI_PRISM_FONTS_CONF overrides the default location.
  const gchar* fonts_conf = g_getenv("OMNI_PRISM_FONTS_CONF");
  g_autofree gchar* default_fonts_conf = g_build_filename(
      g_get_user_config_dir(), "omni-prism", "fonts.conf", nullptr);
  if (fonts_conf == nullptr) {
    fonts_conf = default_fonts_conf;
  }
  if (g_file_test(fonts_conf, G_FILE_TEST_IS_REGULAR)) {
    g_setenv("FONTCONFIG_FILE", fonts_conf, FALSE);
  }
}

int main(int argc, char** argv) {
  setup_environment();
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
