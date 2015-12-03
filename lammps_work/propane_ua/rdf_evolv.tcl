proc rdf_step {type outfile start end} {
    if {$type == "towhee"} {
        set oxygen [atomselect top "name O"]
        set o_hydrogen [atomselect top "name HO"]
        set avg_num 50
    } elseif {$type == "lammps"} {
        set oxygen [atomselect top "name O"]
        set o_hydrogen [atomselect top "name H"]
        set avg_num 700
    }

    set outfile [open $outfile w]
    for {set x $start} {$x <= $end} {incr x} {
        puts $outfile [measure gofr $oxygen $o_hydrogen delta 0.1 usepbc true first $x last $x step 5]
    }
    # The average of last 50 frames
    puts $outfile [measure gofr $oxygen $o_hydrogen delta 0.1 usepbc true first [expr $end - $avg_num] last $end step 5]
    close $outfile
}

proc rdf_mean {type outfile start end} {
    if {$type == "towhee"} {
        set oxygen [atomselect top "name O"]
        set o_hydrogen [atomselect top "name HO"]
    } elseif {$type == "lammps"} {
        set oxygen [atomselect top "name O"]
        set o_hydrogen [atomselect top "name H"]
    }

    set outfile [open $outfile w]
    for {set x $start} {$x <= $end} {incr x} {
        puts $outfile [measure gofr $oxygen $o_hydrogen delta 0.1 usepbc true first $start last $x step 5]
    }
    close $outfile
}
