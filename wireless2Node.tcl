
set x_dim 100
set y_dim 100


set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       50                       ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(rp)           DSDV                     ;# ad-hoc routing protocol 
set val(nn)           2                        ;# number of mobilenodes

set ns_    [new Simulator]

set tracefd     [open wireless2Node.tr w]
$ns_ trace-all $tracefd 

set topo	[new Topography]
$topo load_flatgrid $x_dim $y_dim

create-god $val(nn)

set namtrace [open wireless2Node.nam w]
$ns_ namtrace-all-wireless $namtrace $x_dim $y_dim


# Configure nodes
        $ns_ node-config -adhocRouting $val(rp) \
                         -llType $val(ll) \
                         -macType $val(mac) \
                         -ifqType $val(ifq) \
                         -ifqLen $val(ifqlen) \
                         -antType $val(ant) \
                         -propType $val(prop) \
                         -phyType $val(netif) \
                         -topoInstance $topo \
                         -channelType $val(chan) \
                         -agentTrace ON \
                         -routerTrace ON \
                         -macTrace OFF \
                         -movementTrace OFF



  for {set i 0} {$i < $val(nn) } {incr i} {
                set node_($i) [$ns_ node ]
                $node_($i) random-motion 0       ;# disable random motion
  } 


#
# Provide initial (X,Y, for now Z=0) co-ordinates for node_(0) and node_(1)
#
$node_(0) set X_ 5.0
$node_(0) set Y_ 2.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 6.0
$node_(1) set Y_ 8.0
$node_(1) set Z_ 0.0


#
# Node_(1) starts to move towards node_(0)
#
$ns_ at 50.0 "$node_(1) setdest 25.0 20.0 15.0"
$ns_ at 10.0 "$node_(0) setdest 20.0 18.0 1.0"

# Node_(1) then starts to move away from node_(0)
#$ns_ at 100.0 "$node_(1) setdest 490.0 480.0 15.0" 

set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(1) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns_ at 10.0 "$ftp start"

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 150.0 "$node_($i) reset";
}
$ns_ at 150.0001 "stop"
$ns_ at 150.0002 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    close $tracefd
    exec nam wireless2Node.nam &
}

for {set i 0} {$i < 2  } { incr i} {
	$ns_ initial_node_pos $node_($i) 4
}

puts "Starting Simulation..."
$ns_ run




for {set i 0} {$i < [expr $num_col*$num_row] } {set i [expr $i+1]} {

	set timer [expr 0.0+$i]
	set xdest [expr 500 -$i]
	set ydest [expr 250 -$i]
	$ns_ at $timer "$node_($i) setdest $xdest $ydest 15.0"


}



set udp_($i) [new Agent/TCP]
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
	set end_timer 150
	
	$ns_ at $timer "$cbr_($i) start"
	$ns_ at $end_timer "$cbr_($i) stop"



for {set i [expr ($num_parallel_flow/4)+1] } {$i<($num_parallel_flow/2)+2} {set i [expr $i+2]} {
	

	set tcp_($i) [new Agent/TCP]
	$ns attach-agent $node_($i) $tcp_($i)

	set ftp_($i) [new Application/FTP]
	$ftp_($i) attach-agent $tcp_($i)
	
	set ant_i [expr $i+1]
	set sink_($ant_i) [new Agent/TCPSink] 
	$ns attach-agent $node_($ant_i) $sink_($ant_i)
	
	$ns connect $tcp_($i) $sink_($ant_i)
	
	
	
	if { $i<25} {
		$tcp_($i) set fid_ 5
	}
	
	if {$i>25 && $i<35} {
		$tcp_($i) set fid_ 6
	}
	
	if { $i>35 && $i<40} {
		
		$tcp_($i) set fid_ 7
	}
	
	if { $i>40} {
		$tcp_($i) set fid_ 8
	}
	
	set timer [expr ($num_parallel_flow/4)+$i]
	set end_timer 28.0
	
	$ns at $timer "$ftp_($i) start"
	$ns at $end_timer "$ftp_($i) stop"

}

