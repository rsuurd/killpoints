<character-selection>
  <div class="card">
    <div class="card-block">
      <h1 class="display-3 card-title">Killpoints</h1>
      <p class="card-text">Want to know when you are due for your next legendary? <a href="#" data-toggle="modal" data-target="#readme">How does this work?</a></p>

      <form class="form-inline" onsubmit={ calculateKillpoints }>
        <select ref="region" class="custom-select" onchange = { listRealms }>
          <option value="">Choose region</option>

          <option each={ region in regions } value = { region }>{ region.toUpperCase() }</option>
        </select>
        <input type="text" class="form-control" ref="realm" placeholder="Region and realm" data-provide="typeahead" autocomplete="off" value={ opts.realm }>
        <input type="text" class="form-control" ref="character" placeholder="Character name" value={ opts.character }>

        <input type="submit" class="btn btn-primary" value="Calculate">
      </form>
    </div>
  </div>

  <div id="readme" class="modal fade">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">How it works</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="alert alert-info text-center">
            <strong>Note:</strong> Enable character specific achivements in-game under <em>Interface > Social</em>.
          </div>

          <p>
            This calculator calculates your killpoints based on your character's battle.net profile.
            The following are considered:
          </p>

          <ul>
            <li><strong>Weekly chest</strong>: The amount of weeks your character has been 110. <em>This assumes your character has gotten a weekly chest every week.</em></li>
            <li><strong>Emissary caches</strong>: The amount of days your character has been 110. <em>This assumes your character has been doing emissary caches every day.</em></li>
            <li><strong>Dungeons</strong>: All difficulties count. Depleted mythic+ dungeons do count, but due to how this is tracked by battle.net they are valued as a regular mythic dungeon.</li>
            <li><strong>Raid boss kills</strong>: Boss kills in <em>Emerald Nightmare</em>, <em>Trial of Valor</em> and <em>Nighthold</em>. All difficulaties count.</li>
          </ul>

          <p>BG's/RBG's, arena wins, world bosses and rare mobs are <u>not included</u> in the calculation.</p>

          <h6>A note on alts</h6>
          <p>
            The calculator uses the <em>Level 110</em> achievement to determine the amount of potential emissary and weekly caches you've gotten.
            Because this is an accountwide achievement, it will use the date when your first character dinged 110, so the amount of killpoints will be too high for recently dinged alts.
            You can try enabling character-specific achievements ingame under <em>Interface > Social</em>.
          </p>
        </div>
      </div>
    </div>
  </div>
  <script>
    this.regions = Object.keys(REALMS);

    this.on('mount', function() {
      if (opts.region) {
        this.refs.region.value = opts.region;

        $(this.refs.realm).typeahead({ source: REALMS[this.refs.region.value] });
      }
    });

    calculateKillpoints(event) {
      event.preventDefault();

      var region = this.refs.region.value;
      var realm = this.refs.realm.value.trim().toLowerCase().replace(' ', '+');
      var charactername = this.refs.character.value.trim().toLowerCase();

      if (region && realm && charactername) {
        route([region, realm, charactername].join('/'));
      } else {
        riot.mount('#killpoints', 'error', { message: 'Please fill in a region, realm and character name'});
      }
    }

    listRealms(event) {
      $(this.refs.realm).typeahead({ source: REALMS[this.refs.region.value] });
    }
  </script>
</character-selection>
