import std.core;
import std.sys;

/// Convert a rad_sbw score name string to ASCII
/// rad_sbw alphabet for score names, 'A' = 0, each character is 1 more
/// than the one before it:
///   ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!()
/// 0x29, one more than the last valid character ')', is used as a filler
/// when names are shorter than the allotted 6 bytes.
fn rad_sbw_to_ascii(auto s) {
    str os = "";
    for (u16 i = 0, i < std::core::member_count(s), i = i + 1) {
        u8 c = s[i];
        char oc = '?'; // Use '?' for out of range characters
        if (c >= 0 && c <= 25) {
            oc = char(c + u8('A'));
        } else if (c >= 26 && c <= 35) {
            oc = char(c + u8('0'));
        } else if (c == 36) {
            oc = '!';
        } else if (c == 37) {
            oc = '(';
        } else if (c == 38) {
            oc = ')';
        }
        os = os + oc;
    }
    return os;
};

enum With : u8 {
    MASON = 0,
    DJ = 1,
    RUFUS = 2,
};

struct TimeElapsed {
    u8 milliseconds;
    u8 seconds;
    u8 minutes;
};

union Score {
    u24 pts;
    TimeElapsed time_elapsed;
};

struct Character {
    Score score;
    u8 name[6] [[format("rad_sbw_to_ascii")]];
    With with;
    std::assert(std::core::is_valid_enum(with), "");
};

struct Event {
    Character characters[5];
};

/// Indices for events are:
/// NOTE: "Unknown" Stage referes to an apparent missing stage between
/// Urban Chaos and Badlands for which there are scores but no menu
/// item to select.
/// Free-Ride uses pts from Score
///    0 = Free-Ride, Alpine Bliss, One Diamond
///    1 = Free-Ride, Alpine Bliss, Two Diamonds
///    2 = Free-Ride, Urban Chaos, One Diamond
///    3 = Free-Ride, Urban Chaos, Two Diamonds
///    4 = Free-Ride, Unknown Stage, One Diamond
///    5 = Free-Ride, Unknown Stage, Two Diamonds
///    6 = Free-Ride, Badlands, One Diamond
///    7 = Free-Ride, Badlands, Two Diamonds
/// Slalom uses time_elapsed from Score
///    8 = Slalom, Alpine Bliss, One Diamond
///    9 = Slalom, Alpine Bliss, Two Diamonds
///   10 = Slalom, Urban Chaos, One Diamond
///   11 = Slalom, Urban Chaos, Two Diamonds
///   12 = Slalom, Unknown Stage, One Diamond
///   13 = Slalom, Unknown Stage, Two Diamonds
///   14 = Slalom, Badlands, One Diamond
///   15 = Slalom, Badlands, Two Diamonds
/// Big Air Competition uses pts from Score
///   16 = Big Air Competition
/// 1/2 Pipe uses pts from Score
///   17 = 1/2 Pipe
Event events[18] @ 0x0004FAC0;
