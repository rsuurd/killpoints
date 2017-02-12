<advanced-form>
  <form onsubmit={ calculateKillpoints }>
    <div class="form-group" style="display: flex">
      <select ref="region" class="custom-select" onchange = { listRealms }>
        <option value="">Choose region</option>

        <option each={ region in regions } value = { region }>{ region.toUpperCase() }</option>
      </select>
      <input type="text" class="form-control" ref="realm" placeholder="Region and realm" data-provide="typeahead" autocomplete="off" value={ opts.realm }>
      <input type="text" class="form-control" ref="character" placeholder="Character name" value={ opts.character }>
    </div>
    <div class="form-group row">
      <div class="col-sm-6">
        <input type="number" class="form-control" ref="emissaries" placeholder="Emissary caches (optional)" min="0">
      </div>
      <div class="col-sm-6">
        <input type="number" class="form-control" ref="weeklies" placeholder="Weekly chests (optional)" min="0">
      </div>
    </div>
    <div class="form-group">
      <a href="#" onclick={ showSimpleForm }>Simple</a>

      <input type="submit" class="btn btn-primary pull-right" value="Calculate">
    </div>
  </form>

  <script>
    this.regions = Object.keys(REALMS);

    this.on('mount', function() {
      if (opts.region) {
        this.refs.region.value = opts.region;

        $(this.refs.realm).typeahead({ source: REALMS[this.refs.region.value] });
      }
    });

    function appendParameter(url, name, value) {
      return url.match( /[\?]/g ) ? '&' : '?' + name + '=' + value;
    }

    calculateKillpoints(event) {
      event.preventDefault();

      var region = this.refs.region.value;
      var realm = this.refs.realm.value.trim().toLowerCase().replace(' ', '+');
      var charactername = this.refs.character.value.trim().toLowerCase();
      var emissaries = this.refs.emissaries.value.trim();
      var weeklies = this.refs.weeklies.value.trim();

      if (region && realm && charactername) {
        var url = [region, realm, charactername].join('/');

        if (emissaries) {
          url += '?emissaries=' + emissaries;
        }

        if (weeklies) {
          url += (url.indexOf('?') ? '&' : '?') + 'weeklies=' + weeklies;
        }

        route(url);
      } else {
        riot.mount('#killpoints', 'error', { message: 'Please fill in a region, realm and character name'});
      }
    }

    listRealms(event) {
      $(this.refs.realm).typeahead({ source: REALMS[this.refs.region.value] });
    }

    showSimpleForm(event) {
      event.preventDefault();

      riot.mount('#form', 'simple-form', {
        region: this.refs.region.value,
        realm: this.refs.realm.value,
        character: this.refs.character.value
      });
    }
  </script>
</advanced-form>
