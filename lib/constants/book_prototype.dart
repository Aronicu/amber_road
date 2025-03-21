import 'package:amber_road/models/book.dart';
import 'package:flutter/material.dart';

final Book girlsxvampire = Book(
  Image.asset("assets/girlsxvampire/cover.jpg", fit: BoxFit.cover,),
  0,
  name: "Girls X Vampire",
  author: "Mikami Teren",
  artist: "Chigusa Minori",
  genres: ["Comedy", "Girl's Love", "Romance", "Slice of Life"],
  themes: ["School Life", "Vampires", "Adaptation"],
  format: BookFormat.manga
);

final Book makeine = Book(
  Image.asset("assets/makeine/cover.jpg", fit: BoxFit.cover,),
  1,
  name: "Too Many Losing Heroines",
  author: "Takibi Amamori",
  artist: "Imigimuru",
  genres: ["Comedy", "Drama", "Romance", "Slice of Life"],
  themes: ["School Life"],
  format: BookFormat.webnovel,
);

final Book theNovelsExtra = Book(
  Image.asset("assets/theNovelsExtra/cover.jpg", fit: BoxFit.cover,),
  2,
  name: "The Novel's Extra",
  author: "Jee Gab Song",
  artist: "CarroToon",
  genres: ["Action", "Adventure", "Drama", "Fantasy", "Isekai"],
  themes: ["Demons", "Magic", "Monsters", "Reincarnation", "School Life"],
  format: BookFormat.webtoon
);

final Book brainrotGF = Book(
  Image.asset("assets/brainrotGF/cover.jpg", fit: BoxFit.cover,),
  3,
  name: "Brainrot GF",
  author: "Senukin",
  artist: "Senukin",
  genres: ["Comedy", "Romance", "Slice Of Life"],
  format: BookFormat.manga
);

final Book theFragrantFlowerBloomsWithDignity = Book(
  Image.asset("assets/theFragrantFlowerBloomsWithDignity/cover.jpg", fit: BoxFit.cover,),
  4,
  name: "The Fragrant Flower Blooms with Dignity",
  author: "Mikami Saka",
  artist: "Mikami Saka",
  genres: ["Comedy", "Drama", "Romance", "Slice of Life"],
  themes: ["School Life"],
  format: BookFormat.manga
);

final Book threeSixtyFiveDaysToTheWedding = Book(
  Image.asset("assets/threeSixtyFiveDaysToTheWedding/cover.jpg", fit: BoxFit.cover,),
  5,
  name: "365 Days to the Wedding",
  author: "Wakami Tamiki",
  artist: "Wakami Tamiki",
  genres: ["Drama", "Slice of Life", "Romance"],
  themes: ["Office Workers"],
  format: BookFormat.manga
);

final Book farmingLifeInAnotherWorld = Book(
  Image.asset("assets/farmingLifeInAnotherWorld/cover.jpg", fit: BoxFit.cover,),
  6,
  name: "Farming Life in Another World",
  author: "Naitou Kinosuke",
  artist: "Tsurugi Yasuyuki",
  genres: ["Adventure", "Comedy", "Fantasy", "Isekai", "Slice of Life"],
  themes: ["Harem", "Magic", "Monster Girls", "Survival"],
  format: BookFormat.manga
);

final Book theExtrasAcademySurvivalGuide = Book(
  Image.asset("assets/theExtrasAcademySurvivalGuide/cover.jpg", fit: BoxFit.cover,),
  7,
  name: "The Extra's Academy Survival Guide",
  author: "Korita",
  artist: "Green Kyrin",
  genres: ["Action", "Adventure", "Drama", "Fantasy", "Isekai", "Romance"],
  themes: ["Harem", "Magic", "Reincarnation", "Slice of Life", "Supernatural", "Time Travel"],
  format: BookFormat.webtoon
);

final Book soloLeveling = Book(
  Image.asset("assets/soloLeveling/cover.jpg", fit: BoxFit.cover,),
  8,
  name: "Solo Leveling",
  author: "Chugong",
  artist: "REDICE Studio",
  genres: ["Action", "Adventure", "Drama", "Fantasy"],
  themes: ["Magic", "Monsters", "Supernatural"],
  format: BookFormat.webtoon
);

final Book windBreaker = Book(
  Image.asset("assets/windBreaker/cover.jpg", fit: BoxFit.cover,),
  9,
  name: "Wind Breaker",
  author: "Jo Yongseok",
  artist: "Jo Yongseok",
  genres: ["Action", "Adventure", "Comedy", "Drama", "Slice of Life", "Sports"],
  themes: ["Delinquents", "School Life"],
  format: BookFormat.webtoon
);

final Book myOlderSistersFriend = Book(
  Image.asset("assets/myOlderSistersFriend/cover.jpg", fit: BoxFit.cover,),
  10,
  name: "My Older Sister's Friend",
  author: "Takase Waka",
  artist: "Takase Waka",
  genres: ["Comedy", "Romance", "Slice of Life"],
  themes: ["Gyaru", "School Life"],
  format: BookFormat.manga
);


Book getBookByID(int id) {
  switch (id) {
    case 0:
      return girlsxvampire;
    case 1:
      return makeine;
    case 2:
      return theNovelsExtra;
    case 3:
      return brainrotGF;
    case 4:
      return theFragrantFlowerBloomsWithDignity;
    case 5:
      return threeSixtyFiveDaysToTheWedding;
    case 6:
      return farmingLifeInAnotherWorld;
    case 7:
      return theExtrasAcademySurvivalGuide;
    case 8:
      return soloLeveling;
    case 9:
      return windBreaker;
    case 10:
      return myOlderSistersFriend;
  }

  return girlsxvampire;
}
