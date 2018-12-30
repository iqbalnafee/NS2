
puts "\n\n\n"

set x_dim 100
set y_dim 100


set num_row 5;#number of row
set num_col 5 ;#number of column

set num_parallel_flow 20
set num_cross_flow 20
set num_random_flow 0

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

for {set i 0} {$i < [expr $num_parallel_flow + $num_cross_flow + $num_random_flow]} {incr i} {

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


#PARALLEL FLOW

for {set i 0} {$i < [expr $num_parallel_flow/2] } {set i [expr $i+2]} {
	
	set tcp_($i) [new Agent/TCP]
	$ns_ attach-agent $node_($i) $tcp_($i)

	set ftp_($i) [new Application/FTP]
	$ftp_($i) attach-agent $tcp_($i)
	
	set ant_i [expr $i+1]
	set sink_($ant_i) [new Agent/TCPSink] 
	$ns_ attach-agent $node_($ant_i) $sink_($ant_i)
	
	$ns_ connect $tcp_($i) $sink_($ant_i)
	
	set timer [expr 0.0+$i]
	$ns_ at $timer "$ftp_($i) start"
	$ns_ at 50.0 "$ftp_($i) stop"
} 




for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 50.0 "$node_($i) reset";
}





$ns_ at 50.01 "stop"
#$ns_ at 1.0002 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    close $tracefd
    exec nam wireless.nam &
}
for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns_ initial_node_pos $node_($i) 4
}


puts "Starting Simulation..."
$ns_ run





