all: incrementer.mag

incrementer.mag: incrementer.tcl
	magic -rcfile $(PDK_ROOT)/sky130A/libs.tech/magic/sky130A.magicrc -noconsole -dnull incrementer.tcl

magic: incrementer.mag
	magic -rcfile $(PDK_ROOT)/sky130A/libs.tech/magic/sky130A.magicrc incrementer.mag

spice: incrementer.mag ext2spice.tcl
	magic -rcfile $(PDK_ROOT)/sky130A/libs.tech/magic/sky130A.magicrc -noconsole -dnull ext2spice.tcl
