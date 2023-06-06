import 'package:aad_b2c_webview/aad_b2c_webview.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

onRedirect(BuildContext context) {
  Navigator.pushNamed(context, '/');
}

class MyApp extends StatelessWidget {
  static const authFlowUrl = '<user_flow_endpoint>';
  static const redirectUrl = '<redirect_url>';

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: const Color(0xFF2F56D2),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            fontFamily: 'UberMove',
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF8A8A8A),
            fontSize: 17,
            fontWeight: FontWeight.w400,
            fontFamily: 'UberMoveText',
          ),
          displayMedium: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontFamily: 'UberMove',
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the Create Account widget.

        '/': (context) => const LoginPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? jwtToken;
  String? refreshToken;

  @override
  Widget build(BuildContext context) {
    const aadB2CClientID = "{client id}";
    const aadB2CRedirectURL = "{redirect_url}";
    const aadB2CUserFlowName = "B2C_1_{flow name}";
    const aadB2CScopes = ['openid', 'offline_access'];
    const aadB2TenantName =
        "{tenantName}"; //don't include .onmicrosoft.com in last"
    const aadB2CUserAuthFlow =
        "https://$aadB2TenantName.b2clogin.com/$aadB2TenantName.onmicrosoft.com";

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Login flow
            AADLoginButton(
              userFlowUrl: aadB2CUserAuthFlow,
              clientId: aadB2CClientID,
              userFlowName: aadB2CUserFlowName,
              redirectUrl: aadB2CRedirectURL,
              context: context,
              scopes: aadB2CScopes,
              onAnyTokenRetrieved: (Token anyToken) {},
              onIDToken: (Token token) {
                jwtToken = token.value;
              },
              onAccessToken: (Token token) {},
              onRefreshToken: (Token token) {
                refreshToken = token.value;
              },
              onRedirect: (context) => {},
            ),

            /// Refresh token
            TextButton(
              onPressed: () async {
                if (refreshToken != null) {
                  AzureTokenResponse? response =
                      await ClientAuthentication.refreshTokens(
                    refreshToken: refreshToken!,
                    tenant: aadB2TenantName,
                    policy: aadB2CUserFlowName,
                    clientId: aadB2CClientID,
                  );
                  if (response != null) {
                    refreshToken = response.refreshToken;
                    jwtToken = response.idToken;
                  }
                }
              },
              child: const Text("Refresh my token"),
            )
          ],
        ),
      ),
    );
  }
}
