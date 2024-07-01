# LifecycleScreen

LifecycleScreen is a Flutter library that simplifies state management and lifecycle handling in your applications. By providing a structured approach to managing screen lifecycle events, local state, and UI updates, LifecycleScreen allows you to build robust and maintainable Flutter applications with ease.

## Features

- 🔄 Lifecycle management: Handle screen lifecycle events such as push, pop, and app state changes.
- 🧠 State management: Manage local state with a clean, provider-based architecture.
- ⚡ Asynchronous operation handling: Built-in support for managing loading states and errors during async tasks.
- 🏗️ Separation of concerns: Clear separation between UI and business logic for better maintainability.
- 🎨 Customizable UI components: Easily override default loading and error UIs.
- 🔔 Subscription management: Easily manage stream subscriptions with built-in methods.

## Installation

Add LifecycleScreen to your `pubspec.yaml` file:

```yaml
dependencies:
  lifecycle_screen: latest_version
  provider: ^6.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### 1. Create a Controller

Create a controller that extends `LifecycleScreenController`:

```dart
import 'package:lifecycle_screen/lifecycle_screen.dart';

class CounterController extends LifecycleScreenController {
  int _counter = 0;
  int get counter => _counter;

  void increment() {
    // Use `asyncRun` to handle loading states and errors
    asyncRun(() async {
      await Future.delayed(const Duration(seconds: 1));
      _counter++;
      notifyListeners();
    });
  }

  @override
  void onInit() {
    super.onInit();
    print('Counter initialized');
  }

  @override
  void onDidPush() {
    super.onDidPush();
    print('Counter screen pushed');
  }
}
```

### 2. Create a Screen

Create a screen that extends `LifecycleScreen`:

```dart
import 'package:flutter/material.dart';
import 'package:lifecycle_screen/lifecycle_screen.dart';
import 'package:provider/provider.dart';

class CounterScreen extends LifecycleScreen<CounterController> {
  @override
  CounterController createController() => CounterController();

  @override
  Widget buildView(BuildContext context, CounterController controller) {
    final counter = context.select<CounterController, int>((controller) => controller.counter);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Text(
          'Count: $counter',
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 3. Use the Screen in Your App

```dart
import 'package:flutter/material.dart';
import 'package:lifecycle_screen/lifecycle_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifecycleScreen Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CounterScreen(),
      navigatorObservers: [LifecycleScreenController.basePageRouteObserver],
    );
  }
}
```

## State Management with Provider

LifecycleScreen uses the Provider package for state management. The library automatically sets up the necessary Provider infrastructure, allowing you to access your controller's state easily within your screen.

### Accessing Controller State

You can access your controller's state using `context.read`, `context.watch`, or `context.select`:

```dart
// Read a value once (doesn't listen for changes)
final controller = context.read<CounterController>();

// Watch for all changes in the controller
final counter = context.watch<CounterController>().counter;

// Select and listen to specific properties (recommended for optimal performance)
final counter = context.select<CounterController, int>((controller) => controller.counter);
```

Use `context.select` when you want to listen to specific properties for optimal performance.

## Lifecycle Hooks

LifecycleScreen provides several lifecycle hooks that you can override in your controller:

```dart
class MyController extends LifecycleScreenController {
  @override
  void onInit() {
    super.onInit();
    // Called when the controller is initialized
  }

  @override
  void onDispose() {
    super.onDispose();
    // Called when the controller is disposed
  }
  
  @override
  void onDidPush() {
    super.onDidPush();
    // Called when the screen is pushed onto the navigation stack
  }
  
  @override
  void onDidPop() {
    super.onDidPop();
    // Called when the screen is popped from the navigation stack
  }
  
  @override
  void onDidPushNext() {
    super.onDidPushNext();
    // Called when a new screen is pushed on top of this one
  }
  
  @override
  void onDidPopNext() {
    super.onDidPopNext();
    // Called when the screen on top of this one is popped
  }
  
  @override
  void onResumed() {
    super.onResumed();
    // Called when the app is resumed from the background
  }
  
  @override
  void onInactive() {
    super.onInactive();
    // Called when the app becomes inactive
  }
  
  @override
  void onPaused() {
    super.onPaused();
    // Called when the app is paused
  }
  
  @override
  void onDetached() {
    super.onDetached();
    // Called when the app is detached
  }
}
```

## Customizing UI Components

### Custom Loading View

Override the `buildLoading` method in your screen to provide a custom loading UI:

```dart
class MyScreen extends LifecycleScreen<MyController> {
  @override
  Widget buildLoading(BuildContext context, MyController controller) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
```

### Custom Error View

Similarly, override the `buildError` method for a custom error UI:

```dart
class MyScreen extends LifecycleScreen<MyController> {
  @override
  Widget buildError(BuildContext context, MyController controller) {
    return Center(
      child: Text('Error: ${controller.errorMessage}'),
    );
  }
}
```

## Subscription Management

LifecycleScreen provides built-in methods to manage stream subscriptions, making it easier to handle and dispose of subscriptions properly.

### Adding and Removing Subscriptions

You can use the `addSubscription` method to add a subscription to be managed by the controller:

```dart
class MyController extends LifecycleScreenController {
  void listenToSomeStream() {
    final subscription = someStream.listen((data) {
      // Handle data
    });
    addSubscription(subscription);
  }
}
```

The controller will automatically cancel all added subscriptions when it's disposed, preventing memory leaks.

You can also manually cancel subscriptions using the `cancelSubscription` or `cancelSubscriptionAll` methods:

```dart
// Cancel a specific subscription
cancelSubscription(subscription);

// Cancel all subscriptions
cancelSubscriptionAll();
```

This feature helps in managing resources efficiently and prevents potential memory leaks from uncancelled subscriptions.


## Best Practices

1. **Keep Controllers Focused**: Each controller should manage the state for a single screen or a specific feature.

2. **Use `asyncRun` for Async Operations**: Always use the `asyncRun` method provided by LifecycleScreen for asynchronous operations to properly handle loading states and errors.

3. **Leverage Lifecycle Hooks**: Make use of the various lifecycle hooks to perform initialization, cleanup, and respond to navigation events.

4. **Optimize Rebuilds**: Use `context.select` instead of `context.watch` when you only need to listen to specific properties of your controller.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT

