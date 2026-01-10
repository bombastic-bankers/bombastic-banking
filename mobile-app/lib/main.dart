import 'package:bombastic_banking/repositories/atm_repository.dart';
import 'package:bombastic_banking/repositories/auth_repository.dart';
import 'package:bombastic_banking/repositories/nfc_repository.dart';
import 'package:bombastic_banking/repositories/user_repository.dart';
import 'package:bombastic_banking/repositories/transaction_repository.dart';
import 'package:bombastic_banking/route_observer.dart';
import 'package:bombastic_banking/services/atm_service.dart';
import 'package:bombastic_banking/services/nfc_service.dart';
import 'package:bombastic_banking/services/user_service.dart';
import 'package:bombastic_banking/services/transaction_service.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';
import 'package:bombastic_banking/ui/atm_services/deposit_confirmation/deposit_confirmation_viewmodel.dart';
import 'package:bombastic_banking/ui/atm_services/deposit_start/deposit_start_viewmodel.dart';
import 'package:bombastic_banking/ui/atm_services/nfc_prompt/nfc_prompt_viewmodel.dart';
import 'package:bombastic_banking/ui/atm_services/withdraw_amount/withdraw_amount_viewmodel.dart';
import 'package:bombastic_banking/ui/home/home_viewmodel.dart';
import 'package:bombastic_banking/ui/transactions/transactions_viewmodel.dart';
import 'package:bombastic_banking/ui/login/login_viewmodel.dart';
import 'package:bombastic_banking/ui/navbar_root/navbar_root_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'ui/login/login_screen.dart';
import 'services/auth_service.dart';
import 'app_constants.dart';

Future main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BankApp());
}

class BankApp extends StatefulWidget {
  const BankApp({super.key});

  @override
  State<BankApp> createState() => _BankAppState();
}

class _BankAppState extends State<BankApp> {
  final _secureStorage = DefaultSecureStorage();
  final _nfcService = NFCService();

  late final _authRepo = AuthRepository(
    authService: AuthService(baseUrl: apiBaseUrl),
    secureStorage: _secureStorage,
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavbarRootViewModel()),
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(authRepository: _authRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(userRepository: _userRepo),
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
      ],
      child: MaterialApp(
        title: 'Bombastic Banking',
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: brandRed,
            dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          ),
          useMaterial3: true,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
