<gauge>
  <style>
  .power-gauge g.arc {
    fill: steelblue;
  }

  .power-gauge g.pointer {
    fill: #999;
    stroke: #666;
  }
  
  .power-gauge g.label text {
    text-anchor: middle;
    font-size: 14px;
    font-weight: bold;
    fill: #666;
  }
  </style>

<div class="power-gauge">
    <h2>{ opts.title }</h2>
</div>
  
<script>
var gauge = function(container, configuration) {
  var that = {};
  var config = {
    size            : 200,
    clipWidth         : 200,
    clipHeight          : 110,
    ringInset         : 20,
    ringWidth         : 20,

    pointerWidth        : 10,
    pointerTailLength     : 5,
    pointerHeadLengthPercent  : 0.9,

    minValue          : 0,
    maxValue          : 250,

    minAngle          : -90,
    maxAngle          : 90,

    transitionMs        : 750,

    labelTicks          : 10,
    majorTicks          : 200,
    labelFormat         : d3.format('.0f'),
    labelInset          : 10,

    arcColorFn          : d3.interpolateHsl(d3.rgb('#33cc99'), d3.rgb('#dd0000'))
  };
  var range = undefined;
  var r = undefined;
  var pointerHeadLength = undefined;
  var value = 0;

  var svg = undefined;
  var arc = undefined;
  var scale = undefined;
  var ticks = undefined;
  var tickData = undefined;
  var pointer = undefined;

  var donut = d3.pie();

  function deg2rad(deg) {
    return deg * Math.PI / 180;
  }

  function newAngle(d) {
    var ratio = scale(d);
    var newAngle = config.minAngle + (ratio * range);
    return newAngle;
  }

  function configure(configuration) {
    var prop = undefined;
    for ( prop in configuration ) {
      config[prop] = configuration[prop];
    }

    range = config.maxAngle - config.minAngle;
    r = config.size / 2;
    pointerHeadLength = Math.round(r * config.pointerHeadLengthPercent);

    // a linear scale that maps domain values to a percent from 0..1
    scale = d3.scaleLinear()
      .range([0,1])
      .domain([config.minValue, config.maxValue]);

    ticks = scale.ticks(config.labelTicks);
    tickData = d3.range(config.majorTicks)
      .map(function() { return 1/config.majorTicks; });

    arc = d3.arc()
      .innerRadius(r - config.ringWidth - config.ringInset)
      .outerRadius(r - config.ringInset)
      .startAngle(function(d, i) {
        var ratio = d * i;
        return deg2rad(config.minAngle + (ratio * range));
      })
      .endAngle(function(d, i) {
        var ratio = d * (i+1);
        return deg2rad(config.minAngle + (ratio * range));
      });
  }
  that.configure = configure;

  function centerTranslation() {
    return 'translate('+r +','+ r +')';
  }

  function isRendered() {
    return (svg !== undefined);
  }
  that.isRendered = isRendered;

  function render(newValue) {
    svg = d3.select(container)
      .append('svg:svg')
      .attr('class', 'gauge')
      .attr('width', config.clipWidth)
      .attr('height', config.clipHeight);

    var centerTx = centerTranslation();

    var arcs = svg.append('g')
      .attr('class', 'arc')
      .attr('transform', centerTx);

    arcs.selectAll('path')
      .data(tickData)
      .enter().append('path')
      .attr('fill', function(d, i) {
        return config.arcColorFn(d * i);
      })
      .attr('d', arc);

    var lg = svg.append('g')
      .attr('class', 'label')
      .attr('transform', centerTx);
    lg.selectAll('text')
      .data(ticks)
      .enter().append('text')
      .attr('transform', function(d) {
        var ratio = scale(d);
        var newAngle = config.minAngle + (ratio * range);
        return 'rotate(' +newAngle +') translate(0,' +(config.labelInset - r) +')';
      })
      .text(config.labelFormat);

    var lineData = [ [config.pointerWidth / 2, 0], 
      [0, -pointerHeadLength],
      [-(config.pointerWidth / 2), 0],
      [0, config.pointerTailLength]];

    var pointerLine = d3.line().curve(d3.curveMonotoneY);
    var pg = svg.append('g').data([lineData])
      .attr('class', 'pointer')
      .attr('transform', centerTx);

    pointer = pg.append('path')
      .attr('d', function(d) { return pointerLine(d) +'Z';})
      .attr('transform', 'rotate(' +config.minAngle +')');

    update(newValue === undefined ? 0 : newValue);
  }
  that.render = render;

  function update(newValue, newConfiguration) {
    if ( newConfiguration  !== undefined) {
      configure(newConfiguration);
    }
    var ratio = scale(newValue);
    var newAngle = config.minAngle + (ratio * range);
    pointer.transition()
      .duration(config.transitionMs)
      .ease(d3.easeElastic)
      .attr('transform', 'rotate(' +newAngle +')');
  }
  that.update = update;

  configure(configuration);

  return that;
};

var container = this.root;
function onDocumentReady() {
  var powerGauge = gauge(container, {
    size: 300,
    clipWidth: 300,
    clipHeight: 300,
    ringWidth: 60,
    minValue: 50,
    maxValue: 250,
    transitionMs: 4000,
  });
  powerGauge.render();

  function updateReadings(data) {
    // just pump in random data here...
    powerGauge.update(Math.random() * 200 + 50);
  }

  // every few seconds update reading values
  updateReadings();
  setInterval(function() {
    updateReadings();
  }, 5 * 1000);
}

if ( !window.isLoaded ) {
  window.addEventListener("load", function() {
    onDocumentReady();
  }, false);
} else {
  onDocumentReady();
}
</script>
</gauge>
