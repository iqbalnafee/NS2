
puts "\n\n\n\n"


set cbr_size 1000
set cbr_rate 11.0Mb
set cbr_interval 1

set x_dim 2000
set y_dim 1000


set tcp_src Agent/TCP
set tcp_sink Agent/TCPSink

set num_row [lindex $argv 0] ;#number of row
set num_col [lindex $argv 1] ;#number of column



set num_parallel_flow [lindex $argv 2] 
set num_cross_flow 20
set num_random_flow 0

set val(energymodel_11)    EnergyModel     ;
set val(initialenergy_11)  1000            ;# Initial energy in Joules
set val(idlepower_11) 900e-3			;#Stargate (802.11b) 
set val(rxpower_11) 925e-3			;#Stargate (802.11b)
set val(txpower_11) 1425e-3			;#Stargate (802.11b)
set val(sleeppower_11) 300e-3			;#Stargate (802.11b)
set val(transitionpower_11) 200e-3		;#Stargate (802.11b)	??????????????????????????????/
set val(transitiontime_11) 3

set val(chan)           Channel/Sat
set val(bw_down)	1.5Mb; # Downlink bandwidth (satellite to ground)
set val(bw_up)		1.5Mb; # Uplink bandwidth
set val(bw_isl)		25Mb
set val(phy)            Phy/Sat
set val(mac)            Mac/Sat
set val(ifq)            Queue/DropTail
set val(qlim)		50
set val(ll)             LL/Sat
set val(wiredRouting)	ON




#creating ns simulator

set ns [new Simulator]

#nam file open and trace on

set nf [open wired.nam w]
set traceFile1 [open wired2.tr w]

$ns namtrace-all $nf
$ns trace-all $traceFile1


# Set up the node configuration

$ns node-config -satNodeType polar \
		-llType $val(ll) \
		-ifqType $val(ifq) \
		-ifqLen $val(qlim) \
		-macType $val(mac) \
		-phyType $val(phy) \
		-channelType $val(chan) \
		-downlinkBW $val(bw_down) \
		-wiredRouting $val(wiredRouting)
		


#Create nodes n0 to num_row*num_column

for {set i 0 } {$i<[expr $num_row*$num_col]} {set i [expr $i+1]} {
	set node_($i) [$ns node]
	#$node_($i) random-motion 0
}

for {set i 1 } {$i<[expr $num_row*$num_col]} {set i [expr $i+1]} {

			$ns duplex-link $node_(0) $node_($i) 1Mb 10ms DropTail;
		
	
}




set end_timer [expr $num_parallel_flow*2]

for {set i 0 } {$i<[expr ($num_parallel_flow/4)]} {set i [expr $i+2]} {
	
	set udp_($i) [new Agent/UDP]
	$ns attach-agent $node_($i) $udp_($i)

	set cbr_($i) [new Application/Traffic/CBR]
	
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
	
	set ant_i [expr $i+1]
	set null_($ant_i) [new Agent/Null] 
	$ns attach-agent $node_($ant_i) $null_($ant_i)
	
	$ns connect $udp_($i) $null_($ant_i)
	
	
	
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
	set end_timer [expr 0.0+$i+$i]
	
	$ns at $timer "$cbr_($i) start"
	$ns at $end_timer "$cbr_($i) stop"

}


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
	set end_timer [expr $timer+$i]
	
	$ns at $timer "$ftp_($i) start"
	$ns at $end_timer "$ftp_($i) stop"

}

$ns color 1 Blue
$ns color 2 Green
$ns color 3 Red
$ns color 4 Pink

$ns color 5 Yellow
$ns color 6 Brown
$ns color 7 Grey
$ns color 8 Purple







proc finish {} \
{
	global ns nf
	$ns flush-trace
	#close $traceFile1
	
	#exec nam wired.nam 
	#exec awk -f wired.awk wired2.tr &
	exit 0
}


$ns at 28.0001 "finish"
puts "Starting Simulation..."
$ns at 28.0002 "puts \"NS EXITING...\" "
$ns run

