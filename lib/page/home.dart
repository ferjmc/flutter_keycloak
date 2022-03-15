import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _clientId = 'backend-universitario';
  static const String _issuer =
      'https://auth.bitsports-dev.co/realms/universitario';
  final List<String> _scopes = <String>['openid', 'email', 'offline_access'];
  String logoutUrl = 'https://core.bitsports-dev.co/oauth/logout';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bitsports"),
      ),
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text("Login"),
                onPressed: () async {
                  var tokenInfo = await authenticate(
                      Uri.parse(_issuer), _clientId, _scopes);
                  print(tokenInfo.accessToken);
                },
              ),
              ElevatedButton(
                  onPressed: () async {
                    logout();
                  },
                  child: const Text("Logout")),
            ],
          ),
        ),
      ),
    );
  }

  Future<TokenResponse> authenticate(
      Uri uri, String clientId, List<String> scopes) async {
    // create the client
    var issuer = await Issuer.discover(uri);
    var client = Client(issuer, clientId, clientSecret: 'SECRET');

    // create a function to open a browser with an url
    urlLauncher(String url) async {
      await launch(url, forceWebView: true);
    }

    // create an authenticator
    var authenticator = Authenticator(client,
        scopes: scopes, port: 4000, urlLancher: urlLauncher);

    // starts the authentication
    var c = await authenticator.authorize();

    // close the webview when finished
    closeWebView();

    var res = await c.getTokenResponse();
    setState(() {
      logoutUrl = c.generateLogoutUrl().toString();
    });
    print(res.accessToken);
    // return the user info
    return res;
  }

  Future<void> logout() async {
    if (await canLaunch(logoutUrl)) {
      await launch(logoutUrl, forceWebView: true);
    } else {
      throw 'Could not launch $logoutUrl';
    }
    await Future.delayed(const Duration(seconds: 3));
    closeWebView();
  }
}
