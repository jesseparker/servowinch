include <MCAD/involute_gears.scad>;
include <driveshaft.scad>
use <12vmotor.scad>

//shaft_diameter = 18;
//shaft_height = 200;
//$fn=100;
		
     
//pi=3.14;
in=25.4;
dia=40;

ratio=.33;

N=30;
N2=floor(N*ratio);

//translate([0,0,30])
//cylinder(r=dia/2, h=1);

OD=dia;
    
P=(N+2)/OD;
p=180/P;

OD2=(N2+2)/P;
t=8;

biggear_height = t;
biggear_hub = t+8;
biggear_diameter = OD;
biggear_neg_factor = 1.1;

littlegear_height = t+2;
littlegear_diameter = OD2;
littlegear_neg_factor = 1.2;
    washer=1;
    washer_w=2;

gear_tooth_length = 2.6;

gear_distance = biggear_diameter/2+littlegear_diameter/2 - gear_tooth_length;

module biggear() {
difference(){
    gear (
			number_of_teeth =N,
			circular_pitch=p,
			gear_thickness = t,
			rim_thickness = t,
			rim_width = 1,
			hub_thickness = biggear_hub,
			hub_diameter=shaft_diameter *1.5,
			bore_diameter=shaft_diameter,
			backlash = 1,
			circles=0);
            

translate([0,0,t+(biggear_hub-t)/2])
rotate(90,[0,1,0])
cylinder(r=2.3,h=100,center=true);
}
}

//biggear();

module littlegear() {
    
difference(){
 gear (
			number_of_teeth =N2,
			circular_pitch=p,
			gear_thickness = littlegear_height,
			rim_thickness = littlegear_height,
			rim_width = 1,
			hub_thickness = 0,
			hub_diameter=25,
			bore_diameter=0,
			backlash = 0,
			circles=0
            );

translate([0,0,t/2])
dshaft(d=6.5,h=t*2);
    

}
}



module littlegear_setscrews() {
    
setscrew_z=13.5;
    
//rotate(360/N2/2,[0,0,1])
difference(){
 gear (
			number_of_teeth =N2,
			circular_pitch=p,
			gear_thickness = t,
			rim_thickness = t,
			rim_width = 1,
			hub_thickness = t+7,
			hub_diameter=25,
			bore_diameter=0,
			backlash = 0,
			circles=0
            );
    
translate([0,0,setscrew_z])
rotate(90,[0,1,0])
translate([0,0,50])
cylinder(r=1.8,h=100,center=true);
    
translate([0,0,setscrew_z])
rotate(90,[0,1,0])
translate([0,0,50+9])
cylinder(r=3,h=100,center=true);

translate([6,0,10+t+.5])
    cube([3,6.5,20], center=true);

translate([0,0,t+7+5-7])
dshaft(d=6.5,h=10);

rotate(90, [0,0,1]) {
translate([0,0,setscrew_z])
rotate(90,[0,1,0])
translate([0,0,50])
cylinder(r=1.8,h=100,center=true);

translate([0,0,setscrew_z])
rotate(90,[0,1,0])
translate([0,0,50+9])
cylinder(r=3,h=100,center=true);
translate([6,0,10+t+.5])
    cube([3,6.5,20], center=true);
    

}
}

}


module biggearvol(neg = false) {
    neg_factor=biggear_neg_factor;
    $fn=30;
    if (neg) {
        translate([0,0,-washer])

        difference() {
        cylinder (r=biggear_diameter/2*neg_factor, h = biggear_hub+washer*2);
        translate([0,0,biggear_hub+washer])
        cylinder (r1=shaft_diameter/2+washer_w, r2=shaft_diameter/2+washer_w+(washer_w*2), h = washer*2);
        translate([0,0,-washer])
        cylinder (r2=shaft_diameter/2+washer_w, r1=shaft_diameter/2+washer_w+(washer_w*2), h = washer*2);
       /*
        minkowski() {
            hull()
                biggear();
            cylinder(r=2, h=.5, center=true, $fn=10);
        }
        */
        }
    }
    else biggear();
}
//biggearvol(neg=false);

module littlegearvol(neg = false) {
    $fn=20;
    neg_factor=littlegear_neg_factor;
    neg_factor_z=littlegear_neg_factor;
    
     if (neg) {
         translate([0,0,-((littlegear_height*neg_factor_z)-littlegear_height)/2])
        cylinder (r=littlegear_diameter/2*neg_factor, h = littlegear_height*neg_factor_z);
         
         /*
       minkowski() {
            hull()
                littlegear();
             cylinder(r=4, h=.5, center=true, $fn=10);
        }
         */
    }
    else littlegear();
}

//translate([gear_distance,0,0]) {

//rotate(180,[1,0,0])
//littlegearvol(neg=false);
//%littlegearvol(neg=true);
//}

//biggearvol(neg=false);
//%biggearvol(neg=true);