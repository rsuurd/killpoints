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

  var url = 'https://' + encodeURIComponent(region) + '.api.battle.net/wow/character/' + encodeURIComponent(realm) + '/' + encodeURIComponent(character) + '?fields=progression,achievements&apikey=' + API_KEY;

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
  return Math.round(getDailyKillpoints(json.achievements) + getWeeklyChestKillpoints(json.achievements) + getMythicPlusKillpoints(json.achievements) + getRaidKillpoints(json.progression.raids));
}

function getDailyKillpoints(achievements) {
  var killpoints = 0;

  var index = achievements.achievementsCompleted.indexOf(10671);

  if (index >= 0) {
    var days110 = moment(new Date()).diff(achievements.achievementsCompletedTimestamp[index], 'days');

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

function getMythicPlusKillpoints(achievements) {
  var killpoints = 0;

  KEYSTONES.forEach(function(keystone) {
    var index = achievements.criteria.indexOf(keystone);

    killpoints += (index < 0) ? 0 : achievements.criteriaQuantity[index] * 4;
  });

  return killpoints;
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

const KEYSTONES = [
  33096, // Initiate
  33097, // Challenger
  33098, // Conqueror
  32028  // Master
];

const RAIDS = {
  8440: 'Trial of Valor',
  8025: 'Nighthold',
  8026: 'Emerald Nightmare'
};
