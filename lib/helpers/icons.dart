import 'package:knocky/models/usergroup.dart';

/// This is really ugly, and should be a seperate API call.
///
/// As of time of writing, there is no API call for this.
///
/// :(

const _baseurl = "https://knockout.chat/";
const _cdnUrl = "https://cdn.knockout.chat/";
const _ratingsUrl = "${_cdnUrl}assets/ratings/rating-";

List<IconListItem> iconList = [
  new IconListItem(id: 0, url: _baseurl + "static/icons/default.png"),
  new IconListItem(id: 1, url: _baseurl + "static/icons/drama.png"),
  new IconListItem(id: 2, url: _baseurl + "static/icons/games.png"),
  new IconListItem(id: 3, url: _baseurl + "static/icons/life.png"),
  new IconListItem(id: 4, url: _baseurl + "static/icons/money.png"),
  new IconListItem(id: 5, url: _baseurl + "static/icons/announcement.png"),
  new IconListItem(
      id: 6, url: "https://img.icons8.com/color/64/arcade-cabinet.png"),
  new IconListItem(id: 7, url: "https://img.icons8.com/color/64/blog.png"),
  new IconListItem(id: 8, url: "https://img.icons8.com/color/64/bomb.png"),
  new IconListItem(id: 9, url: "https://img.icons8.com/color/64/bug.png"),
  new IconListItem(id: 10, url: "https://img.icons8.com/color/64/code.png"),
  new IconListItem(
      id: 11, url: "https://img.icons8.com/color/64/combo-chart.png"),
  new IconListItem(id: 12, url: "https://img.icons8.com/color/64/cooker.png"),
  new IconListItem(
      id: 13, url: "https://img.icons8.com/color/64/crying-baby.png"),
  new IconListItem(id: 14, url: "https://img.icons8.com/color/64/dota.png"),
  new IconListItem(
      id: 15, url: "https://img.icons8.com/color/64/europe-news.png"),
  new IconListItem(id: 16, url: "https://img.icons8.com/color/64/gallery.png"),
  new IconListItem(
      id: 17, url: "https://img.icons8.com/color/64/grocery-bag.png"),
  new IconListItem(id: 18, url: "https://img.icons8.com/color/64/gun.png"),
  new IconListItem(
      id: 19, url: "https://img.icons8.com/color/64/heart-with-pulse.png"),
  new IconListItem(id: 20, url: "https://img.icons8.com/color/64/help.png"),
  new IconListItem(
      id: 21, url: "https://img.icons8.com/color/64/hot-article.png"),
  new IconListItem(id: 22, url: "https://img.icons8.com/color/64/news.png"),
  new IconListItem(
      id: 23,
      url: "https://img.icons8.com/color/64/nintendo-entertainment-system.png"),
  new IconListItem(id: 24, url: "https://img.icons8.com/color/64/pin.png"),
  new IconListItem(id: 25, url: "https://img.icons8.com/color/64/planner.png"),
  new IconListItem(id: 26, url: "https://img.icons8.com/color/64/tv-show.png"),
  new IconListItem(id: 27, url: "https://img.icons8.com/color/64/uk-news.png"),
  new IconListItem(id: 28, url: "https://img.icons8.com/color/64/us-music.png"),
  new IconListItem(id: 29, url: "https://img.icons8.com/color/64/us-news.png"),
  new IconListItem(id: 30, url: "https://img.icons8.com/color/64/retro-tv.png"),
  new IconListItem(id: 31, url: "https://img.icons8.com/color/64/smiling.png"),
  new IconListItem(id: 32, url: "https://img.icons8.com/color/64/vomited.png"),
  new IconListItem(
      id: 33, url: "https://img.icons8.com/color/64/test-tube.png"),
  new IconListItem(id: 34, url: "https://img.icons8.com/color/64/easel.png"),
  new IconListItem(id: 35, url: "https://img.icons8.com/color/64/banana.png"),
  new IconListItem(
      id: 36, url: "https://img.icons8.com/color/64/heart-with-arrow.png"),
  new IconListItem(
      id: 37, url: "https://img.icons8.com/color/64/radio-active.png"),
  new IconListItem(id: 38, url: "https://img.icons8.com/color/64/poison.png"),
  new IconListItem(
      id: 39, url: "https://img.icons8.com/color/64/invisible.png"),
  new IconListItem(id: 40, url: "https://img.icons8.com/color/64/visible.png"),
  new IconListItem(
      id: 41, url: "https://img.icons8.com/color/64/controller.png"),
  new IconListItem(id: 42, url: "https://img.icons8.com/color/64/boring.png"),
  new IconListItem(
      id: 43, url: "https://img.icons8.com/color/64/swearing-male.png"),
  new IconListItem(id: 44, url: "https://img.icons8.com/color/64/idea.png"),
  new IconListItem(
      id: 45, url: "https://img.icons8.com/color/64/megaphone.png"),
  new IconListItem(
      id: 46, url: "https://img.icons8.com/color/64/banknotes.png"),
  new IconListItem(id: 47, url: "https://img.icons8.com/color/64/robot-3.png"),
  new IconListItem(
      id: 48, url: "https://img.icons8.com/color/64/phonelink-ring.png"),
  new IconListItem(id: 49, url: "https://img.icons8.com/color/64/thriller.png"),
  new IconListItem(
      id: 50, url: "https://img.icons8.com/color/64/hamburger.png"),
  new IconListItem(id: 51, url: "https://img.icons8.com/color/64/sakura.png"),
  new IconListItem(id: 52, url: "https://img.icons8.com/color/64/sushi.png"),
  new IconListItem(id: 53, url: "https://img.icons8.com/color/64/lifebuoy.png"),
  new IconListItem(
      id: 54, url: "https://img.icons8.com/color/64/handshake.png"),
  new IconListItem(
      id: 55, url: "https://img.icons8.com/color/64/clenched-fist.png"),
  new IconListItem(
      id: 56, url: "https://img.icons8.com/color/64/anonymous-mask.png"),
  new IconListItem(id: 57, url: "https://img.icons8.com/color/64/rocket.png"),
  new IconListItem(id: 58, url: "https://img.icons8.com/color/64/vodka.png"),
  new IconListItem(id: 59, url: "https://img.icons8.com/color/64/poo.png"),
  new IconListItem(id: 60, url: "https://img.icons8.com/color/64/sedan.png"),
  new IconListItem(
      id: 61, url: "https://img.icons8.com/color/64/tesla-model-x.png"),
  new IconListItem(
      id: 62, url: "https://img.icons8.com/color/64/memory-slot.png"),
  new IconListItem(
      id: 63, url: "https://img.icons8.com/color/64/processor.png"),
  new IconListItem(
      id: 64, url: "https://img.icons8.com/color/64/fire-element.png"),
  new IconListItem(id: 65, url: "https://img.icons8.com/color/64/firework.png"),
  new IconListItem(id: 66, url: "https://img.icons8.com/color/64/siren.png"),
  new IconListItem(id: 67, url: "https://img.icons8.com/color/64/confetti.png"),
  new IconListItem(id: 68, url: "https://img.icons8.com/color/64/campfire.png"),
  new IconListItem(id: 69, url: "https://img.icons8.com/color/64/panties.png"),
  new IconListItem(
      id: 70, url: "https://img.icons8.com/color/64/mushroom-cloud.png"),
  new IconListItem(id: 71, url: _baseurl + "static/icons/adhd.png"),
  new IconListItem(id: 72, url: _baseurl + "static/icons/cute-monster.png"),
  new IconListItem(id: 73, url: _baseurl + "static/icons/japan-circular.png"),
  new IconListItem(id: 74, url: _baseurl + "static/icons/sad-sun.png"),
  new IconListItem(id: 75, url: _baseurl + "static/icons/anime-emoji.png"),
  new IconListItem(id: 76, url: _baseurl + "static/icons/daruma-doll.png"),
  new IconListItem(id: 77, url: _baseurl + "static/icons/jellyfish.png"),
  new IconListItem(id: 78, url: _baseurl + "static/icons/jellyfish.png"),
  new IconListItem(id: 79, url: _baseurl + "static/icons/sailor-moon.png"),
  new IconListItem(
      id: 80, url: _baseurl + "static/icons/argentina-circular.png"),
  new IconListItem(id: 81, url: _baseurl + "static/icons/dice.png"),
  new IconListItem(id: 82, url: _baseurl + "static/icons/landslide.png"),
  new IconListItem(id: 83, url: _baseurl + "static/icons/security-guard.png"),
  new IconListItem(
      id: 84, url: _baseurl + "static/icons/australia-circular.png"),
  new IconListItem(id: 85, url: _baseurl + "static/icons/dog-pee.png"),
  new IconListItem(id: 86, url: _baseurl + "static/icons/language-skill.png"),
  new IconListItem(id: 87, url: _baseurl + "static/icons/skull-heart--v2.png"),
  new IconListItem(id: 88, url: _baseurl + "static/icons/bad-piggies.png"),
  new IconListItem(id: 89, url: _baseurl + "static/icons/dog-pooping.png"),
  new IconListItem(id: 90, url: _baseurl + "static/icons/lasagna.png"),
  new IconListItem(id: 91, url: _baseurl + "static/icons/soil.png"),
  new IconListItem(id: 92, url: _baseurl + "static/icons/batman-emoji.png"),
  new IconListItem(id: 93, url: _baseurl + "static/icons/euro-exchange.png"),
  new IconListItem(id: 94, url: _baseurl + "static/icons/lawn-care.png"),
  new IconListItem(
      id: 95, url: _baseurl + "static/icons/south-korea-circular.png"),
  new IconListItem(id: 96, url: _baseurl + "static/icons/belgium-circular.png"),
  new IconListItem(id: 97, url: _baseurl + "static/icons/finland-circular.png"),
  new IconListItem(id: 98, url: _baseurl + "static/icons/lobster.png"),
  new IconListItem(id: 99, url: _baseurl + "static/icons/spain2-circular.png"),
  new IconListItem(id: 100, url: _baseurl + "static/icons/boiling.png"),
  new IconListItem(id: 101, url: _baseurl + "static/icons/fortnite.png"),
  new IconListItem(id: 102, url: _baseurl + "static/icons/marijuana-leaf.png"),
  new IconListItem(
      id: 103,
      url: _baseurl + "static/icons/statue-of-christ-the-redeemer.png"),
  new IconListItem(id: 104, url: _baseurl + "static/icons/border-collie.png"),
  new IconListItem(id: 105, url: _baseurl + "static/icons/fry.png"),
  new IconListItem(id: 106, url: _baseurl + "static/icons/mdma.png"),
  new IconListItem(
      id: 107, url: _baseurl + "static/icons/stump-with-roots.png"),
  new IconListItem(id: 108, url: _baseurl + "static/icons/brazil-circular.png"),
  new IconListItem(id: 109, url: _baseurl + "static/icons/full-of-shit.png"),
  new IconListItem(id: 110, url: _baseurl + "static/icons/meowth.png"),
  new IconListItem(id: 111, url: _baseurl + "static/icons/sweden-circular.png"),
  new IconListItem(id: 112, url: _baseurl + "static/icons/brigadeiro.png"),
  new IconListItem(id: 113, url: _baseurl + "static/icons/gasoline-refill.png"),
  new IconListItem(id: 114, url: _baseurl + "static/icons/mexico-circular.png"),
  new IconListItem(
      id: 115, url: _baseurl + "static/icons/switzerland-circular.png"),
  new IconListItem(id: 116, url: _baseurl + "static/icons/buddha.png"),
  new IconListItem(
      id: 117, url: _baseurl + "static/icons/germany-circular.png"),
  new IconListItem(id: 118, url: _baseurl + "static/icons/music-band.png"),
  new IconListItem(id: 119, url: _baseurl + "static/icons/tapir.png"),
  new IconListItem(id: 120, url: _baseurl + "static/icons/call-me.png"),
  new IconListItem(id: 121, url: _baseurl + "static/icons/national-park.png"),
  new IconListItem(id: 122, url: _baseurl + "static/icons/the-sims.png"),
  new IconListItem(id: 123, url: _baseurl + "static/icons/canada-circular.png"),
  new IconListItem(
      id: 124, url: _baseurl + "static/icons/great-britain-circular.png"),
  new IconListItem(id: 125, url: _baseurl + "static/icons/nightmare.png"),
  new IconListItem(id: 126, url: _baseurl + "static/icons/trust.png"),
  new IconListItem(id: 127, url: _baseurl + "static/icons/car-fire.png"),
  new IconListItem(
      id: 128, url: _baseurl + "static/icons/group-of-animals.png"),
  new IconListItem(
      id: 129, url: _baseurl + "static/icons/nintendo-gamecube-controller.png"),
  new IconListItem(id: 130, url: _baseurl + "static/icons/under-computer.png"),
  new IconListItem(id: 131, url: _baseurl + "static/icons/caveman.png"),
  new IconListItem(id: 132, url: _baseurl + "static/icons/headache.png"),
  new IconListItem(id: 133, url: _baseurl + "static/icons/no-drugs.png"),
  new IconListItem(id: 134, url: _baseurl + "static/icons/undertale.png"),
  new IconListItem(id: 135, url: _baseurl + "static/icons/chad-circular.png"),
  new IconListItem(id: 136, url: _baseurl + "static/icons/hills.png"),
  new IconListItem(id: 137, url: _baseurl + "static/icons/norway-circular.png"),
  new IconListItem(id: 138, url: _baseurl + "static/icons/usa-circular.png"),
  new IconListItem(id: 139, url: _baseurl + "static/icons/chickenpox.png"),
  new IconListItem(id: 140, url: _baseurl + "static/icons/hitler.png"),
  new IconListItem(id: 141, url: _baseurl + "static/icons/nuke.png"),
  new IconListItem(id: 142, url: _baseurl + "static/icons/ussr-circular.png"),
  new IconListItem(id: 143, url: _baseurl + "static/icons/china-circular.png"),
  new IconListItem(id: 144, url: _baseurl + "static/icons/holy-bible.png"),
  new IconListItem(id: 145, url: _baseurl + "static/icons/overwatch.png"),
  new IconListItem(id: 146, url: _baseurl + "static/icons/wake-up.png"),
  new IconListItem(id: 147, url: _baseurl + "static/icons/choir--v2.png"),
  new IconListItem(id: 148, url: _baseurl + "static/icons/improvement.png"),
  new IconListItem(id: 149, url: _baseurl + "static/icons/peace-pigeon.png"),
  new IconListItem(id: 150, url: _baseurl + "static/icons/wildfire.png"),
  new IconListItem(id: 151, url: _baseurl + "static/icons/city-buildings.png"),
  new IconListItem(id: 152, url: _baseurl + "static/icons/india-circular.png"),
  new IconListItem(id: 153, url: _baseurl + "static/icons/plasma-ball.png"),
  new IconListItem(id: 154, url: _baseurl + "static/icons/winner.png"),
  new IconListItem(id: 155, url: _baseurl + "static/icons/complaint.png"),
  new IconListItem(id: 156, url: _baseurl + "static/icons/insects.png"),
  new IconListItem(id: 157, url: _baseurl + "static/icons/pocket.png"),
  new IconListItem(id: 158, url: _baseurl + "static/icons/wring.png"),
  new IconListItem(id: 159, url: _baseurl + "static/icons/country.png"),
  new IconListItem(id: 160, url: _baseurl + "static/icons/internship.png"),
  new IconListItem(id: 161, url: _baseurl + "static/icons/pokeball-2.png"),
  new IconListItem(id: 162, url: _baseurl + "static/icons/cross.png"),
  new IconListItem(
      id: 163, url: _baseurl + "static/icons/ireland-circular.png"),
  new IconListItem(id: 164, url: _baseurl + "static/icons/cup-with-straw.png"),
  new IconListItem(id: 165, url: _baseurl + "static/icons/israel-circular.png"),
  new IconListItem(id: 166, url: _baseurl + "static/icons/pray.png"),
];

IconListItem getIconOrDefault(iconId) {
  try {
    return iconList.firstWhere((IconListItem litem) => litem.id == iconId);
  } catch (err) {
    return iconList.first;
  }
}

class IconListItem {
  final int id;
  final String url;

  IconListItem({this.id, this.url});
}

Map<String, RatingItem> ratingsMapForContext(Usergroup group, int subforum) {
  var relevantEntries = ratingIconMap.entries
      .where((element) =>
          element.value.allowedUsergroups == null ||
          element.value.allowedUsergroups.contains(group))
      .where((element) =>
          element.value.allowedSubforums == null ||
          element.value.allowedSubforums.contains(subforum));
  var map = new Map<String, RatingItem>();
  map.addEntries(relevantEntries);
  return map;
}

const double RATING_ICON_SIZE = 24;

Map<String, RatingItem> ratingIconMap = {
  'agree': new RatingItem(
    id: 'agree',
    name: 'Agree',
    url: "${_ratingsUrl}agree.png",
  ),
  'disagree': new RatingItem(
    id: 'disagree',
    name: 'Disagree',
    url: "${_ratingsUrl}disagree.png",
  ),
  'funny': new RatingItem(
    id: 'funny',
    name: 'Funny',
    url: "${_ratingsUrl}funny.png",
  ),
  'optimistic': new RatingItem(
    id: 'optimistic',
    name: 'Optimistic',
    url: "${_ratingsUrl}optimistic.png",
  ),
  'zing': new RatingItem(
    id: 'zing',
    name: 'Zing',
    url: "${_ratingsUrl}zing.png",
  ),
  'friendly': new RatingItem(
    id: 'friendly',
    name: 'Friendly',
    url: "${_ratingsUrl}friendly.png",
  ),
  'kawaii': new RatingItem(
    id: 'kawaii',
    name: 'かわいい',
    url: "${_ratingsUrl}cute.png",
  ),
  'sad': new RatingItem(
    id: 'sad',
    name: 'Sad',
    url: "${_ratingsUrl}sad.png",
  ),
  'artistic': new RatingItem(
    id: 'artistic',
    name: 'Artistic',
    url: "${_ratingsUrl}artistic.png",
  ),
  'informative': new RatingItem(
    id: 'informative',
    name: 'Informative',
    url: "${_ratingsUrl}informative.png",
  ),
  'idea': new RatingItem(
    id: 'idea',
    name: 'Idea',
    url: "${_ratingsUrl}idea.png",
  ),
  'winner': new RatingItem(
    id: 'winner',
    name: 'Winner',
    url: "${_ratingsUrl}winner.png",
  ),
  'glasses': new RatingItem(
    id: 'glasses',
    name: 'Bad Reading',
    url: "${_ratingsUrl}badreading.png",
  ),
  'late': new RatingItem(
    id: 'late',
    name: 'Late',
    url: "${_ratingsUrl}late.png",
  ),
  'dumb': new RatingItem(
    id: 'dumb',
    name: 'Dumb',
    url: "${_ratingsUrl}dumb.png",
  ),
  'citation': new RatingItem(
      id: 'citation',
      name: 'Citation Needed',
      url: "${_ratingsUrl}citation.png",
      allowedSubforums: [5]),
  'yeet': new RatingItem(
      id: 'yeet',
      name: 'Yeet',
      url: "${_ratingsUrl}yeet.png",
      allowedUsergroups: [
        Usergroup.moderator,
        Usergroup.admin,
        Usergroup.staff,
        Usergroup.moderatorInTraining
      ])
};

class RatingItem {
  final String id;
  final String name;
  final String url;
  final List<int> allowedSubforums;
  final List<Usergroup> allowedUsergroups;

  RatingItem(
      {this.id,
      this.url,
      this.name,
      this.allowedSubforums,
      this.allowedUsergroups});
}
