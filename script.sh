#!/bin/sh
row=5
max=20

touch force.out
truncate -s 0 force.out
for col in 4 8 12 16 20
do
   mul=$(( row * col ))
   ns wired2.tcl $row $col $mul
   parameter=$(awk -f wired.awk wired2.tr)
   echo $mul $parameter >> force.out

done



gnuplot << EOF
set terminal postscript eps color enhanced
set output "$1.pdf"
set xlabel "Number Of Flow"
set ylabel "Network Throughput"
set title "NS2"
set xrange [ 0 : 100 ]
set yrange [ 0 : 0.5 ]
set mxtics 5
set mytics 5
set xtics 5
set ytics 0.5
plot "$1.out" using 1:2 notitle w l
EOF
