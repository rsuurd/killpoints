<character-selection>
  <div class="card">
    <div class="card-block">
      <h1 class="display-3 card-title">Killpoints</h1>
      <p class="card-text">Want to know when you are due for you next legendary?</p>

      <form class="form-inline" onsubmit={ calculateKillpoints }>
        <input type="text" class="form-control" ref="realm" placeholder="EU Twisting Nether">
        <input type="text" class="form-control" ref="character" placeholder="Character name">

        <input type="submit" class="btn btn-primary" value="Calculate">
      </form>
    </div>
  </div>
  <script>
    calculateKillpoints(event) {
      event.preventDefault();

      var realm = this.refs.realm.value.substring(0, 2).trim().toLowerCase();
      var server = this.refs.realm.value.substring(2).trim().toLowerCase();
      var charactername = this.refs.character.value.trim().toLowerCase();

      route([realm, server, charactername].join('/'));
    }
  </script>
</character-selection>
