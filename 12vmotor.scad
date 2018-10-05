module dshaft(d = 6, dee = 0.7, h = 5.8){
    difference() {
    cylinder(r=d/2, h=h, center=true);
        translate([d + d/2 - dee,0,0])
        cube([d*2,d*2,h*2], center=true);
    }
}

module gmshaft_disp() {
    translate([8,0,0]) children();
}
module 12vmotor(neg = false) {
    
cylinder(r=38.5/2,h=25);
cylinder(r=34.5/2,h=53);
cylinder(r=11/2,h=56.5);
translate([10,0,55])    
    cube ([1,3,10], center=true);
translate([-10,0,55])    
    cube ([1,3,10], center=true);
if (neg) {
    cylinder(r=34.5/2,h=65);
    //translate([0,0,1])
    //rotate(180,[0,1,0])
            //cylinder(r=32/2,h=12);
    
gmshaft_disp()
        rotate(180,[0,1,0])
            cylinder(r=11,h=18);

    //translate([0,0,-3])
    //rotate(180,[0,1,0])
            //cylinder(r=45/2,h=24);

}
gmshaft_disp()
rotate(180,[0,1,0])
union() {
    cylinder(r=12/2,h=6);
    //cylinder(r=6/2,h=15);
translate([0,0,15/2])
        dshaft(h=15);
}
}

//12vmotor(neg = false);
//%12vmotor(neg = true);