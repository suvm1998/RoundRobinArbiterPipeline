#!/usr/bin/tclsh

if {$argc!= 3} {
	puts "ERROR: Please provide a Verilog File, cell Library, top module name"
	exit
}

set ext [llength [split [lindex $argv 0] .]]

set xtn [lindex [split [lindex $argv 0] .] $ext-1]


if {![regexp {^v} $xtn]} {
	puts "ERROR: Provide a valid verilog file"
	exit
}
set gg [lindex [split [lindex $argv 0] .] $ext-2]
set ext [llength [split [lindex $argv 1] .]]
set xtn [lindex [split [lindex $argv 1] .] $ext-1]
if {![regexp {^lib} $xtn]} {
	puts "ERROR: Provide a valid liberty file"
	exit
}
set design [lindex $argv 0]
set libFile [lindex $argv 1]
set synthScript [open yosys_script.ys w]
set synthrtl "output.v"
set topmodule [lindex $argv 2]
puts $synthScript "read_verilog $design;\nhierarchy -check -top $topmodule;\nproc; opt;\nfsm; opt;\nmemory; opt;\ntechmap; opt;\ndfflibmap -liberty $libFile;\nabc -liberty $libFile;\nclean;\nwrite_verilog $synthrtl"

close $synthScript
set err [catch {exec yosys yosys_script.ys} msg]
if {$err} {
	puts $msg
}

if {[file exists design.v]} {
	file delete design.v
}
set fId [open design.v w]
set tt "$gg _synthesized.v"
set xy "$gg _synthesized_optimized.v"
regsub " " $tt "" tt
regsub " " $xy "" xy
 
puts -nonewline $fId [exec grep -v  "*" $synthrtl] 
#grep grep is a powerful command-line tool that is used to search one or more input files for lines that match a regular expression and writes each matching line to standard output. -v tells that there must not be a match. -w
close $fId
#here we have a clean synthesized verilog file

set tmp [open design.v r]

set tmp2 [open $tt w]
while {![eof $tmp]} {
	set line [gets $tmp]
	set line [string trimleft $line " "]
	if {![regexp ";" $line]} {
	puts -nonewline $tmp2 $line
	} else {
	puts $tmp2 $line
	}
}
close $tmp
close $tmp2
file delete design.v

set liberty [open cells.lib r]
while {![eof $liberty]} {
	set line [gets $liberty]
	if {[regexp "NOT" $line]} {
	set var "NOT"
	}
	if {[regexp "BUF" $line]} {
	set var "BUF"
	}
	if {[regexp "NOR" $line]} {
	set var "NOR"
	}
	if {[regexp "NAND" $line]} {
	set var "NAND"
	}
	if {[regexp "DFF" $line]} {
	set var "DFF"
	}
	if {[regexp "area:" $line]} {
		regsub "\S" $line "" line
		set line [lindex [split $line ":"] 1]
		set line [lindex [split $line ";"] 0]
		set line [lindex [split $line " "] 1]
		set $var $line
	}

}
close $liberty
set netlist [open $tt r]

if {[file exists edges.txt]} {
	file delete edges.txt
}
set vals [open edges.txt w]
if {[file exists launchCapture.txt]} {
	file delete launchCapture.txt
}
set area 0
set lc [open launchCapture.txt w]
while {![eof $netlist]} {
	set line [gets $netlist]
	set line1 [split $line " "]
	set len [llength $line1]
	if {[regexp (input|output) $line]} {
		set comp [lindex [split [lindex $line1 $len-1] ";"] 0]
		set type [lindex $line1 0]
		if {$len>2} {
		set idx [string trimleft [lindex [split [lindex $line1 $len-2] ":"] 0] "\["]
		incr idx
		for {set i 0} {$i<$idx} {incr i} {
			puts $lc "$type $comp\[$i\]"
		}
		} elseif {![regexp (clk|rst) $comp]} {
		puts $lc "$type $comp"
		}
	
	}
	if {[regexp (NOT|NAND|NOR) $line]} {
		set type [lindex $line1 0]
		if {[regexp "NOT" $type]} {
			set area [expr {$area+$NOT}]
		}
		if {[regexp "NOR" $type]} {
			set area [expr {$area+$NOR}]
		}
		if {[regexp "NAND" $type]} {
			set area [expr {$area+$NAND}]
		}
		if {[regexp "BUF" $type]} {
			set area [expr {$area+$BUF}]
		}
		puts -nonewline $vals "\n[lindex $line1 0] [lindex $line1 1] "
		set comp [string trimright [lindex $line1 2] "\)\);"]
		set comp [string trimleft $comp "\(."]
		regsub -all "\\),." $comp " " comp
		set comp [split $comp " "]
		foreach ele $comp {
			set t [lindex [split $ele "\("] 1]
			puts -nonewline $vals " $t"
		}
	
	}
	if {[regexp (DFF) $line]} {
		set area [expr {$area+$DFF}]
		puts -nonewline $lc "\n[lindex $line1 0] [lindex $line1 1] "
		set comp [string trimright [lindex $line1 2] "\)\);"]
		set comp [string trimleft $comp "\(."]
		regsub -all "\\),." $comp " " comp
		set comp [split $comp " "]
		foreach ele $comp {
			set t [lindex [split $ele "\("] 1]
			if {![regexp {^clk} $t]} {
			puts -nonewline $lc " $t"}
		}
	
	}
	
}
close $lc
close $vals
close $netlist
puts "Area overhead is $area units"
set lc [open launchCapture.txt r]
set lc2 [open lc2.txt w]
set vals [open edges.txt r]
set vals2 [open edges2.txt w]

while {![eof $lc]} {
	set line [gets $lc]
	set size [llength $line]
	if {$size==0} {
		continue
	}
	puts $lc2 $line
}
while {![eof $vals]} {
	set line [gets $vals]
	set size [llength $line]
	if {$size==0} {
		continue
	}
	puts $vals2 $line
}
close $vals
close $vals2
close $lc
close $lc2
file delete edges.txt
file delete launchCapture.txt
file rename lc2.txt launchCapture.txt
file rename edges2.txt edges.txt
set err [catch {exec g++ text.cpp -o main} msg]
	#puts $msg
set err [catch {exec ./main} msg]
	#puts $msg;
set liberty [open output.txt r]
set oldfreq 0
while {![eof $liberty]} {
	set line [gets $liberty]
	if {[llength $line]} {
		set oldfreq $line
		puts "Max operating frequency is $line GHz"
	}
}
close $liberty
set netlist [open $tt r]
set opt [open optmize_nodes.txt r]
set sc [open 1.txt w]
set points 0
set numm 0;
set lst {}
while {![eof $opt]} {
	set find [gets $opt]
	set tttt [lindex [split $find " "] 0]
	if {[llength $tttt]} {
		lappend lst $find
		puts $sc "input _$numm\_$numm\_;"
	set netlist [open $tt r]
	while {![eof $netlist]} {
		set in [gets $netlist]
		set copyin $in
		
	   	if {[regexp $find $in]} {
	   	regsub {\.[Y]\([\w\[\]\_]+\)} $in ".Y(_$numm\_$numm\_)" in
	   	puts $sc $in
	   	
	   	regsub {(NAND|NOR)\s+\_[\d]+\_\s+\(\.[A,B]\([\w\_\[\]]+\),\.[A,B]\([\w\_\[\]]+\)} $copyin "DFF _$numm\_$numm\_$numm\_ (.C(clk),.D(_$numm\_$numm\_)" copyin
	   	regsub {(NOT)\s+\_[\d]+\_\s+\(\.[A,B]\([\w\_\[\]]+\)} $copyin "DFF _$numm\_$numm\_$numm\_ (.C(clk),.D(_$numm\_$numm\_)" copyin
	   	puts $sc $copyin
	   	
	   	
	   	incr points
	   }
	}
	set numm [expr {$numm+1}]
	close $netlist}
}	
close $opt
close $sc
set netlist [open $tt r]
set newnetlist [open optDesign.v w]
set sc [open 1.txt r]
while {![eof $netlist]} {
	set line [gets $netlist]
	set checker [lindex [split $line " "] 1]
	if {[lsearch $lst $checker]>=0} {
		continue
	}
	if {[regexp "endmodule" $line]} {
	while {![eof $sc]} {
		set ss [gets $sc] 
		puts $newnetlist $ss
	}
	}
	puts $newnetlist $line
}
close $netlist
close $newnetlist
set netlist [open optDesign.v r]
set new_area [expr {$area + ($DFF*$points)}]
set up_area [expr {($new_area-$area)*100/$area}]
puts "\nArea post pipelining is $new_area units (+$up_area %)"

if {[file exists edges.txt]} {
	file delete edges.txt
}
set vals [open edges.txt w]
if {[file exists launchCapture.txt]} {
	file delete launchCapture.txt
}
set area 0
set lc [open launchCapture.txt w]
while {![eof $netlist]} {
	set line [gets $netlist]
	set line1 [split $line " "]
	set len [llength $line1]
	if {[regexp (input|output) $line]} {
		set comp [lindex [split [lindex $line1 $len-1] ";"] 0]
		set type [lindex $line1 0]
		if {$len>2} {
		set idx [string trimleft [lindex [split [lindex $line1 $len-2] ":"] 0] "\["]
		incr idx
		for {set i 0} {$i<$idx} {incr i} {
			puts $lc "$type $comp\[$i\]"
		}
		} elseif {![regexp (clk|rst) $comp]} {
		puts $lc "$type $comp"
		}
	
	}
	if {[regexp (NOT|NAND|NOR) $line]} {
		set type [lindex $line1 0]
		if {[regexp "NOT" $type]} {
			set area [expr {$area+$NOT}]
		}
		if {[regexp "NOR" $type]} {
			set area [expr {$area+$NOR}]
		}
		if {[regexp "NAND" $type]} {
			set area [expr {$area+$NAND}]
		}
		if {[regexp "BUF" $type]} {
			set area [expr {$area+$BUF}]
		}
		puts -nonewline $vals "\n[lindex $line1 0] [lindex $line1 1] "
		set comp [string trimright [lindex $line1 2] "\)\);"]
		set comp [string trimleft $comp "\(."]
		regsub -all "\\),." $comp " " comp
		set comp [split $comp " "]
		foreach ele $comp {
			set t [lindex [split $ele "\("] 1]
			puts -nonewline $vals " $t"
		}
	
	}
	if {[regexp (DFF) $line]} {
		set area [expr {$area+$DFF}]
		puts -nonewline $lc "\n[lindex $line1 0] [lindex $line1 1] "
		set comp [string trimright [lindex $line1 2] "\)\);"]
		set comp [string trimleft $comp "\(."]
		regsub -all "\\),." $comp " " comp
		set comp [split $comp " "]
		foreach ele $comp {
			set t [lindex [split $ele "\("] 1]
			if {![regexp {^clk} $t]} {
			puts -nonewline $lc " $t"}
		}
	
	}
	
}
close $lc
close $vals
set lc [open launchCapture.txt r]
set lc2 [open lc2.txt w]
set vals [open edges.txt r]
set vals2 [open edges2.txt w]

while {![eof $lc]} {
	set line [gets $lc]
	set size [llength $line]
	if {$size==0} {
		continue
	}
	puts $lc2 $line
}
while {![eof $vals]} {
	set line [gets $vals]
	set size [llength $line]
	if {$size==0} {
		continue
	}
	puts $vals2 $line
}
close $vals
close $vals2
close $lc
close $lc2
file delete edges.txt
file delete launchCapture.txt
file rename lc2.txt launchCapture.txt
file rename edges2.txt edges.txt
set err [catch {exec g++ text.cpp -o main} msg]
	#puts $msg;
set err [catch {exec ./main} msg]
	#puts $msg;
set liberty [open output.txt r]
set newfreq 0
while {![eof $liberty]} {
	set line [gets $liberty]
	if {[llength $line]} {
		set newfreq $line
		set optfreq [expr {($newfreq-$oldfreq)*100/$oldfreq}]
		puts "Pipelined operating frequency is $line GHz(+$optfreq %)"
	}
}

file delete output.v
file delete yosys_script.ys
file delete output.txt
file delete edges.txt
file delete launchCapture.txt
file delete main
file delete optmize_nodes.txt
file delete 1.txt
if {[file exists $xy]} {
	file delete $xy
}
file rename optDesign.v $xy
puts "\n\nThe synthesized netlist is saved as $tt"
puts "Optimized netlist saved as $xy"
puts "=======EXIT======="








