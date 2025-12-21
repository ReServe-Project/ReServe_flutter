import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:reserve_mobile/core/auth/auth_provider.dart';
import 'package:reserve_mobile/features/blog/providers/blog_provider.dart';

import 'package:reserve_mobile/main.dart';

void main() {
  testWidgets('App boots (smoke)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProxyProvider<AuthProvider, BlogProvider>(
            create: (_) => BlogProvider(client: AuthProvider().request),
            update: (context, authProvider, blogProvider) =>
                BlogProvider(client: authProvider.request),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Let the first frame + any scheduled work run.
    await tester.pump();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
