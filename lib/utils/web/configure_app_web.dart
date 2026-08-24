/// Web bootstrap — keep default hash URLs.
///
/// Path URL strategy + GetX widget routes (`Get.offAll(() => NavigationMenu())`)
/// makes the browser request `/NavigationMenu`, which Flutter cannot resolve
/// as an initial named route. Hash URLs avoid that entirely and still work on
/// IIS / Vercel / Render SPA hosts.
void configureApp() {}
