#!/bin/sh
row=5
max=20
thrput=0.0
Avg_Delay=0.0
pktDlRat=0.0
pktDrRat=0.0


touch wired.out
truncate -s 0 wired.out

for col in 4 8 12 16 20
do
	

   nodes=$(( row * col ))
   for flow in 10 20 30 40 50
   do
   	    
   		PktPerSec=$(( var*10 ))
   		ns wired.tcl $row $col $flow $PktPerSec
   		parameter=$(awk -f wired.awk wired.tr)
   		
		t=$(echo $parameter | awk '{print $1}')
		avgdel=$(echo $parameter | awk '{print $2}')
		pktdelrat=$(echo $parameter | awk '{print $3}')
		pktdrrat=$(echo $parameter | awk '{print $4}')
		
		
		
   		thrput=`echo $t + $thrput | bc`
   		Avg_Delay=`echo $avgdel + $Avg_Delay | bc`
   		pktDlRat=`echo $pktdelrat + $pktDlRat | bc`
   		pktDrRat=`echo $pktdrrat + $pktDrRat | bc` 
   		
   		i_loop=$(( i_loop+1 ))
   done
   
   
   thrput=`echo $thrput/5.0 | bc -l`
   Avg_Delay=`echo $Avg_Delay/5.0 | bc -l`
   pktDlRat=`echo $pktDlRat/5.0 | bc -l`
   pktDrRat=`echo $pktDrRat/5.0 | bc -l`
   
   
   echo $nodes $thrput $Avg_Delay $pktDlRat $pktDrRat >> wired.out


done


gnuplot << EOF
set terminal postscript eps color enhanced
set output "wired.pdf"
set xlabel "Number Of Nodes"
set ylabel "Throughput"
set title "NS2"
set xrange [ 0 : 100 ]
set yrange [ 0 : 0.5 ]

plot "wired.out" using 1:2 notitle w l

set ylabel "E2E Delay"
set xrange [ 0 : 100 ]
set yrange [ 0 : 50 ]
plot "wired.out" using 1:3 notitle w l

set ylabel "Pkt Delivery Ratio"
set xrange [ 0 : 100 ]
set yrange [ 0 : 10 ]
plot "wired.out" using 1:4 notitle w l

set ylabel "Pkt Drop Ratio"
set xrange [ 0 : 100 ]
set yrange [ 0 : 50 ]
plot "wired.out" using 1:5 notitle w l
EOF




