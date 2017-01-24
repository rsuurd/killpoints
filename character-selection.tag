<character-selection>
  <div class="card">
    <div class="card-block">
      <h1 class="display-3 card-title">Killpoints</h1>
      <p class="card-text">Want to know when you are due for your next legendary?</p>

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
      var realm = this.refs.realm.value.trim().toLowerCase();
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
