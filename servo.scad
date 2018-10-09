include <driveshaft.scad>
include <enc.scad>;
include <gears.scad>;
include <12vmotor.scad>;
shaft_height = 300;
//$fs = .2;



gm_z_offset = 18;
gm_shaft_offset = 8;
controller_length=58;
enclosure_thickness = 1.5;


//dia=10; // main gear d;
//encoder_d = 20;
//gm_major_diameter=18.5;
dictated_assembly_height=0;
dictated_assembly_width=0;
dictated_assembly_length=0;

assembly_height = max(
    biggear_diameter*biggear_neg_factor/2 + enclosure_thickness,
    encoder_d*encoder_neg_factor/2 + enclosure_thickness,
    gm_major_diameter/2 + enclosure_thickness,
    dictated_assembly_height
);

assembly_width = max(
    gm_major_diameter + dia + enclosure_thickness*2,
    dictated_assembly_width
);

assembly_length = max(
    gm_major_length + gm_z_offset + enclosure_thickness,
    dictated_assembly_length
);

echo ("max");
echo (assembly_height);
case_bolts = [
// [x,y,        rotation of trap
    [-4,-29,     -1],
    [-6,37,     -1],
 //   [40,16,     -1],
 //   [40,64.5,     -1],
 //   [97,40,     -1],
    [83,-20,     -1],
    [83,18,     -1],
];


module case_bolt_clearance(rot=0, boss=false) {
    //rotate(90,[1,0,0])
    //rotate(90,[0,1,0])

    if (boss) {
        cylinder(r=4.2, h=9, center=true);
    }
    else {
        cylinder(r=1.5, h=30, center=true);
        translate([0,0,54])
            cylinder(r=3.5, h=100, center=true);
        translate([0,0,2.25])
            cylinder(r=2, h=4.5, center=true);
        /*
        if(rot == -1) {
        translate([0,0,-54])
            cylinder(r=3, h=100, center=true);
        }
        else {
            rotate(rot, [0,0,1])
            translate([7,0,-5])
            cube([20,6,2], center=true);           
        }
        */
    }
    
}

module case_boltholes(boss = boss) {
    rotate(-90,[0,1,0])
    for (i = case_bolts) {
        translate([i[0],i[1],0])
        case_bolt_clearance(i[2], boss=boss);
    }
}
//case_boltholes();

//cylinder(r=18/2,h=300, center=true);
//driveshaft();

/*
%union() {
    translate([30,0,-15])
    cube([90,80,20], center=true);

    translate([30,0,55])
    cube([90,80,30], center=true);

    translate([60,0,20])
    cube([30,80,100], center=true);
}
translate([0,0,200])
*/

//servoneg();
//hull() {
module pcb_disp() {
    encoder_disp()
    translate([+pcb_x/2-h206_w,encoder_d/2+h206_base_t+2.5,1.5]) //1.5 encoder t/2
    rotate(180, [0,1,0])
    rotate(90, [0,0,1])
    rotate(-90, [0,1,0]) children();
}

module encoder_disp() {
     translate([0,0,-19]) children();
}

module drive_gear_disp() {
    
        translate([0,gear_distance,0])
            rotate(-90,[0,0,1]) children();
}

module gm_disp() {
    drive_gear_disp()
    rotate(180,[0,0,1])
            gm_shaft_disp()
                rotate(180, [0,0,1])
                    translate([0,0,gm_z_offset])
//   rotate(50,[0,0,1])
                        children();
}

module controller_disp() {
    translate([-gm_major_diameter/2-enclosure_thickness,gear_distance+gm_shaft_offset,controller_length/2+gm_z_offset])
    children();
}

module sub_gears_encoder(neg = neg) {
       encoder_disp()
            // Encoder rotation
            //rotate(20,[0,0,1])
            color("blue") shaft_encoder(neg = neg);
        color("red") biggearvol(neg = neg);
     drive_gear_disp()
       color("yellow") littlegearvol(neg = neg);

}
module assembly(neg = false) {
    
        sub_gears_encoder(neg = neg);
        pcb_disp()
            encoder_pcb(neg=neg);
        gm_disp()
            12vmotor(neg = neg);
        controller_disp()
            controller();
}

module enclosure_blank(neg = true, t = enclosure_thickness) {
    $fn = 30;
    //minkowski() {
        //union() {
            minkowski() {
                hull()
                    sub_gears_encoder(neg = neg);
                sphere(r=t, center=true, $afn = 10); 
            }
            minkowski() {
                hull()
                    pcb_disp()
                        encoder_pcb(neg=neg);
                sphere(r=t, center=true, $afn = 10); 
            }
            minkowski() {
                hull()
                    gm_disp()
                        12vmotor(neg = neg);
                sphere(r=t, center=true, $afn = 10); 
            }
            case_boltholes(boss=true);
   //       // }
}

//!enclosure_blank(neg=true);

//module enclosure_bolt_clearance() {
//    rotate(90,[1,0,0]) rotate(90,[0,1,0]) {
//        cylinder(r=2.5, h=100, center=true);
//        translate([0,0,54])
//            cylinder(r=3.5, h=100, center=true);
//        translate([0,0,-54])
//            cylinder(r=3.5, h=100, center=true);
//    }    
//}
module pillow(screws=true) {
base_t = 15;
tab_t = 8;
base_w1 = shaft_diameter+tab_t*2;
base_w2 = 70;
skew=0;
shift=0;
base_h = assembly_height;
hole_d=6;

screw_head_d=7;
screw_thread_3=3;
screw_shank_d=5;

screw_off = shaft_diameter/2 + tab_t/2;

    translate([0,shift,0])
    difference() {
    union() {
       //Trapezoid body
        hull() {
       cube([1,base_w1,base_t], center=true);
            cylinder(r=base_w1/2,h=base_t, center=true);
       translate([base_h-.5,skew,0])
            cube([1,base_w2,base_t], center=true);
        }
        difference() {
            //Base plate
        hull() {
            translate([base_h-tab_t/2,base_w2/2+hole_d/2,0])
                rotate(90,[0,1,0])
                    cylinder(r=base_t/2, h=tab_t, center=true);
            translate([base_h-tab_t/2,-base_w2/2-hole_d/2,0])
                rotate(90,[0,1,0])
                    cylinder(r=base_t/2, h=tab_t, center=true);
        }
        // Base screw holes
        translate([base_h,base_w2/2+4+skew,0])
            rotate(90,[0,1,0])
                cylinder(r=hole_d/2, h=40, center=true);
        translate([base_h,-base_w2/2-4+skew,0])
            rotate(90,[0,1,0])
                cylinder(r=hole_d/2, h=40, center=true);
        }
        
       
        
       
    }
    if (screws) {
     // Top screw holes
     translate([-10-4,-screw_off,0])
        rotate(90,[0,1,0])
            cylinder(r=screw_head_d/2, h=20, center=true);
     translate([-2.5,-screw_off,0])
        rotate(90,[0,1,0])
            cylinder(r=screw_shank_d/2, h=5, center=true);
     translate([-2.5,-screw_off,0])
        rotate(90,[0,1,0])
            cylinder(r=screw_thread_d/2, h=50, center=true);

     translate([-10-4,screw_off,0])
        rotate(90,[0,1,0])
            cylinder(r=screw_head_d/2, h=20, center=true);
     translate([-2.5,screw_off,0])
        rotate(90,[0,1,0])
            cylinder(r=screw_shank_d/2, h=5, center=true);
     translate([-2.5,screw_off,0])
        rotate(90,[0,1,0])
            cylinder(r=screw_thread_d/2, h=50, center=true);
    }
    //Oil hole
     translate([-25,0,0])
        rotate(90,[0,1,0])
            cylinder(r=screw_thread_d/2, h=50, center=true);
     translate([-25-shaft_diameter/2-tab_t+3,0,0])
        rotate(90,[0,1,0])
            cylinder(r=screw_shank_d/2, h=50, center=true);
driveshaft();
    }

}
module pillow_top() {
    difference() {
        pillow();
        translate([50,0,0]) cube([100,100,100], center=true);
    }
}
module pillow_bottom() {
     difference() {
        pillow();
        translate([-50,0,0]) cube([100,100,100], center=true);
    }   
}
module pillow_pair() {
    translate([-10,0,0]) pillow_top();
    pillow_bottom();
}
//pillow_pair();
//translate([0,0,140]) //rotate(180,[0,1,0]) pillow(screws=falses);
//pillow();
//pillow_top();
//pillow_bottom();

//driveshaft();
module base() {
base_t = t;
base_w1 = assembly_width;
base_w2 = base_w1;
skew=0;
shift=15;
base_h = assembly_height;
    tab_t = 8;
    
    translate([0,shift,0])
    difference() {
    union() {
   //translate([base_h/2,0,0])
    hull() {
   cube([1,base_w1,base_t], center=true);
   translate([base_h-.5,skew,0])
        cube([1,base_w2,base_t], center=true);
    }
    difference() {
       translate([base_h-tab_t/2,skew,0])
        cube([tab_t,base_w2+20,base_t], center=true);
    // base mount holes
    translate([base_h,base_w2/2+4+skew,0])
        rotate(90,[0,1,0])
            cylinder(r=3, h=40, center=true);
    translate([base_h,-base_w2/2-4+skew,0])
        rotate(90,[0,1,0])
            cylinder(r=3, h=40, center=true);
    }
}
    //cable channel through base
    translate([base_h-7,base_w1/2-9,0])
            cylinder(r=4, h=40, center=true);

}

    //translate([0,0,72]) pillow();
    translate([0,shift,72])
    difference() {
    union() {
   //translate([base_h/2,0,0])
    hull() {
   cube([1,base_w1,base_t], center=true);

   translate([0,-shift,0])
        //cube([1,base_w1,base_t], center=true);
        cylinder(r=pdia/2, h=base_t, center=true);
   translate([base_h-.5,skew,0])
        cube([1,base_w2,base_t], center=true);
    }
    difference() {
       translate([base_h-tab_t/2,skew,0])
        cube([tab_t,base_w2+20,base_t], center=true);
    // base mount holes
    translate([base_h,base_w2/2+4+skew,0])
        rotate(90,[0,1,0])
            cylinder(r=3, h=40, center=true);
    translate([base_h,-base_w2/2-4+skew,0])
        rotate(90,[0,1,0])
            cylinder(r=3, h=40, center=true);
    }
}
    //cable channel through base
    //translate([base_h-7,base_w1/2-9,0])
    //        cylinder(r=4, h=40, center=true);

}

//rotate(-90-pangle/2, [0,0,1])
//translate([0,0,18])
//fairleed_holder();

}
//base();

positions=12;
pangle=360/(positions);
pdia=50;

pwidth=pdia/2*sin(pangle/2)*2;
plen = pdia/2*cos(pangle/2);
pt=5;
ph=10;
poverlap=10;
pdistance = 38;

module fairleed_holder() {
    


//translate([0,0,17])
for (x = [0:positions]) {
    rotate(pangle*x, [0,0,1])
    translate([plen-pt/2,0,0])
    difference() {
        translate([0,0,-poverlap/2])
    cube([pt,pwidth,ph+poverlap], center=true);
        rotate(90,[0,1,0])
        cylinder(r=1.5, h=20, center=true);
    }
}


translate([0,0,pdistance])
for (x = [0:positions]) {
    rotate(pangle*x, [0,0,1])
    translate([plen-pt/2,0,0])
    difference() {
        translate([0,0,poverlap/2])
    cube([pt,pwidth,ph+poverlap], center=true);
        rotate(90,[0,1,0])
        cylinder(r=1.5, h=20, center=true);
    }
}
//translate([plen+pt/2,0,0])
//fairleed();
}

module fairleed() {
    difference() {
        
    union() {
        translate([0,0,pdistance/2])
            cube([pt,pwidth,pdistance+ph], center=true);
        translate([0,0,pdistance/2])
        rotate(90,[0,1,0])
        cylinder(r=10, h=pt, center=true);
    }
    
        translate([0,0,pdistance/2])
        rotate(90,[0,1,0])
        cylinder(r=5, h=20, center=true);
    
        translate([0,0,0])
        rotate(90,[0,1,0])
        cylinder(r=2, h=20, center=true);
    
        translate([0,0,pdistance])
        rotate(90,[0,1,0])
        cylinder(r=2, h=20, center=true);
    
        translate([0,0,pdistance/2+9])
        rotate(90,[0,1,0])
        cylinder(r=2, h=20, center=true);

}
}


module controller(neg = false) {
    if (neg) {
        translate([-7,0,0])
            cube([15,43,controller_length], center=true);
    } else {
        
        translate([-1,0,0])
        difference() {
            color("black")
                cube([2,43,58], center=true);
            translate([0,21.5-12,29-12])
                rotate(90,[0,1,0])
                    cylinder(r=1.5, h=10, center=true);
             translate([0,21.5-40.5,29-12])
                rotate(90,[0,1,0])
                    cylinder(r=1.5, h=10, center=true);
             translate([0,21.5-24,29-43])
                rotate(90,[0,1,0])
                    cylinder(r=1.5, h=10, center=true);
             translate([0,21.5-25.5,29-55.5])
                rotate(90,[0,1,0])
                    cylinder(r=1.5, h=10, center=true);
             translate([0,21.5-40.5,29-55.5])
                rotate(90,[0,1,0])
                    cylinder(r=1.5, h=10, center=true);
        }
        color("blue")
            translate([-7,0,24])
                cube([10,43,8], center=true);
        color("silver")
            translate([-6,15,-12])
                cube([8,10,32], center=true);
            
    }
}

module controller_mount() {
    difference() {
    hull() {
    translate([-.95,0,0])
        color("yellow")
            cube([2,41,56], center=true);
    translate([20,0,0])
        color("yellow")
            cube([2,31,46], center=true);
    }
             translate([0,21.5-24,29-43])
                rotate(90,[0,1,0])
                    cylinder(r=1.5, h=100, center=true);
    controller();
}
}


//controller();
//%controller(neg=true);
//controller_mount();

module enclosure() {

    
difference() {
    union() {
        // base
        translate([0,0,t/2])
            base();
        enclosure_blank();
        controller_disp()
            controller_mount(neg=false);
    }
    assembly(neg=true);
    pcb_disp() pcb_bolt_clearance();
    driveshaft();
    case_boltholes(boss=false);
    // Motor wire hole
    translate([12,40,88]) //rotate(90,[0,1,0])
        cylinder(r=3, h=20, center=true);
    // Encoder wire hole
    translate([20,22,-28]) rotate(90,[0,1,0])
        cylinder(r=3, h=20, center=true);

}
}
//!enclosure();
module enclosure_bottom() {
    difference() {
        enclosure();
        // slice
            translate([-50,0,0]) cube([100,300,300], center=true);
    }
}
//enclosure_bottom();
module enclosure_top() {
    difference() {
        enclosure();
        // slice
            translate([50,0,0]) cube([100,300,300], center=true);
    }
}
//intersection() {
//enclosure_top();
enclosure_bottom();
//enclosure_blank();
//enclosure();
//rotate(-90,[0,1,0])
//enclosure_top();
//rotate(90,[0,1,0])
//enclosure_bottom();
//intersection() {
 //   enclosure_top();
//pcb_bolt_clearance();
//encoder_pcb(neg=true);
//projection(cut=true)
//rotate(90, [0,1,0])
//assembly(neg = false);
//%assembly(neg = true);
//pcb_disp() pcb_bolt_clearance();
//}
//assembly(neg = true);
//}
//translate([0,0,36])
//driveshaft();

//        biggearvol(neg = neg);
//     drive_gear_disp()
//       littlegearvol(neg = neg);
//translate([0,0,140]) //rotate(180,[0,1,0]) pillow(screws=falses);
//pillow();