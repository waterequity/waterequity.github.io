var map, heatmap;
var csvData;
var town = new google.maps.MVCArray();

// Size of the main container with magins
var margin = {top: 30, right: 10, bottom: 10, left: 10},
    width = parseInt(d3.select('#mainContainer').style('width')) - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

// Scale to place the dimensions
var x = d3.scale.ordinal().rangePoints([0, width], 1);
// Scale for each of the dimensions
var  y = {};
// Line 
var line = d3.svg.line();
// Dimension axis
var axis = d3.svg.axis().orient("left");
// Variable holding a subgroup of lines in gray
var background;
// Variable holding a subgroup of lines in color
var foreground;
// Color scale
var color = d3.scale.category20();
// A bunch of crap (--> is it useful ?)
var map;
var heatmap, binList;
var town = new Array();

// Add a SVG which will contain the parallel coordinates
var svg = d3.select("#chartContainer1").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// Add a SVG to hold the selection text (--> replace text with a table under parallel coord.)
var svgtext = d3.select("#label").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", 50 + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// Load the data
d3.csv("data.csv", function(error, data) {

  // Creating a new variable to hold the visibility status and colors
  data.forEach(function(d, i) { 
    d.visible = true;
    d.color = color(i);
   });

  // Saving data in a global scope (use outside of d3.csv)
  csvData = data;

  // Extract the list of dimensions and create a scale for each.
  x.domain(dimensions = d3.keys(data[0]).filter(function(d) {
    // Avoid dimensions with the following names
    return d != "name" &&  d != "visible" && d != "color" && d != "lat" && d !="long" && 
    (y[d] = d3.scale.linear()
    // Get the min and max to scale the domain
        .domain(d3.extent(data, function(p) { return +p[d]; }))
        .range([height, 0]));
  }));

  // Add grey background lines for context.
  background = svg.append("g")
      .attr("class", "background")
    .selectAll("path")
      .data(data)
    .enter().append("path")
      .attr("d", path);

  // Add colored foreground lines for focus.
  foreground = svg.append("g")
      .attr("class", "foreground")
    .selectAll("path")
      .data(data)
    .enter().append("path")
      .attr("d", path)
      .style('stroke-width', '1.5')
      .style('stroke', function(d) { return d.color; })
      // Add text when mouseover
      .on("mouseover", function(d){
         svgtext.select("text").remove();
         svgtext.append("text")
        .attr("font-size", '150%')
        .attr("x", '50px')
        .attr("y", '25px')
        .text( function () { return String(d.name); });
      });

  // Add a group element for each dimension.
  var g = svg.selectAll(".dimension")
      .data(dimensions)
    .enter().append("g")
      .attr("class", "dimension")
      .attr("transform", function(d) { return "translate(" + x(d) + ")"; });

  // Add an axis and title.
  g.append("g")
      .attr("class", "axis")
      .each(function(d) { d3.select(this).call(axis.scale(y[d])); })
    .append("text")
      .style("text-anchor", "middle")
      .attr("y", -9)
      .text(function(d) { return d; });

  // Add and store a brush for each axis.
  g.append("g")
      .attr("class", "brush")
      .each(function(d) { d3.select(this)
        .call(y[d].brush = d3.svg.brush().y(y[d])
        .on("brush", brush).on("brushend", brushend)); })
    .selectAll("rect")
      .attr("x", -8)
      .attr("width", 16);

  initialize();
});

function path(d) {
  return line(dimensions.map(function(p) { return [x(p), y[p](d[p])]; }));
}

// Handles a brush event, toggling the display of foreground lines.
function brush() {
  // Get all the active brushes (the one that are not empty)
  var actives = dimensions.filter(function(p) { return !y[p].brush.empty(); });
  // Get the min and max covered by active brushes
  var extents = actives.map(function(p) { return y[p].brush.extent(); });

  // For all the foreground lines change the display property
  foreground.style("display", function(d) {
    // True only if every active brush cross the line
    bool = actives.every(function(p, i) {
      return extents[i][0] <= d[p] && d[p] <= extents[i][1];
    }) ? null : "none";
    if (bool == "none"){
      d.visible = false;
    }
    else {
      d.visible = true;
    }
    return bool;
  }); 
}

// Once the brush event is finished (mouse released)
function brushend() {
  // Empty town array
  while(town.length > 0) {
        town.pop();
    }

  for (i = 0; i < csvData.length; i++) {
    if (csvData[i].visible) {
      town.push(new google.maps.LatLng(csvData[i].lat, csvData[i].long));
    }
  }

  heatmap.setData(town);
}

function initialize() {
    map = new google.maps.Map(document.getElementById('map'), {
    zoom: 6,
    center: {lat: 36.775, lng: -119.434},
     mapTypeId: google.maps.MapTypeId.TERRAIN,
      panControl: true,
      scrollwheel: false,
      mapTypeControl: false,
      panControlOptions: {
          position: google.maps.ControlPosition.RIGHT_CENTER
      },
      zoomControl: true,
      zoomControlOptions: {
          style: google.maps.ZoomControlStyle.LARGE,
          position: google.maps.ControlPosition.RIGHT_CENTER
      },
      scaleControl: false,
      streetViewControl: false,
      streetViewControlOptions: {
          position: google.maps.ControlPosition.RIGHT_CENTER
      }
  });

  csvData.forEach(function(d){
       town.push(new google.maps.LatLng(d.lat, d.long))
  });

  heatmap = new google.maps.visualization.HeatmapLayer({
    data: town,
    map: map
  });
  
  heatmap.set('radius', 15)
  heatmap.set('opacity', 0.8)
}