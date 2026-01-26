import 'package:bombastic_banking/repositories/atm_repository.dart';
import 'package:bombastic_banking/repositories/auth_repository.dart';
import 'package:bombastic_banking/repositories/nfc_repository.dart';
import 'package:bombastic_banking/repositories/user_repository.dart';
import 'package:bombastic_banking/repositories/transaction_repository.dart';
import 'package:bombastic_banking/repositories/verification_repository.dart';
import 'package:bombastic_banking/repositories/agent_repository.dart';
import 'package:bombastic_banking/route_observer.dart';
import 'package:bombastic_banking/services/atm_service.dart';
import 'package:bombastic_banking/services/biometric_service.dart';
import 'package:bombastic_banking/services/nfc_service.dart';
import 'package:bombastic_banking/services/user_service.dart';
import 'package:bombastic_banking/services/transaction_service.dart';
import 'package:bombastic_banking/services/verification_service.dart';
import 'package:bombastic_banking/services/transfer_service.dart';
import 'package:bombastic_banking/services/agent_service.dart';
import 'package:bombastic_banking/services/permission_service.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';
import 'package:bombastic_banking/ui/atm_services/deposit_confirmation/deposit_confirmation_viewmodel.dart';
import 'package:bombastic_banking/ui/atm_services/deposit_start/deposit_start_viewmodel.dart';
import 'package:bombastic_banking/ui/atm_services/nfc_prompt/nfc_prompt_viewmodel.dart';
import 'package:bombastic_banking/ui/atm_services/withdraw_amount/withdraw_amount_viewmodel.dart';
import 'package:bombastic_banking/ui/home/home_viewmodel.dart';
import 'package:bombastic_banking/ui/transactions/transactions_viewmodel.dart';
import 'package:bombastic_banking/ui/login/login_viewmodel.dart';
import 'package:bombastic_banking/ui/navbar_root/navbar_root_viewmodel.dart';
import 'package:bombastic_banking/ui/signup/signup_form/signup_viewmodel.dart';
import 'package:bombastic_banking/ui/signup/sms_otp/sms_otp_viewmodel.dart';
import 'package:bombastic_banking/ui/signup/email_verification/email_verification_viewmodel.dart';
import 'package:bombastic_banking/ui/signup/signup_pin/signup_pin_viewmodel.dart';
import 'package:bombastic_banking/ui/signup/email_verification/email_verification_screen.dart';
import 'package:bombastic_banking/ui/signup/sms_otp/sms_otp_screen.dart';
import 'package:bombastic_banking/storage/signup_storage.dart';
import 'package:bombastic_banking/ui/profile/profile_viewmodel.dart';
import 'package:bombastic_banking/repositories/profile_repository.dart';
import 'package:bombastic_banking/services/profile_service.dart';
import 'package:bombastic_banking/ui/Agent/agent_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'ui/login/login_screen.dart';
import 'services/auth_service.dart';
import 'services/session_manager.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'app_constants.dart';

final locator = GetIt.instance;
void setupLocator() {
  locator.registerLazySingleton<NFCService>(() => NFCService());
}

Future main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setupLocator();
  runApp(const BankApp());
}

class BankApp extends StatefulWidget {
  const BankApp({super.key});
  @override
  State<BankApp> createState() => _BankAppState();
}

class _BankAppState extends State<BankApp> {
  final _secureStorage = DefaultSecureStorage();
  final _nfcService = locator<NFCService>();
  late final AgentViewmodel _agentViewmodel;
  final _biometricService = BiometricService();
  final _navigatorKey = GlobalKey<NavigatorState>();

  late final _transferService = TransferService(baseUrl: apiBaseUrl);

  late final _authRepo = AuthRepository(
    authService: AuthService(baseUrl: apiBaseUrl),
    secureStorage: _secureStorage,
    biometricService: _biometricService,
  );
  late final _userRepo = UserRepository(
    userService: UserService(baseUrl: apiBaseUrl),
    secureStorage: _secureStorage,
  );
  late final _transactionRepo = TransactionRepository(
    transactionsService: TransactionsService(baseUrl: apiBaseUrl),
    secureStorage: _secureStorage,
  );
  late final _nfcRepo = NFCRepository(
    nfcService: _nfcService,
    tagMatcher: atmTagMatcher,
  );
  late final _atmRepository = ATMRepository(
    atmService: ATMService(baseUrl: apiBaseUrl),
    secureStorage: _secureStorage,
  );
  late final _verificationRepo = VerificationRepository(
    verificationService: VerificationService(baseUrl: apiBaseUrl),
    secureStorage: _secureStorage,
  );
  late final _signupStorage = DefaultSignupStorage();
  late final _sessionManager = SessionManager(
    getSessionExpiry: () async {
      final accessToken = await _secureStorage.getSessionToken();
      if (accessToken == null) return null;

      try {
        // Decode JWT to extract expiration time
        final decodedToken = Jwt.parseJwt(accessToken);
        final exp = decodedToken['exp'] as int?;
        if (exp == null) return null;

        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      } catch (e) {
        debugPrint('Error decoding access token: $e');
        return null;
      }
    },
    onRefreshSession: () async {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;
      return await _authRepo.loginWithRefreshToken(refreshToken);
    },
    onSessionEnd: (reason) async {
      // Clear only the session token (preserve refresh token for biometric login)
      await _secureStorage.deleteSessionToken();

      final context = _navigatorKey.currentContext;
      if (context != null && context.mounted) {
        final message = switch (reason) {
          SessionEndReason.inactivity => 'Session timed out due to inactivity',
          SessionEndReason.refreshFailed => null,
        };

        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      // Navigate to login screen
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (_) => false,
      );
    },
  );

  late final _agentRepo = TokenRepository(
    tokenService: TokenService(baseUrl: apiBaseUrl),
    secureStorage: _secureStorage,
  );
  @override
  void initState() {
    super.initState();

    _agentViewmodel = AgentViewmodel(
      tokenRepository: _agentRepo,
      permissionService: PermissionService(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _authRepo),
        Provider.value(value: _sessionManager),
        Provider.value(value: _signupStorage as SignupStorage),
        Provider.value(value: _transferService),
        ChangeNotifierProvider(create: (_) => NavbarRootViewModel()),
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(
            authRepository: _authRepo,
            sessionManager: _sessionManager,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(
            repository: ProfileRepository(
              profileService: ProfileService(baseUrl: apiBaseUrl),
              secureStorage: _secureStorage,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(
            userRepository: _userRepo,
            sessionManager: _sessionManager,
            secureStorage: _secureStorage,
            transactionRepository: _transactionRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              TransactionsViewModel(transactionRepository: _transactionRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => NFCPromptViewModel(nfcRepository: _nfcRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => WithdrawAmountViewModel(atmRepository: _atmRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => DepositStartViewModel(atmRepository: _atmRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DepositConfirmationViewModel(atmRepository: _atmRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SignupViewModel(signupStorage: _signupStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => SMSOTPViewModel(
            verificationRepository: _verificationRepo,
            signupStorage: _signupStorage,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SignupPinViewModel(
            authRepository: _authRepo,
            sessionManager: _sessionManager,
            signupStorage: _signupStorage,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EmailVerificationViewModel(
            verificationRepository: _verificationRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AgentViewmodel(
            tokenRepository: _agentRepo,
            permissionService: PermissionService(),
          ),
        ),
        Provider.value(value: _sessionManager),
      ],
      child: GestureDetector(
        onTap: () => _sessionManager.recordActivity(),
        onPanDown: (_) => _sessionManager.recordActivity(),
        onScaleStart: (_) => _sessionManager.recordActivity(),
        child: MaterialApp(
          title: 'Bombastic Banking',
          navigatorKey: _navigatorKey,
          navigatorObservers: [routeObserver],
          theme: ThemeData(
            scaffoldBackgroundColor: Theme.of(context).colorScheme.surface,
            appBarTheme: AppBarTheme(
              backgroundColor: Theme.of(context).colorScheme.surface,
              titleTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xFFE50513),
              onPrimary: Color(0xFFF9F5F6),
              secondary: Color(0xFF5D6BD4),
              onSecondary: Color(0xFFDDDFEC),
              error: Colors.red,
              onError: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF232125),
              tertiary: Color(0xFF3EB489),
            ),
            useMaterial3: true,
          ),
          home: FutureBuilder<SignupStage>(
            future: () async {
              return await _signupStorage.getSignupStage();
            }(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final stage = snapshot.data!;
              return switch (stage) {
                SignupStage.emailVerification => FutureBuilder<SignupData?>(
                  future: () async {
                    return await _signupStorage.getSignupData();
                  }(),
                  builder: (context, dataSnapshot) {
                    if (!dataSnapshot.hasData) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final signupData = dataSnapshot.data;
                    if (signupData == null) {
                      return LoginScreen();
                    }
                    return FutureBuilder<void>(
                      future: _sessionManager.startMonitoring(
                        ignoreInactivityTimeout: true,
                        attemptRefreshNow: true,
                      ),
                      builder: (context, _) {
                        return EmailVerificationScreen(email: signupData.email);
                      },
                    );
                  },
                ),
                SignupStage.smsOtp => FutureBuilder<void>(
                  future: _sessionManager.startMonitoring(
                    ignoreInactivityTimeout: true,
                    attemptRefreshNow: true,
                  ),
                  builder: (context, _) {
                    return const SMSOTPScreen();
                  },
                ),
                SignupStage.none => LoginScreen(),
              };
            },
          ),
        ),
      ),
    );
  }
}
