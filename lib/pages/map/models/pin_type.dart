// Initially, we used the _PinOptions class and an array to represent the pin types,
// but this approach was less structured and we could accidentally create a pin type with a label but no emoji
enum PinType {
  // each location type e.g. gym will store its corresponding set emoji
  // and the customised name from user
  restaurant("Restaurant", "🍽️"),
  gym("Gym", "🏋"),
  hotel("Hotel", "🏨"),
  food("Food", "🍚"),
  cafe("Cafe", "☕"),
  drinks("Drinks", "🍹"),
  outdoors("Outdoors", "🌳"),
  toilet("Toilet", "🚽"),
  shopping("Shopping", "🛍️"),
  dessert("Dessert", "🍦"),
  bar("Bar", "🍺"),
  karaoke("Karaoke", "🎤"),
  studySpot("Study Spot", "📚"),
  sports("Sports", "⚽"),
  beach("Beach", "🏖️"),
  attraction("Attraction", "🎡"),
  cinema("Cinema", "🎬"),
  games("Games", "🎮"),
  station("Station", "🚇");

  const PinType(this.label, this.emoji);
  final String label;
  final String emoji;

  static PinType? fromEmoji(String? emoji) {
    if (emoji == null) return null;
    for (final type in values) {
      if (type.emoji == emoji) return type;
    }
    return null;
  }
}