load incrementer.mag
flatten incrementer_flat
load incrementer_flat
select top cell
extract do local
extract all
ext2sim labels on
ext2sim
#extresist tolerance 1
#extresist
ext2spice lvs
#ext2spice extresist on
ext2spice cthresh 0.5
#ext2spice rthresh 1
ext2spice
quit -noprompt
