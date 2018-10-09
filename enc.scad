//WYC H206 optocoupler
include <driveshaft.scad>
/*
translate([pcb_x/2,-pcb_y/2,0])
rotate(90, [0,0,1]) 
linear_extrude(height=1) 
translate([-1.59,-1.8,0])
import("test.dxf");
*/

in = 25.4;

h206_w = 0.250*in;
pcb_x=1.020*in;
pcb_y=0.940*in;
pcb_z=2;
pcb_tie_hole_1=0.600*in;
pcb_tie_hole_2=0.850*in;

h206_base_t = 2.7;

//$fn = 20;
h206_base_w = h206_w;
h206_base_l = 26;

hole_d = 3.2;
hole_centers = 20.5;
sensor_height = 11.4;
sensor_t = 4.1;
sensor_centers = 10;

// shaft encoder
encoder_d = 40;
encoder_neg_factor=1.1;
//encoder_d = 50;
teeth = 6;
tooth_length = 12;
pi = 3.1415926;
//tooth_width = (d*pi)/(teeth*2);
tooth_angle = 360 / (teeth*2);
bore = shaft_diameter+.5;
hub_d = bore * 1.25;
hub_h = bore*.5;

module h206() {
    

translate([sensor_centers/2,0,sensor_height/2])
cube([sensor_t,h206_base_w,sensor_height], center=true);

translate([-sensor_centers/2,0,sensor_height/2])
cube([sensor_t,h206_base_w,sensor_height], center=true);

// Beam
#translate([0,0,sensor_height-3])
    rotate(90, [0,1,0])
        cylinder(r=1.5, h=5, center=true);

difference() {
    
    hull() {
        translate([-h206_base_l/2+h206_base_w/2,0,h206_base_t/2]) 
        cylinder(r=h206_base_w/2, h=h206_base_t, center=true);
        translate([h206_base_l/2-h206_base_w/2,0,h206_base_t/2]) 
        cylinder(r=h206_base_w/2, h=h206_base_t, center=true);
    }
    translate([-hole_centers/2,0,h206_base_t/2]) 
    cylinder(r=hole_d/2, h = h206_base_t*3, center=true);
    translate([hole_centers/2,0,h206_base_t/2]) 
    cylinder(r=hole_d/2, h = h206_base_t*3, center=true);
}

}

//h206();

module wagon_wheel(t=1.5) {
    teeth =7;
tooth_angle = 360 / (teeth*2);
         gap_l = encoder_d;
        gap_off = tan(tooth_angle/2)*encoder_d;
    difference() {
        union() {
                   difference() {
                    cylinder(r = encoder_d/2, h = t, center=true);
                    for(i = [0 : teeth -1]) {
                        rotate(i*tooth_angle*2, [0,0,1])
                        linear_extrude(height = t*2, center=true)
                        polygon(points = [[0,0], [gap_l,gap_off], [gap_l,-gap_off]]);
                    }
                }
                cylinder(r = (encoder_d/2) - tooth_length, h = t, center = true);
                //outer ring
                difference() {
                    cylinder(r = (encoder_d/2), h = t, center = true);
                    cylinder(r = (encoder_d/2 - 1), h = 2*t, center = true);
                }
                translate([0,0,3])
                cylinder(r=5, h=6, center=true);
            }
            translate([0,0,-2])
            slot_shaft();
        }
}
//wagon_wheel();
module slot_shaft(d = 6, t = 3.5, h=10) {
    translate([0,0,h/2])
    difference() {
        cylinder(r=d/2, h=h, center=true);
        translate([0,5+t/2,0])
            cube([10,10,h+1], center=true);
        translate([0,-5-t/2,0])
            cube([10,10,h+1], center=true);
    }
}
//slot_shaft();
//wagon_wheel();
module shaft_encoder(neg = false) {
    $fn=40;
    neg_factor=encoder_neg_factor;
    neg_factor_z=1.2;
  washer = 1;
  washer_w=2;  
     if (neg) {
        //translate([0,0,-((hub_h*neg_factor_z)-hub_h)/2])
        //cylinder (r=(encoder_d/2)*neg_factor, h = hub_h*neg_factor_z);
 
          difference() {
        //translate([0,0,-washer])
        translate([0,0,-washer])
        cylinder (r=encoder_d/2*neg_factor, h = hub_h+washer*2);
        translate([0,0,hub_h])
        cylinder (r1=shaft_diameter/2+washer_w, r2=shaft_diameter/2+washer_w+(washer_w*2), h = washer*2);
        translate([0,0,-washer*2])
        cylinder (r2=shaft_diameter/2+washer_w, r1=shaft_diameter/2+washer_w+(washer_w*2), h = washer*2);
          }
         /*minkowski() {
            hull () 
                shaft_encoder();
            sphere(r=2, center=true);
        */
        
    }
    else {
        
        t = 1.5;

        gap_l = encoder_d;
        gap_off = tan(tooth_angle/2)*encoder_d;

        
        //translate([0,0,t/2])
        difference() {
            union() {
               translate([0,0,t/2])
               union() {
                difference() {
                    cylinder(r = encoder_d/2, h = t, center=true);
                    for(i = [0 : teeth -1]) {
                        rotate(i*tooth_angle*2, [0,0,1])
                        linear_extrude(height = t*2, center=true)
                        polygon(points = [[0,0], [gap_l,gap_off], [gap_l,-gap_off]]);
                    }
                }
                cylinder(r = (encoder_d/2) - tooth_length, h = t, center = true);
                //outer ring
                if (false) {
                difference() {
                    cylinder(r = (encoder_d/2), h = t, center = true);
                    cylinder(r = (encoder_d/2 - 1), h = 2*t, center = true);
                }
            }
            }
                difference() {
                translate([0,0,hub_h/2])
                cylinder(r = hub_d/2, h = hub_h, center = true);

                translate([0,0,t+(hub_h-t)/2])
                rotate(90, [1,0,0])
                cylinder (r=2, h = hub_d*2, center = true);
                }
            }
            cylinder(r = bore/2, h = bore*3, center = true);
        }
    }
}
//!intersection() {
//shaft_encoder(neg=false);
//shaft_encoder(neg=true);
//}
module pcb_holes() {
    $fn=20;
        translate([-pcb_x/2+pcb_x/2,-pcb_y/2+pcb_tie_hole_1,0]) 
            cylinder(r = 1.5, h = 8, center = true);
        translate([-pcb_x/2+pcb_x/2,-pcb_y/2+pcb_tie_hole_2,0]) 
            cylinder(r = 1.5, h = 8, center = true); 
}

module pcb_bolt_clearance() {
    $fn=20;
 //       translate([-pcb_x/2,-pcb_y/2,0]) 
 //           cylinder(r = 1.5, h = 20, center = true);
        translate([-pcb_x/2+pcb_x/2,-pcb_y/2+pcb_tie_hole_1,0]) 
            cylinder(r = 0.100*in/2, h = 20, center = true);
        translate([-pcb_x/2+pcb_x/2,-pcb_y/2+pcb_tie_hole_2,0]) 
            cylinder(r = 0.100*in/2, h = 20, center = true);
/*
        translate([-hole_centers/2,-pcb_y/2+h206_w/2,-14]) 
            cylinder(r = 2.5, h = 20, center = true);
        translate([hole_centers/2,-pcb_y/2+h206_w/2,-14]) 
            cylinder(r = 2.5, h = 20, center = true);
        translate([-hole_centers/2,-pcb_y/2+h206_w+h206_w/2,-14]) 
            cylinder(r = 2.5, h = 20, center = true);
        translate([hole_centers/2,-pcb_y/2+h206_w+h206_w/2,-14]) 
            cylinder(r = 2.5, h = 20, center = true);
 */
}

module encoder_pcb(neg = false) {
   
    $fn=20;
    difference() {
        
        union() {
             translate([0,-pcb_y/2+h206_w/2,0])
                color([.3,.3,.3])
                    h206();
            translate([0,-pcb_y/2+h206_w+h206_w/2,0])
                color([.3,.3,.3]) h206();
            translate([0,0,-1])
                cube([pcb_x,pcb_y,pcb_z], center=true);
        }
        if (! neg) {
            pcb_holes();
        }
    }
    if (neg) {
        //pcb_holes();
        translate([0,0,pcb_z/2+12/2-2])
        cube([pcb_x+2,pcb_y+2,pcb_z+12], center=true);
    }
}

module pcb_disp() {
    encoder_disp()
    translate([+pcb_x/2-h206_w,encoder_d/2+h206_base_t+2.5,1]) //1.5 encoder t/2
    rotate(180, [0,1,0])
    rotate(90, [0,0,1])
    rotate(-90, [0,1,0]) children();
}

module encoder_disp() {
     translate([0,0,-19]) children();
}

//encoder_disp() shaft_encoder();
//pcb_disp() encoder_pcb(neg=false);
//%encoder_pcb(neg=true);
//#pcb_bolt_clearance();

