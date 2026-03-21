all: incrementer.mag

incrementer.mag: incrementer.tcl
	magic -rcfile $(PDK_ROOT)/sky130A/libs.tech/magic/sky130A.magicrc -noconsole -dnull incrementer.tcl

magic: incrementer.mag
	magic -rcfile $(PDK_ROOT)/sky130A/libs.tech/magic/sky130A.magicrc incrementer.mag
