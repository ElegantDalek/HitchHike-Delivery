var streets = [];
var people = [];
var id = 0;
var CARRIER_CONSTANT = .7;
var SPAWN_PACKAGE = .9;
var SPAWN_PERSON = .1;
var stopped = false;

function Coords(x,y){
    this.x = x;
    this.y = y;
}
function Person() {
    this.type = "person";
    this.id = id;
    if (Math.random() > CARRIER_CONSTANT) {
        this.carrier = true;
        this.color = "green";
    } else {
        this.carrier = false;
        this.color = "yellow";
    }
    this.drawPerson = function () {
        $("body").append("<div id='" + this.id + "' class='person " + this.color + "'>" + this.id + "</div>");
        if (Math.random() > .5) {
            this.retrograde = true;
            $("#" + this.id).css({
                "left": (this.street.end.x + 2.5) + "px",
                "top": (this.street.end.y + 2.5) + "px"
            });
            this.position = new Coords(this.street.end.x, this.street.end.y);
        }else{
            this.retrograde = false;
            $("#" + this.id).css({
                "left": this.street.start.x + "px",
                "top": this.street.start.y + "px"
            });
            this.position = new Coords(this.street.start.x, this.street.start.y);
        }
    };
    this.suicide = function () {
        this.walkPerson = function(){$("#"+this.id).hide()};
    };
    this.walkPerson = function () {
        var priorx = this.position.x;
        var priory= this.position.y;
        if (this.retrograde) {
            var MULTIPLIER = -1
        } else {
            var MULTIPLIER = 1;
        }
        if (this.street.orientation == "vertical") {
            this.position.y = this.position.y + 26 * MULTIPLIER;
        } else if (this.street.orientation == "horizontal") {
            this.position.x = this.position.x + 26 * MULTIPLIER;
        }
        $("#" + this.id).animate({
            "left": this.position.x + "px",
            "top": this.position.y + "px"
        }, 100);
        if(this.position.x<0||this.position.x>1000||this.position.y<0||this.position.y>600){this.suicide()}
    };
    id++;
    var streetselect = Math.floor(Math.random() * streets.length);
    this.street = streets[streetselect];
    streets[streetselect].contents.push(this);
}
function Package(){
    this.type="package";
    this.id=id;
    id++;
    this.drawPackage = function () {
        $("body").append("<div id='" + this.id + "' class='package'>" + this.id + "</div>");
        $("#" + this.id).css({
            "left": this.position.x + "px",
            "top": this.position.y + "px"
        });
    };
    var origstselect = Math.floor(Math.random() * streets.length);
    this.origstreet = streets[origstselect];
    var deststselect = Math.floor(Math.random() * streets.length);
    this.deststreet = streets[deststselect];
    this.origstreet.contents.push(this);
    this.position = new Coords(this.origstreet.start.x+Math.random()*(this.origstreet.end.x-this.origstreet.start.x),
        this.origstreet.start.y+Math.random()*(this.origstreet.end.y-this.origstreet.start.y));
    console.log(this.position);
}
function Intersection(name,coords){
    this.name = name;
    this.place = coords;
}
function Street(name,start,end,len){
    this.start = start;
    this.contents = [];
    this.end = end;
    this.id = id;
    id++;
    this.name = name;
    this.length = len+20;
    this.intersections = [];
    if(start.x==end.x){
        this.orientation = "vertical";
    }else if(start.y==end.y){
        this.orientation= "horizontal";
    }
    //figure out diagonals later
    this.testIntersection= function(st){
        if(this.orientation==st.orientation){
            return false;
        }else{
            if(this.orientation=="vertical"&&st.orientation=="horizontal"){
                this.intersections.push([st.name,new Coords(this.start.x,st.start.y)]);
                st.intersections.push([this.name,new Coords(this.start.x,st.start.y)]);
                return true;
            }else if(this.orientation=="horizontal"&&st.orientation=="vertical"){
                this.intersections.push([st.name,new Coords(st.start.x,this.start.y)]);
                st.intersections.push([this.name,new Coords(st.start.x,this.start.y)]);
                return true;
            }
            //figure out diagonals later
        }
    };
    this.drawStreet= function(){
      $("body").append("<div id='"+this.id+"' class='street "+this.orientation+"'>"+this.name+"</div>");
      $("#"+this.id).css({
          "left": this.start.x+"px",
          "top": this.start.y+"px"
      });
      if(this.orientation=="vertical"){
          $("#"+this.id).height(this.length);
      }else if(this.orientation=="horizontal"){
          $("#"+this.id).width(this.length);
      }

    };
    for(var str of streets){
        this.testIntersection(str);
    }
    streets.push(this);
}
function step(){
    if(!stopped){
        if(Math.random()>SPAWN_PERSON){
            k = new Person();
            k.drawPerson();
        }
        if(Math.random()>SPAWN_PACKAGE){
            k = new Package();
            k.drawPackage();
        }
        for(var s of streets){
            for(var p of s.contents){
                if(p.type=="person"){
                    p.walkPerson();
                }
            }
        }
        setTimeout(step,100);
    }
}
function stop(){
    stopped = true;
}

var firststreet = new Street("First Street",new Coords(10,10),new Coords(10,610),600);
var secondstreet = new Street("Second Street",new Coords(110,10),new Coords(110,610),600);
var thirdstreet = new Street("Third Street",new Coords(210,10),new Coords(210,610),600);
var fourthstreet = new Street("Fourth Street",new Coords(310,10),new Coords(310,610),600);
var fifthstreet = new Street("Fifth Street",new Coords(410,10),new Coords(410,610),600);
var sixthstreet = new Street("Sixth Street",new Coords(510,10),new Coords(510,610),600);
var seventhstreet = new Street("Seventh Street",new Coords(610,10),new Coords(610,610),600);
var eighthstreet = new Street("Eighth Street",new Coords(710,10),new Coords(710,610),600);
var ninthstreet = new Street("Ninth Street",new Coords(810,10),new Coords(810,610),600);
var tenstreet = new Street("Tenth Street",new Coords(910,10),new Coords(910,610),600);
var elevenstreet = new Street("Eleventh Street",new Coords(1010,10),new Coords(1010,610),600);
var firstave = new Street("First Avenue",new Coords(10,10),new Coords(1010,10),1000);
var secondave = new Street("Second Avenue",new Coords(10,110),new Coords(1010,110),1000);
var thirdave = new Street("Third Avenue",new Coords(10,210),new Coords(1010,210),1000);
var fourthave = new Street("Fourth Avenue",new Coords(10,310),new Coords(1010,310),1000);
var fifthave = new Street("Fifth Avenue",new Coords(10,410),new Coords(1010,410),1000);
var sixthave = new Street("Sixth Avenue",new Coords(10,510),new Coords(1010,510),1000);
var seventhave = new Street("Seventh Avenue",new Coords(10,610),new Coords(1010,610),1000);

$(document).ready(function(){
    for(str of streets){
        str.drawStreet();
    }

});


console.log(streets);