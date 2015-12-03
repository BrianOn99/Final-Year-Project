#!/usr/bin/perl

# Set the number of atoms in the box
$n_atoms = 25;

# Set the number of Monte Carlo moves to perform
$num_moves = 5000;

# Set the size of the box (in Angstroms)
@box_size = ( 10.0, 10.0, 10.0 );

# The maximum amount that the atom can be translated by
$max_translate = 0.5;  # angstroms

# The maximum amount to change the volume - the 
# best value is 10% of the number of atoms
$max_volume_change = 0.1 * $n_atoms;   # Angstroms**3

# Simulation temperature
$temperature = 298.15;   # kelvin

# Simulation pressure
$pressure = 1;   # atmospheres

# Convert pressure to internal units (kcal mol-1 A-3)
$pressure = $pressure * 1.458397506863647E-005;

# Give the Lennard Jones parameters for the atoms
# (these are the OPLS parameters for Krypton)
$sigma = 3.624;     # angstroms
$epsilon = 0.317;   # kcal mol-1

# Randomly generate the coordinates of the atoms in the box
for ($i = 0; $i < $n_atoms; $i = $i + 1)
{
    # Note "rand($x)" would generate a random number
    # between 0 and $x

    $coords[$i][0] = rand($box_size[0]);
    $coords[$i][1] = rand($box_size[1]);
    $coords[$i][2] = rand($box_size[2]);
}

# Subroutine to apply periodic boundaries
sub make_periodic
{
    my ($x, $box) = @_;

    while ($x < -0.5*$box)
    {
        $x = $x + $box;
    }

    while ($x > 0.5*$box)
    {
        $x = $x - $box;
    }

    return $x;
}

# Subroutine to wrap the coordinates into a box
sub wrap_into_box
{
    my ($x, $box) = @_;

    while ($x > $box)
    {
        $x = $x - $box;
    }

    while ($x < 0)
    {
        $x = $x + $box;
    }

    return $x;
}

sub wrap_all_atoms
{
     for ($i=0; $i<$n_atoms; $i = $i + 1)
     {
        # wrap the coordinates back into the box
        $coords[$i][0] = wrap_into_box($coords[$i][0], $box_size[0]);
        $coords[$i][1] = wrap_into_box($coords[$i][1], $box_size[1]);
        $coords[$i][2] = wrap_into_box($coords[$i][2], $box_size[2]);
     }
}

# Subroutine to print a PDB of the coordinates
sub print_pdb
{
    my ($move) = @_;

    $filename = sprintf("output%000006d.pdb", $move);

    open FILE,">$filename" or die "Cannot open $filename for writing! $!\n";

    printf FILE ("CRYST1 %8.3f %8.3f %8.3f  90.00  90.00  90.00\n", 
                  $box_size[0], $box_size[1], $box_size[2]);

    for ($i = 0; $i < $n_atoms; $i = $i + 1)
    {
        printf FILE ("ATOM  %5d  Kr   Kr     1    %8.3f%8.3f%8.3f  1.00  0.00          Kr\n",
                       $i+1, $coords[$i][0], $coords[$i][1], $coords[$i][2]); 
        print FILE "TER\n";
    }

    close FILE;
}

# Subroutine that calculates the energies of the atoms
sub calculate_energy
{
    # Loop over all pairs of atoms and calculate
    # the LJ energy
    $total_energy = 0;

    for ($i = 0; $i < $n_atoms-1; $i = $i + 1)
    {
        for ($j = $i+1; $j < $n_atoms; $j = $j + 1)
        {
            $delta_x = $coords[$j][0] - $coords[$i][0];
            $delta_y = $coords[$j][1] - $coords[$i][1];
            $delta_z = $coords[$j][2] - $coords[$i][2];

            # Apply periodic boundaries
            $delta_x = make_periodic($delta_x, $box_size[0]);
            $delta_y = make_periodic($delta_y, $box_size[1]);
            $delta_z = make_periodic($delta_z, $box_size[2]);

            $r = sqrt( ($delta_x*$delta_x) + ($delta_y*$delta_y) +
                       ($delta_z*$delta_z) );

            # E_LJ = 4*epsilon[ (sigma/r)^12 - (sigma/r)^6 ]
            $e_lj = 4.0 * $epsilon * ( ($sigma/$r)**12 - ($sigma/$r)**6 );

            $total_energy = $total_energy + $e_lj;
        }
    }

    # return the total energy of the atoms
    return $total_energy;
}

# calculate kT
$k_boltz = 1.987206504191549E-003;  # kcal mol-1 K-1

$kT = $k_boltz * $temperature;

# The total number of accepted moves
$naccept = 0;

# The total number of rejected moves
$nreject = 0;

# The total number of accepted volume moves
$nvolaccept = 0;

# The total number of rejected volume moves
$nvolreject = 0;

# Print the initial PDB file
print_pdb(0);

for ($move=1; $move<=$num_moves; $move = $move + 1)
{
    # calculate the old energy
    $old_energy = calculate_energy();

    # calculate the old volume of the box
    $V_old = $box_size[0] * $box_size[1] * $box_size[2];

    # Pick a random atom
    $atom = int( rand($n_atoms) );

    # save the old coordinates
    @old_coords = ( $coords[$atom][0], $coords[$atom][1],
                    $coords[$atom][2] );

    # save the old box dimensions
    @old_box_size = @box_size;

    # Decide if we are performing an atom move, or a volume move
    if (rand(1.0) <= 1.0 / $n_atoms)
    {
        $is_volume_move = 1;

        # 1 in $n_atoms chance of being here. Perform a volume move
        # by changing the volume for a random amount
        $delta_vol = rand($max_volume_change);

        # Volume is the cube of the box length, so add the cube root
        # of this change onto the box size
        $delta_vol = $delta_vol**(1.0/3.0);

        # Are we making the box bigger or smaller?
        if (rand(1.0) >= 0.5)
        {
            $box_size[0] = $box_size[0] + $delta_vol;
            $box_size[1] = $box_size[1] + $delta_vol;
            $box_size[2] = $box_size[2] + $delta_vol;
        }
        else
        {
            $box_size[0] = $box_size[0] - $delta_vol;
            $box_size[1] = $box_size[1] - $delta_vol;
            $box_size[2] = $box_size[2] - $delta_vol;
        }

        # wrap the atoms back into the box
        wrap_all_atoms();
    }
    else
    {
        $is_volume_move = 0;

        # Make the atom move - translate by a delta in each dimension
        $delta_x = $max_translate * ( 2.0 * rand(1.0) - 1.0 );
        $delta_y = $max_translate * ( 2.0 * rand(1.0) - 1.0 );
        $delta_z = $max_translate * ( 2.0 * rand(1.0) - 1.0 );

        $coords[$atom][0] = $coords[$atom][0] + $delta_x;
        $coords[$atom][1] = $coords[$atom][1] + $delta_y;
        $coords[$atom][2] = $coords[$atom][2] + $delta_z;

        # wrap the coordinates back into the box
        $coords[$atom][0] = wrap_into_box($coords[$atom][0], $box_size[0]);
        $coords[$atom][1] = wrap_into_box($coords[$atom][1], $box_size[1]);
        $coords[$atom][2] = wrap_into_box($coords[$atom][2], $box_size[2]);
    }

    # calculate the new energy
    $new_energy = calculate_energy();

    # calculate the new volume of the box
    $V_new = $box_size[0] * $box_size[1] * $box_size[2];

    $accept = 0;

    # Automatically accept if the energy goes down
    if ($new_energy <= $old_energy)
    {
        $accept = 1;
    }
    else
    {
        # Now apply the Monte Carlo test - compare
        # exp( -(E_new - E_old + P(V_new - V_old)) / kT 
        #             +  N ln (V_new - V_old) ) >= rand(0,1)
        $x = exp( -($new_energy - $old_energy + $pressure * ($V_new - $V_old)) / $kT
                      + $n_atoms * (log($V_new) - log($V_old) ) );

        if ($x >= rand(1.0))
        {
            $accept = 1;
        }
        else
        {
            $accept = 0
        }
    }

    if ($accept == 1)
    {
        # accept the move
        $naccept = $naccept + 1;

        if ($is_volume_move){ $nvolaccept = $nvolaccept + 1; }

        $total_energy = $new_energy;
    }
    else
    {
        # reject the move - restore the old coordinates and box size
        $nreject = $nreject + 1;

        if ($is_volume_move){ $nvolreject = $nvolreject + 1; }

        $coords[$atom][0] = $old_coords[0];
        $coords[$atom][1] = $old_coords[1];
        $coords[$atom][2] = $old_coords[2];

        @box_size = @old_box_size;

        if ($is_volume_move){ wrap_all_atoms(); }

        $total_energy = $old_energy;
    }

    # print the energy every 10 moves
    if ($move % 10 == 0)
    {
        print "$move: $total_energy  ($naccept : $nreject)  ".
              "($nvolaccept : $nvolreject)\n";

        $vol = $box_size[0] * $box_size[1] * $box_size[2];

        print "    Box size = @box_size. Volume = $vol A^3\n";
    }

    # print the coordinates every 100 moves
    if ($move % 100 == 0)
    {
        print_pdb($move);
    }
}


