<killpoints>
  <div class="card mt-1">
    <div class="card-block">
      <p class="card-text text-center killpoints">{ opts.name } has <strong>{ opts.killpoints}</strong> killpoints.</p>

      <p class="card-text text-center">{ estimate(opts.killpoints) }</p>
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
    this.breakpoints = [194, 772, 1997, 4178, 8978];

    estimate(killpoints) {
      var message;

      if (killpoints > this.breakpoints[this.breakpoints.length - 1]) {
        message = "Wow! You should have received over 5 legendaries!";
      } else {
        var amount = this.breakpoints.findIndex(function(breakpoint) {
          return breakpoint > killpoints;
        });

        if (amount == 0) {
          message = "Keep going! Your first legendary will be quick!";
        } else if (amount ==1 ) {
          message = "You should have received your first legendary by now.";
        } else {
          message = "You should have received " + amount + " legendaries so far.";
        }
      }

      return message;
    }
  </script>
</killpoints>
