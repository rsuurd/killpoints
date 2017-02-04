<killpoints>
  <div class="card mt-1">
    <div class="card-block">
      <img src={ '//render-' + opts.region + '.worldofwarcraft.com/character/' + opts.avatar } class="rounded float-left"></img>

      <p class="card-text text-center killpoints">{ opts.name } has <strong>{ opts.killpoints}</strong> killpoints.</p>

      <p class="card-text text-center">{ estimate(opts.killpoints) }</p>

      <div class="py-2">
        <div class="progress progress-legendary float-left" if={ progress(killpoints) }>
          <div class="progress-bar bg-legendary" role="progressbar" style={ "width: " + progress(killpoints) + "%" }>
            Progress towards the next legendary: { Math.round(progress(killpoints)) }%
          </div>
        </div>

        <a href="http://www.wowhead.com/item=132452/sephuzs-secret" rel="item=132452" target="_blank">
          <img src="https://wow.zamimg.com/images/wow/icons/large/inv_jewelry_ring_149.jpg" class="rounded" height="32" width="32"></img>
        </a>
      </div>

      <table class="table table-sm">
        <thead>
          <tr>
            <th>Number of legendaries</th>
            <th class="text-right">Killpoints</th>
          </tr>
        </thead>
        <tbody>
          <tr each={ breakpoint, legendary in breakpoints }>
            <td if={ legendary == 0} class={ table-success: (breakpoint <= killpoints) }> 1 legendary</td>
            <td if={ legendary > 0} class={ table-success: (breakpoint <= killpoints) }> { legendary + 1} legendaries</td>
            <td class="text-right { table-success: (breakpoint <= killpoints) }">{ breakpoint }</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
  <script>
    this.killpoints = opts.killpoints;
    this.breakpoints = [194, 578, 1225, 2181, 4800, 9600];

    estimate(killpoints) {
      var message;

      if (killpoints > this.breakpoints[this.breakpoints.length - 1]) {
        message = 'Wow! You should have received over ' + this.breakpoints.length + ' legendaries!';
      } else {
        var amount = this.breakpoints.findIndex(function(breakpoint) {
          return breakpoint > killpoints;
        });

        if (amount == 0) {
          message = "Keep going! Your first legendary will be quick!";
        } else if (amount == 1) {
          message = "You should have received your first legendary by now.";
        } else {
          message = "You should have received " + amount + " legendaries so far.";
        }
      }

      return message;
    }

    progress(killpoints) {
      var amount = this.breakpoints.findIndex(function(breakpoint) {
        return breakpoint > killpoints;
      });

      if (amount < this.breakpoints.length) {
        var top = this.breakpoints[amount];

        var x = (killpoints / top) * 100;

        console.log(killpoints + ' / ' + top);

        return x;
      }
    }
  </script>
</killpoints>
