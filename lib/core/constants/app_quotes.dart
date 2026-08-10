class AppQuote {
  final String text;
  final String author;

  const AppQuote({required this.text, required this.author});
}

class AppQuotes {
  static const List<AppQuote> quotes = [
    AppQuote(
      text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.",
      author: "Aristotle",
    ),
    AppQuote(
      text: "Small daily improvements over time lead to stunning results.",
      author: "Robin Sharma",
    ),
    AppQuote(
      text: "You do not rise to the level of your goals. You fall to the level of your systems.",
      author: "James Clear",
    ),
    AppQuote(
      text: "Motivation is what gets you started. Habit is what keeps you going.",
      author: "Jim Ryun",
    ),
    AppQuote(
      text: "Chains of habit are too light to be felt until they are too heavy to be broken.",
      author: "Warren Buffett",
    ),
    AppQuote(
      text: "Consistency is key. Success doesn't come from what you do occasionally.",
      author: "Marie Forleo",
    ),
    AppQuote(
      text: "The secret of your future is hidden in your daily routine.",
      author: "Mike Murdock",
    ),
  ];

  static AppQuote getDailyQuote() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return quotes[dayOfYear % quotes.length];
  }
}
