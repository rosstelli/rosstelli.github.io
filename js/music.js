/*
  MOUSEOVER with D3: http://bl.ocks.org/WilliamQLiu/76ae20060e19bf42d774
*/
var d;
var question = document.getElementById('question');

function generateQuestion() {
  load(getData());
}

function noteUpdate(value) {
  console.log(value);
  load(getData(value));
}

var frets = 25;
var stepDown = 0; // 0 is standard tuning
var baseString = ['E', 'A', 'D', 'G', 'B', 'E'];
var strings = baseString;
var notes = ['A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#'];
var currentScale = [];
var minor = [0, 2, 3, 5, 7, 8, 10];

var margin = {top: 50, right: 50, bottom: 50, left: 50},
    width = 2000 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;


var x = d3.scaleLinear().rangeRound([0, width]);
var y = d3.scaleLinear().rangeRound([height, 0]);

var svg = d3.select("body")
    .append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
    .append("g")
        .attr("transform",
              "translate(" + margin.left + "," + margin.top + ")");

function getData(
  starting_note = notes[Math.floor(Math.random() * 12) % 12] // pick random by default
) {
  var data = [];

  document.getElementById('question').innerHTML = starting_note + ' minor scale';

  for (var i = 0; i < strings.length; i++) {
    for (var j = 0; j < frets; j++) {
      var currentNote = getNote(i, j);
      var color = '#AA0000';
      generateScale(starting_note);
      if (isInScale(currentNote)) {
        color = '#00AA00';
      }

      data.push(
        {
          "string": i,
          "frets": j,
          "offset": stepDown,
          "note": currentNote,
          "color": color
        }
      );
    }
  }

  return data;
}

function noteToIndex(note) {
  return notes.indexOf(note);
}

function getNote(i, j) {
  var currentString = strings[i];
  var stringIndex = noteToIndex(currentString);
  var newNote = (stringIndex + j) % 12;
  return notes[newNote];
}

function isInScale(note) {
  return (currentScale.indexOf(note) >= 0);
}


function generateScale(start_note) {
  var index = noteToIndex(start_note);
  currentScale = [];
  for (var i in minor) {
    currentScale.push(
      notes[(index + minor[i])%12]
    )
  }
  return currentScale;
}

function load( data ) {
  d = data;

  d3.select("rect").selectAll("*").remove();
  d3.select("text").selectAll("*").remove();
  d3.select("line").selectAll("*").remove();
  d3.select("g").selectAll("*").remove();
  d3.select("path").selectAll("*").remove();
  d3.select("dot").selectAll("*").remove();
  d3.select("circle").selectAll("*").remove();


  x.domain([0, d3.max(data, function(d) { return d.frets; })]);
  var y_max = d3.max(data, function(d) { return d.string; });
  y.domain([0, y_max]);

  // Create Event Handlers for mouse
  function handleMouseOver(d, i) {  // Add interactivity
    // Use D3 to select element, change color and size
    d3.select(this)
      .attr("stroke","black")
      .style("stroke-width", "4");
  }

  function handleMouseOut(d, i) {
    // Use D3 to select element, change color back to normal
    console.log(this)
    d3.select(this)
      .attr("stroke","black")
      .style("stroke-width", "0");
  }

  // Add the scatterplot
  svg.selectAll("dot")
      .data(data)
    .enter().append("circle")
      .attr("r", 30)
      .attr("cx", function(d) { return x(d.frets); })
      .attr("cy", function(d) { return y(d.string); })
      .attr("fill", function(d) { return d.color; })
      .attr("onclick", "testMe()")
      .on("mouseover", handleMouseOver)
      .on("mouseout", handleMouseOut);

  svg.selectAll("text")
      .data(data)
    .enter().append("text")
      .text( function (d) { return d.note; })
      .attr("text-anchor", "middle")
      .attr("x", function(d) { return x(d.frets); })
      .attr("y", function(d) { return y(d.string); })
      .style("font-weight", "900")
      .style("fill", "#FFFFFF");

  svg.selectAll("text")
      .data(data)
    .enter().append("text")
      .text( function (d) { return d.frets; })
      .attr("text-anchor", "middle")
      .attr("x", function(d) { return x(d.frets); })
      .attr("y", function(d) { return y(d.string); })
      .style("font-weight", "900")
      .style("fill", "#FFFFFF");
}

function testMe() {
  console.log("fdsa");
}


load(getData('E'));
