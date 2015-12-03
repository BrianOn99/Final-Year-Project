proc rdf_step {type outfile start end} {
    if {$type == "towhee"} {
        set oxygen [atomselect top "name O"]
        set o_hydrogen [atomselect top "name HO"]
    } elseif {$type == "lammps"} {
        set oxygen [atomselect top "name O"]
        set o_hydrogen [atomselect top "name H"]
    }
    set avg_num 150

    set outfile [open $outfile w]
    for {set x $start} {$x <= $end} {incr x} {
        puts $outfile [measure gofr $oxygen $o_hydrogen delta 0.1 usepbc true first $x last $x step 1]
    }
    # The average of last $avg_num frames
    puts $outfile [measure gofr $oxygen $o_hydrogen delta 0.1 usepbc true first [expr $end - $avg_num] last $end step 1]
    close $outfile
}

proc rdf_mean {type outfile start end ref} {
    if {$type == "towhee"} {
        set oxygen [atomselect top "name O"]
        set o_hydrogen [atomselect top "name HO"]
    } elseif {$type == "lammps"} {
        set oxygen [atomselect top "name O"]
        set o_hydrogen [atomselect top "name H"]
    }
    set avg_num 250

    set outfile [open $outfile w]
    for {set x $start} {$x <= $end} {incr x} {
        puts $outfile [measure gofr $oxygen $o_hydrogen delta 0.1 usepbc true first $start last $x step 1]
    }
    puts $outfile [measure gofr $oxygen $o_hydrogen delta 0.1 usepbc true first [expr $ref - $avg_num] last $ref step 1]
    close $outfile
}
