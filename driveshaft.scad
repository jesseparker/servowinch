shaft_height=100;
shaft_diameter=18.5;

module driveshaft() {
    echo(shaft_diameter);
    cylinder(r=shaft_diameter/2, h = shaft_height, center=true);
}

