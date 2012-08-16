#library("Unit");

/**
  * Unit for animation
  */
class Unit {
    const Unit(String id) : _id = id;

    String toString() {
        return _id;
    }

    final String _id;

    static final String PixelID = "px";
    static final String MillisecID = "ms";
    static final Pixel = const Unit(PixelID);
    static final Millisecond = const Unit(MillisecID);
}

