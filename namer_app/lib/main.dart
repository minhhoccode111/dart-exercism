// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:english_words/english_words.dart'; // Import package for generating English word pairs
import 'package:flutter/material.dart'; // Import Flutter's Material design library
import 'package:provider/provider.dart'; // Import Provider package for state management

// The main entry point of the application
void main() {
  runApp(MyApp()); // Run the MyApp widget
}

// The root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor for MyApp

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider creates and provides the MyAppState instance
    // to the widget tree below it. Any widget in the tree can access the state.
    return ChangeNotifierProvider(
      create: (context) => MyAppState(), // Create an instance of the app state
      child: MaterialApp(
        title: 'Namer App', // Title of the application
        theme: ThemeData(
          useMaterial3: true, // Enable Material 3 design
          // Define the color scheme based on a seed color
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(), // Set the initial screen (widget) of the app
      ),
    );
  }
}

// Manages the application's state using ChangeNotifier.
// Widgets can listen to changes in this state and rebuild accordingly.
class MyAppState extends ChangeNotifier {
  // The currently displayed random word pair.
  var current = WordPair.random();
  // A list to store the history of generated word pairs. The newest is at index 0.
  var history = <WordPair>[];

  // A GlobalKey specifically for the AnimatedList in HistoryListView.
  // This allows MyAppState to trigger animations (like insertion) on the list.
  GlobalKey? historyListKey;

  // Generates the next random word pair.
  void getNext() {
    // Add the current word pair to the beginning of the history list.
    history.insert(0, current);
    // Get the state of the AnimatedList using the GlobalKey.
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    // Tell the AnimatedList to animate the insertion of the new item at index 0.
    animatedList?.insertItem(0);
    // Generate a new random word pair and assign it to 'current'.
    current = WordPair.random();
    // Notify any widgets listening to this state that the state has changed.
    // This typically causes widgets observing 'current' or 'history' to rebuild.
    notifyListeners();
  }

  // A list to store the word pairs that the user has marked as favorites.
  var favorites = <WordPair>[];

  // Toggles the favorite status of a word pair.
  // If no pair is provided, it defaults to the 'current' word pair.
  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current; // Use 'current' if 'pair' is null
    if (favorites.contains(pair)) {
      // If the pair is already in favorites, remove it.
      favorites.remove(pair);
    } else {
      // Otherwise, add it to favorites.
      favorites.add(pair);
    }
    // Notify listeners about the change in the favorites list.
    notifyListeners();
  }

  // Removes a specific word pair from the favorites list.
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    // Notify listeners about the change in the favorites list.
    notifyListeners();
  }
}

// The main screen widget, which is stateful because its content changes
// based on user interaction (switching between pages).
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// The state associated with MyHomePage.
class _MyHomePageState extends State<MyHomePage> {
  // Tracks the index of the currently selected page/tab.
  // 0 corresponds to the GeneratorPage, 1 corresponds to the FavoritesPage.
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get the color scheme from the current theme.
    var colorScheme = Theme.of(context).colorScheme;

    // Determine which page widget to display based on the selectedIndex.
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(); // Show the generator page
      case 1:
        page = FavoritesPage(); // Show the favorites page
      default:
        // This should not happen in this app, but it's good practice
        // to handle unexpected states.
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // A container for the currently selected page.
    // It sets a background color and uses AnimatedSwitcher to provide
    // a smooth fade transition when switching between pages.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceContainerHighest, // Background color from theme
      child: AnimatedSwitcher(
        duration:
            Duration(milliseconds: 1200), // Duration of the switch animation
        child:
            page, // The widget to display (either GeneratorPage or FavoritesPage)
      ),
    );

    // Scaffold provides the basic structure (like AppBar, Body, BottomNavigationBar).
    return Scaffold(
      body: LayoutBuilder(
        // LayoutBuilder rebuilds the UI based on the available constraints (like screen width).
        // This allows for creating responsive layouts.
        builder: (context, constraints) {
          // Check if the screen width is less than 450 logical pixels.
          if (constraints.maxWidth < 450) {
            // Use a mobile-friendly layout with a BottomNavigationBar.
            return Column(
              children: [
                // The main content area takes up the available vertical space.
                Expanded(child: mainArea),
                // SafeArea ensures the navigation bar doesn't overlap with system UI (like notches).
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      // Define the items for the bottom navigation bar.
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Favorites',
                      ),
                    ],
                    currentIndex:
                        selectedIndex, // Highlight the currently selected item
                    // Callback function when a navigation item is tapped.
                    onTap: (value) {
                      // Update the selectedIndex state variable, which triggers a rebuild.
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            // Use a layout suitable for wider screens (tablets, desktops) with a NavigationRail.
            return Row(
              children: [
                // SafeArea for the NavigationRail.
                SafeArea(
                  child: NavigationRail(
                    // Show labels next to icons if the screen width is >= 600.
                    extended: constraints.maxWidth >= 600,
                    // Define the destinations (items) for the navigation rail.
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                    ],
                    selectedIndex:
                        selectedIndex, // Highlight the selected destination
                    // Callback function when a destination is selected.
                    onDestinationSelected: (value) {
                      // Update the selectedIndex state variable, triggering a rebuild.
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                // The main content area takes up the remaining horizontal space.
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

// The page widget responsible for displaying the word generation UI.
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the application state (MyAppState).
    // context.watch<T>() makes this widget rebuild whenever MyAppState changes.
    var appState = context.watch<MyAppState>();
    // Get the current word pair from the state.
    var pair = appState.current;

    // Determine which icon to display based on whether the current pair is favorited.
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite; // Filled heart icon if favorited
    } else {
      icon = Icons.favorite_border; // Border heart icon if not favorited
    }

    // Center the content vertically within the page.
    return Center(
      child: Column(
        // Center the column's children horizontally.
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The HistoryListView takes up 3 parts of the flexible space.
          Expanded(
            flex: 3,
            child:
                HistoryListView(), // Display the list of previously generated words
          ),
          // Add a small fixed amount of vertical space.
          SizedBox(height: 10),
          // Display the current word pair using the BigCard widget.
          BigCard(pair: pair),
          // Add a small fixed amount of vertical space.
          SizedBox(height: 10),
          // A row containing the action buttons ('Like' and 'Next').
          Row(
            // Size the row to be only as wide as its children need.
            mainAxisSize: MainAxisSize.min,
            children: [
              // Button to toggle the favorite status of the current word pair.
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(); // Call the state method
                },
                icon: Icon(icon), // Display the determined favorite icon
                label: Text('Like'),
              ),
              // Add a small fixed amount of horizontal space between buttons.
              SizedBox(width: 10),
              // Button to generate the next word pair.
              ElevatedButton(
                onPressed: () {
                  appState.getNext(); // Call the state method
                },
                child: Text('Next'),
              ),
            ],
          ),
          // A flexible spacer that takes up 2 parts of the remaining space,
          // pushing the content towards the center/top.
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

// A widget to display a WordPair prominently within a Card.
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair, // Requires a WordPair to be passed in
  });

  final WordPair pair; // The WordPair to display

  @override
  Widget build(BuildContext context) {
    // Get the current theme data.
    var theme = Theme.of(context);
    // Define the text style for the word pair, based on the theme's displayMedium style.
    // Make the text color contrast with the card's primary color background.
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme
          .colorScheme.onPrimary, // Text color suitable for primary background
    );

    // Card provides a Material Design card container with elevation.
    return Card(
      // Set the card's background color to the theme's primary color.
      color: theme.colorScheme.primary,
      child: Padding(
        // Add padding around the text inside the card.
        padding: const EdgeInsets.all(20),
        // AnimatedSize automatically animates the card's size when its child's size changes.
        child: AnimatedSize(
          duration: Duration(milliseconds: 200), // Animation duration
          // MergeSemantics combines the semantics information of its descendants.
          // This is helpful for accessibility tools like screen readers.
          child: MergeSemantics(
            // Wrap widget allows its children to wrap to the next line if there isn't enough horizontal space.
            child: Wrap(
              children: [
                // Display the first word of the pair with a lighter font weight.
                Text(
                  pair.first,
                  style: style.copyWith(fontWeight: FontWeight.w200),
                ),
                // Display the second word of the pair with a bold font weight.
                Text(
                  pair.second,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// The page widget responsible for displaying the list of favorited word pairs.
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context); // Get the current theme
    var appState = context.watch<MyAppState>(); // Access the application state

    // If the favorites list is empty, display a message in the center.
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    // If there are favorites, display them in a Column layout.
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align children to the start (left)
      children: [
        // Add padding around the header text.
        Padding(
          padding: const EdgeInsets.all(30),
          // Display the count of favorite items.
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        // Use Expanded to make the GridView take up the remaining vertical space.
        Expanded(
          // GridView displays items in a scrollable grid.
          child: GridView(
            // Configure the grid layout. Items will have a maximum width of 400,
            // and their height will be calculated based on the childAspectRatio.
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400, // Max width of each grid item
              childAspectRatio: 400 / 80, // Ratio of width to height
            ),
            // Generate the list of widgets (ListTile) for the grid.
            children: [
              // Iterate through the favorites list.
              for (var pair in appState.favorites)
                // ListTile is a standard Material Design list item.
                ListTile(
                  // Display a delete icon button at the beginning of the tile.
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                    color: theme.colorScheme.primary, // Icon color
                    // When the delete button is pressed, remove the favorite.
                    onPressed: () {
                      appState.removeFavorite(pair);
                    },
                  ),
                  // Display the favorite word pair as the title of the list tile.
                  title: Text(
                    pair.asLowerCase, // Show text in lower case
                    // Provide a semantic label (e.g., for screen readers) in PascalCase.
                    semanticsLabel: pair.asPascalCase,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// A StatefulWidget to display the scrollable, animated list of generated word history.
class HistoryListView extends StatefulWidget {
  const HistoryListView({super.key});

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  /// Needed so that [MyAppState] can tell [AnimatedList] below to animate
  /// new items. This key uniquely identifies the AnimatedList widget.
  final _key = GlobalKey();

  /// Used to "fade out" the history items at the top, to suggest continuation.
  static const Gradient _maskingGradient = LinearGradient(
    // This gradient goes from fully transparent to fully opaque black...
    colors: [Colors.transparent, Colors.black],
    // ... from the top (transparent) to half (0.5) of the way to the bottom.
    stops: [0.0, 0.5],
    begin: Alignment.topCenter, // Gradient starts at the top center
    end: Alignment.bottomCenter, // Gradient ends at the bottom center
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>(); // Access the app state
    // Assign the local _key to the historyListKey in the app state.
    // This allows MyAppState.getNext() to access the AnimatedList's state via the key.
    appState.historyListKey = _key;

    // ShaderMask applies a gradient mask to its child (the AnimatedList).
    return ShaderMask(
      // The callback provides the gradient shader based on the child's bounds.
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // This blend mode takes the opacity of the shader (our gradient)
      // and applies it to the destination (our animated list). This creates the fade effect.
      blendMode: BlendMode.dstIn,
      // The child widget that the mask is applied to.
      child: AnimatedList(
        key: _key, // Assign the GlobalKey to the AnimatedList
        reverse:
            true, // Items are added at index 0, but visually appear at the bottom and scroll upwards.
        padding: EdgeInsets.only(
            top:
                100), // Add padding at the top (which is visually the bottom because reverse=true)
        // to prevent items from being hidden initially by the gradient mask.
        initialItemCount:
            appState.history.length, // Number of items initially in the list
        // Builder function to create each item in the list.
        // It receives context, index, and an animation object.
        itemBuilder: (context, index, animation) {
          final pair =
              appState.history[index]; // Get the word pair for this index
          // SizeTransition animates the size of its child based on the provided animation.
          // Used here for the insertion animation.
          return SizeTransition(
            sizeFactor:
                animation, // Link the transition to the list's animation
            child: Center(
              // Center the list item horizontally
              // Display each history item as a TextButton with an optional icon.
              child: TextButton.icon(
                // When pressed, toggle the favorite status of this specific history item.
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                // Conditionally display a small favorite icon if the item is in favorites.
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(), // Display nothing (empty box) if not favorited
                // The text label for the button, showing the word pair.
                label: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase, // Accessibility label
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
