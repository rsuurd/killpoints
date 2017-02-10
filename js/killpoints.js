route.start(true);

route('/', function() {
  riot.mount('#character-selection', 'character-selection');
});
route(function(region, realm, character) {
  var decodedRealm = decodeURIComponent(realm).replace(/\+/g, ' ');
  var decodedCharacter = decodeURIComponent(character);

  riot.mount('#character-selection', 'character-selection', { 'region': region, 'realm': decodedRealm, 'character': decodedCharacter });

  calculate(region, decodedRealm, decodedCharacter, function(data) {
    riot.mount('#killpoints', 'killpoints', data);
  })
});

function calculate(region, realm, character, callback) {
  riot.mount('#killpoints', 'loading');

  var url = 'https://' + encodeURIComponent(region) + '.api.battle.net/wow/character/' + encodeURIComponent(realm) + '/' + encodeURIComponent(character) + '?fields=progression,achievements,statistics&apikey=' + API_KEY;

  fetch(url, {
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
	}).then(function(response) {
    if (response.ok) {
      return response.json();
    } else {
      throw Error(response.statusText);
    }
  }).then(function(json) {
    if (json.level < 110) {
      throw Error('Level to 110 first.');
    } else {
      callback({
        'region': region,
        'name': json.name,
        'avatar': json.thumbnail,
        'killpoints': getKillpoints(json)
      });
    }
  }).catch(function(error) {
    riot.mount('#killpoints', 'error', { message: error });
  });
}

function getKillpoints(json) {
  return Math.round(getDailyKillpoints(json.achievements) +
    getWeeklyChestKillpoints(json.achievements) + getDungeonKillpoints(json) + getRaidKillpoints(json.progression.raids));
}

function getDailyKillpoints(achievements) {
  var killpoints = 0;

  var index = achievements.achievementsCompleted.indexOf(10671);

  if (index >= 0) {
    var days110 = moment(new Date()).diff(achievements.achievementsCompletedTimestamp[index], 'days');
    days110 += 2; //Add 2 extra dailies from first day of 110
 
    killpoints += days110 * 4;
  }

  return killpoints;
}

function getWeeklyChestKillpoints(achievements) {
  var killpoints = 0;

  var index = achievements.achievementsCompleted.indexOf(10671);

  if (index >= 0) {
    var weeklyChests = moment().diff(moment.max(CHEST_AVAILABLE, moment(achievements.achievementsCompletedTimestamp[index])), 'weeks');

    killpoints += weeklyChests * 15;
  }

  return killpoints;
}

function getDungeonKillpoints(json) {
  var normalDungeons = 0;
  var heroicDungeons = 0;
  var mythicDungeons = 0;

  json.statistics.subCategories.find(subCategory =>
      subCategory.id == 14807).subCategories.find(subCategory => subCategory.id == 15264).statistics.forEach(dungeon => {
    normalDungeons += (NORMAL_DUNGEONS.indexOf(dungeon.id) < 0) ? 0 : dungeon.quantity;
    heroicDungeons += (HEROIC_DUNGEONS.indexOf(dungeon.id) < 0) ? 0 : dungeon.quantity;
    mythicDungeons += (MYTHIC_DUNGEONS.indexOf(dungeon.id) < 0) ? 0 : dungeon.quantity;
  });

  var index = json.achievements.criteria.indexOf(33096);
  var mythicPlusDungeons = (index < 0) ? 0 : json.achievements.criteriaQuantity[index];
  var mythicZeroDungeons = mythicDungeons - mythicPlusDungeons;

  return ((normalDungeons + heroicDungeons) * 2) + (mythicZeroDungeons * 3) + (mythicPlusDungeons * 4);
}

function getRaidKillpoints(raids) {
  var killpoints = 0;

  raids.forEach(function(raid) {
    if (RAIDS.hasOwnProperty(raid.id)) {
      raid.bosses.forEach(function(boss) {
        killpoints += boss.lfrKills * 2;
        killpoints += boss.normalKills * 3;
        killpoints += boss.heroicKills * 4;
        killpoints += boss.mythicKills * 6;
      });
    }
  });

  return killpoints;
}

const API_KEY = 'kr2bfgpv5wtx5entzwkvvq6kqpwfwg7e';

const CHEST_AVAILABLE = moment('2016-09-21');

const RAIDS = {
  8440: 'Trial of Valor',
  8025: 'Nighthold',
  8026: 'Emerald Nightmare'
};
