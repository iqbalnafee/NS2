
puts "\n\n\n"

set cbr_size 1000
set cbr_rate 11.0Mb
set cbr_interval 1

set x_dim 100
set y_dim 100


set num_row [lindex $argv 0];#number of row
set num_col [lindex $argv 1] ;#number of column

set num_parallel_flow 20
set num_cross_flow 20
set num_random_flow [lindex $argv 2]

set tcp_src Agent/TCP ;
set tcp_sink Agent/TCPSink


set val(energymodel_11)    EnergyModel     ;
set val(initialenergy_11)  1000            ;# Initial energy in Joules
set val(idlepower_11) 900e-3			;#Stargate (802.11b) 
set val(rxpower_11) 925e-3			;#Stargate (802.11b)
set val(txpower_11) 1425e-3			;#Stargate (802.11b)
set val(sleeppower_11) 300e-3			;#Stargate (802.11b)
set val(transitionpower_11) 200e-3		;#Stargate (802.11b)	??????????????????????????????/
set val(transitiontime_11) 3

set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       50                       ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(rp)           DSDV                     ;# ad-hoc routing protocol 
set val(nn)           [expr $num_row*$num_col]                        ;# number of mobilenodes

set ns_    [new Simulator]


set topo	[new Topography]
$topo load_flatgrid 500 500

set tracefd     [open wireless.tr w]
$ns_ trace-all $tracefd 

set namtrace [open wireless.nam w]
$ns_ namtrace-all-wireless $namtrace $x_dim $y_dim

#Energy

$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) \
     -macType $val(mac)  -ifqType $val(ifq) \
     -ifqLen $val(ifqlen) -antType $val(ant) \
     -propType $val(prop) -phyType $val(netif) \
     -channel  [new $val(chan)] -topoInstance $topo \
     -agentTrace ON -routerTrace OFF\
     -macTrace ON \
     -movementTrace OFF \
     -energyModel $val(energymodel_11) \
     -idlePower $val(idlepower_11) \
     -rxPower $val(rxpower_11) \
     -txPower $val(txpower_11) \
     -sleepPower $val(sleeppower_11) \
     -transitionPower $val(transitionpower_11) \
     -transitionTime $val(transitiontime_11) \
     -initialEnergy $val(initialenergy_11)


#          		 -transitionTime 0.005 \






create-god $val(nn)



for {set i 0} {$i < $val(nn) } {incr i} {
    set node_($i) [$ns_ node ]
    $node_($i) random-motion 0       ;# disable random motion
}

set x_start 0
set y_start 0

set node_num 0

#Node Creation

for {set i 0} {$i < [expr $num_row*$num_row] } {set i [expr $i+5]} {
  
	for {set j 0} {$j < $num_col } {incr j} {
	

		set x_pos [expr $j*10]
  	    set y_pos [expr $i]

   		$node_($node_num) set X_ $x_pos;
  	    $node_($node_num) set Y_ $y_pos;
  	    
  	    set node_num [expr $node_num+1]
	}

}

for {set i 0} {$i < [expr $num_random_flow]} {incr i} {

	set tcp_($i) [new $tcp_src]
	$tcp_($i) set class_ $i
	set sink_($i) [new $tcp_sink]
	$tcp_($i) set fid_ $i
	if { [expr $i%2] == 0} {
		$ns_ color $i Blue
	} else {
		$ns_ color $i Red
	}
}


#Random FLOW

for {set i 0} {$i<[expr int([expr $num_random_flow/4])]} {set i [expr $i+2]} {
	
	set udp_($i) [new Agent/UDP]
	$ns_ attach-agent $node_($i) $udp_($i)

	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) attach-agent $udp_($i)
	
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	
	set ant_i [expr $i+1]
	set null_($ant_i) [new Agent/Null]  
	$ns_ attach-agent $node_($ant_i) $null_($ant_i)
	
	$ns_ connect $udp_($i) $null_($ant_i)
	
	if { $i<5} {
		$udp_($i) set class_ 1
	}
	
	if {$i>5 && $i<15} {
		$udp_($i) set class_ 2
	}
	
	if { $i>15 && $i<25} {
		
		$udp_($i) set class_ 3
	}
	
	if { $i>25} {
		$udp_($i) set class_ 4
	}
	
	set timer [expr 0.0+$i]
	set end_timer 50
	
	$ns_ at $timer "$cbr_($i) start"
	$ns_ at $end_timer "$cbr_($i) stop"

} 

# mobility

for {set i 0} {$i < [expr $num_col*$num_row] } {set i [expr $i+1]} {

	set timer [expr 0.0+$i]
	set xdest [expr 100-$i ]
	set ydest [expr 100-$i ]
	$ns_ at $timer "$node_($i) setdest $xdest $ydest 15.0"


}

$ns_ color 1 Blue
$ns_ color 2 Green
$ns_ color 3 Red
$ns_ color 4 Pink

$ns_ color 5 Yellow
$ns_ color 6 Brown
$ns_ color 7 Grey
$ns_ color 8 Purple




for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 50.0 "$node_($i) reset";
}





$ns_ at 50.01 "stop"
#$ns_ at 150.0002 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    close $tracefd
    #exec nam wireless.nam &
	exit 0
}
for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns_ initial_node_pos $node_($i) 4
}


puts "Starting Simulation..."
$ns_ run





