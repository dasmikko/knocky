import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../services/knockout_api_service.dart';
import '../services/settings_service.dart';

/// Login provider configuration
class _LoginProvider {
  final String name;
  final String provider;
  final IconData icon;
  final Color color;

  const _LoginProvider({
    required this.name,
    required this.provider,
    required this.icon,
    required this.color,
  });
}

const _loginProviders = [
  _LoginProvider(
    name: 'Google',
    provider: 'google',
    icon: FontAwesomeIcons.google,
    color: Color(0xFFDB4437),
  ),
  _LoginProvider(
    name: 'Twitter',
    provider: 'twitter',
    icon: FontAwesomeIcons.xTwitter,
    color: Color(0xFF1DA1F2),
  ),
  _LoginProvider(
    name: 'GitHub',
    provider: 'github',
    icon: FontAwesomeIcons.github,
    color: Color(0xFF333333),
  ),
  _LoginProvider(
    name: 'Steam',
    provider: 'steam',
    icon: FontAwesomeIcons.steam,
    color: Color(0xFF1B2838),
  ),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggingIn = false;
  final _jwtController = TextEditingController();

  @override
  void dispose() {
    _jwtController.dispose();
    super.dispose();
  }

  Future<void> _loginWithJwt() async {
    final jwt = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter JWT Token'),
        content: TextField(
          controller: _jwtController,
          decoration: const InputDecoration(
            hintText: 'Paste your JWT token here',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final token = _jwtController.text.trim();
              if (token.isNotEmpty) {
                Navigator.pop(context, token);
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );

    _jwtController.clear();

    if (jwt != null && jwt.isNotEmpty && mounted) {
      setState(() => _isLoggingIn = true);

      final apiService = context.read<KnockoutApiService>();
      await apiService.setToken(jwt);

      try {
        await apiService.getSyncData();
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          Navigator.pop(context);
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Login successful!'),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      } catch (e) {
        await apiService.clearToken();
        if (mounted) {
          setState(() => _isLoggingIn = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invalid token or login failed'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }

  Future<void> _loginWithProvider(_LoginProvider provider) async {
    if (_isLoggingIn) return;

    setState(() => _isLoggingIn = true);

    final jwt = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => _WebViewLoginScreen(provider: provider.provider),
      ),
    );

    if (!mounted) return;
    setState(() => _isLoggingIn = false);

    if (jwt != null && jwt.isNotEmpty) {
      final apiService = context.read<KnockoutApiService>();
      await apiService.setToken(jwt);
      try {
        await apiService.getSyncData();
      } catch (_) {
        // Sync data fetch is best-effort; token is already saved
      }

      if (mounted) {
        // Capture ScaffoldMessenger before popping (it uses root scaffold)
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Login successful!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final apiService = context.read<KnockoutApiService>();
    await apiService.clearToken();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logged out'),
          backgroundColor: Colors.blueGrey.shade700,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = context.watch<KnockoutApiService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign in with',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ..._loginProviders.map((provider) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProviderButton(
                provider: provider,
                onPressed: _isLoggingIn ? null : () => _loginWithProvider(provider),
                isLoading: _isLoggingIn,
              ),
            )),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('or'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isLoggingIn ? null : _loginWithJwt,
              icon: const Icon(Icons.key),
              label: const Text('Login with JWT Token'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (apiService.isAuthenticated) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  final _LoginProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ProviderButton({
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDark ? provider.color.withValues(alpha: 0.8) : provider.color;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: FaIcon(provider.icon, size: 20),
      label: Text('Continue with ${provider.name}'),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _WebViewLoginScreen extends StatefulWidget {
  final String provider;

  const _WebViewLoginScreen({required this.provider});

  @override
  State<_WebViewLoginScreen> createState() => _WebViewLoginScreenState();
}

class _WebViewLoginScreenState extends State<_WebViewLoginScreen> {
  bool _isLoading = true;
  String? _error;
  bool _isExtracting = false;

  @override
  Widget build(BuildContext context) {
    final baseUrl = context.read<SettingsService>().baseUrl;
    final authUrl = '$baseUrl/auth/${widget.provider}/login';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(authUrl)),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              javaScriptEnabled: true,
              // Use a standard Chrome user agent to avoid Google blocking
              userAgent: 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36',
            ),
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
                _error = null;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() => _isLoading = false);

              // Check if we've reached the finish page
              if (url != null && url.path == '/auth/finish') {
                await _extractJwtAndClose(controller);
              }
            },
            onReceivedError: (controller, request, error) {
              setState(() {
                _isLoading = false;
                _error = error.description;
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url;

              // Check if navigating to finish page
              if (url != null && url.path == '/auth/finish') {
                // Let it load, we'll extract JWT in onLoadStop
                return NavigationActionPolicy.ALLOW;
              }

              return NavigationActionPolicy.ALLOW;
            },
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $_error', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _extractJwtAndClose(InAppWebViewController controller) async {
    // Prevent multiple extraction attempts
    if (_isExtracting) return;
    _isExtracting = true;

    try {
      // Get cookies from the api.knockout.chat domain
      final cookieManager = CookieManager.instance();
      final baseUrl = context.read<SettingsService>().baseUrl;
      final cookies = await cookieManager.getCookies(
        url: WebUri(baseUrl),
      );

      // Find the knockoutJwt cookie
      String? jwt;
      for (final cookie in cookies) {
        if (cookie.name == 'knockoutJwt') {
          jwt = cookie.value;
          break;
        }
      }

      // Clear cookies from api.knockout.chat after extracting JWT
      await cookieManager.deleteCookies(
        url: WebUri(baseUrl),
      );

      if (mounted) {
        Navigator.pop(context, jwt);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to extract token: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
