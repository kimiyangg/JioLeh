// Initially, we used the _PinOptions class and an array to represent the pin types,
// but this approach was less structured and we could accidentally create a pin type with a label but no emoji
enum PinType {
  // each location type e.g. gym will store its corresponding set emoji 
  // and the customised name from user 
  restaurant("Restaurant", "🍽️"),
  gym("Gym", "🏋"),
  hotel("Hotel", "🏨");

  const PinType(this.label, this.emoji);
  final String label;
  final String emoji;
}