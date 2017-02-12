<simple-form>
  <form class="form-inline" onsubmit={ calculateKillpoints }>
    <select ref="region" class="custom-select" onchange = { listRealms }>
      <option value="">Choose region</option>

      <option each={ region in regions } value = { region }>{ region.toUpperCase() }</option>
    </select>
    <input type="text" class="form-control" ref="realm" placeholder="Region and realm" data-provide="typeahead" autocomplete="off" value={ opts.realm }>
    <input type="text" class="form-control" ref="character" placeholder="Character name" value={ opts.character }>

    <input type="submit" class="btn btn-primary" value="Calculate">
  </form>

  <a href="#" onclick={ showAdvancedForm }>Advanced</a>

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

    showAdvancedForm(event) {
      event.preventDefault();

      riot.mount('#form', 'advanced-form', { region: this.refs.region.value, realm: this.refs.realm.value, character: this.refs.character.value });
    }
  </script>
</simple-form>
