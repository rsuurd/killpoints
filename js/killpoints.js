route.start(true);

route('/', function() {
  riot.mount('#character-selection', 'character-selection');
});
route(function(region, realm, character, emissaries, weeklies) {
  var characterInfo = {
    region: region,
    realm: decodeURIComponent(realm).replace(/\+/g, ' '),
    character: decodeURIComponent(character)
  };

  if (emissaries) {
    characterInfo.emissaries = parseInt(emissaries)
  }

  if (weeklies) {
    characterInfo.weeklies = parseInt(weeklies)
  }

  riot.mount('#character-selection', 'character-selection', characterInfo);

  calculate(characterInfo, function(data) {
    riot.mount('#killpoints', 'killpoints', data);
  })
});

function calculate(characterInfo, callback) {
  riot.mount('#killpoints', 'loading');

  var url = 'https://' + encodeURIComponent(characterInfo.region) + '.api.battle.net/wow/character/' + encodeURIComponent(characterInfo.realm) + '/' + encodeURIComponent(characterInfo.character) + '?fields=progression,achievements,statistics&apikey=' + API_KEY;

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
        'region': characterInfo.region,
        'name': json.name,
        'avatar': json.thumbnail,
        'killpoints': getKillpoints(characterInfo, json)
      });
    }
  }).catch(function(error) {
    riot.mount('#killpoints', 'error', { message: error });
  });
}

function getKillpoints(characterInfo, json) {
  return Math.round(getDailyKillpoints(characterInfo, json.achievements) +
    getWeeklyChestKillpoints(characterInfo, json.achievements) + getDungeonKillpoints(json) + getRaidKillpoints(json.progression.raids));
}

function getDailyKillpoints(characterInfo, achievements) {
  var emissaries = 0;

  if (characterInfo.hasOwnProperty('emissaries')) {
    emissaries = characterInfo.emissaries;
  } else {
    var index = achievements.achievementsCompleted.indexOf(10671);

    if (index >= 0) {
      emissaries = moment(new Date()).diff(achievements.achievementsCompletedTimestamp[index], 'days') + 2;
    }
  }

  return emissaries * 4;
}

function getWeeklyChestKillpoints(characterInfo, achievements) {
  var weeklies = 0;

  if (characterInfo.hasOwnProperty('weeklies')) {
    weeklies = characterInfo.weeklies;
  } else {
    var index = achievements.achievementsCompleted.indexOf(10671);

    if (index >= 0) {
      weeklies = moment().diff(moment.max(CHEST_AVAILABLE, moment(achievements.achievementsCompletedTimestamp[index])), 'weeks');
    }
  }

  return weeklies * 15;
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
