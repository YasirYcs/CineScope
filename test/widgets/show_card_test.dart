import 'package:cinescope/core/theme/app_theme.dart';
import 'package:cinescope/data/models/show.dart';
import 'package:cinescope/presentation/widgets/show_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final show = Show(
    id: 99,
    name: 'Test Show',
    rating: 7.5,
    premiered: '2020-01-01',
    genres: const ['Drama'],
  );

  testWidgets('renders the title, metadata and save action', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 310,
              child: ShowCard(
                show: show,
                isSaved: false,
                onTap: () {},
                onToggleSaved: () => tapped = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test Show'), findsOneWidget);
    expect(find.text('7.5'), findsOneWidget);
    expect(find.textContaining('2020'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark_add_outlined));
    expect(tapped, isTrue);
  });

  testWidgets('shows a filled bookmark when saved', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 310,
              child: ShowCard(
                show: show,
                isSaved: true,
                onTap: () {},
                onToggleSaved: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
  });
}
