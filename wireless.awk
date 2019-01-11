BEGIN {
	max_node = 2000;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;

	header = 20;	

	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nReceivedBytes = 0;
	rEnergyEfficeincy = 0;

	nDropPackets = 0.0;

	total_energy_consumption = 0;
	total_retransmit = 0;
	
	temp = 0;
	
	energy_consumption[max_node];
	retransmit[max_node];
	
	

	
	

}

{


	strEvent = $1 ;
	rTime = $2 ;			
	node = $3 ;
	strAgt = $4 ;			idPacket = $6 ;
	strType = $7 ;			nBytes = $8;

	energy = $13;			total_energy = $14;
	idle_energy_consumption = $16;	sleep_energy_consumption = $18; 
	transmit_energy_consumption = $20;	receive_energy_consumption = $22; 
	num_retransmit = $30;
	
	sub(/^_*/, "", node);
	sub(/_*$/, "", node);

	if (energy == "[energy") {
		energy_consumption[node] = (idle_energy_consumption + sleep_energy_consumption + transmit_energy_consumption + receive_energy_consumption);

	}


	if ( strAgt == "AGT"   &&   strType == "cbr") {
		if (idPacket > idHighestPacket) idHighestPacket = idPacket;
		if (idPacket < idLowestPacket) idLowestPacket = idPacket;

#		if(rTime>rEndTime) rEndTime=rTime;
#			printf("********************\n");
		if(rTime<rStartTime) {
#			printf("********************\n");
#			printf("%10.0f %10.0f %10.0f\n",rTime, node, idPacket);
			rStartTime=rTime;
		}

		if ( strEvent == "s" ) {
			nSentPackets += 1 ;	rSentTime[ idPacket ] = rTime ;
#			printf("%15.5f\n", nSentPackets);
		}
#		if ( strEvent == "r" ) {
		if ( strEvent == "r" && idPacket >= idLowestPacket) {
			nReceivedPackets += 1 ;		nReceivedBytes += (nBytes-header);
#			printf("%15.0f\n", $6); #nBytes);
			rReceivedTime[ idPacket ] = rTime ;
			rDelay[idPacket] = rReceivedTime[ idPacket] - rSentTime[ idPacket ];
#			rTotalDelay += rReceivedTime[ idPacket] - rSentTime[ idPacket ];
			rTotalDelay += rDelay[idPacket]; 

#			printf("%15.5f   %15.5f\n", rDelay[idPacket], rReceivedTime[ idPacket] - rSentTime[ idPacket ]);
		}
	}

	if( strEvent == "D"   &&   strType == "cbr" )
	{
		if(rTime>rEndTime) rEndTime=rTime;

		nDropPackets += 1;
	}

	if( strType == "tcp" )
	{

		retransmit[idPacket] = num_retransmit;		
	}

	if(rTime>rEndTime) rEndTime=rTime;

}

END {
	rTime = rEndTime - rStartTime ;
	rThroughput = nReceivedBytes*8 / rTime;
	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
	rPacketDropRatio = nDropPackets / nSentPackets * 100;


	for(i=0; i<max_node;i++) {
		total_energy_consumption += energy_consumption[i];
	}
	if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
		avg_energy_per_packet = total_energy_consumption / nReceivedPackets ;
	}

	if ( nReceivedBytes != 0 ) {
		avg_energy_per_byte = total_energy_consumption / nReceivedBytes ;
		avg_energy_per_bit = avg_energy_per_byte / 8;
		rEnergyEfficeincy = total_energy_consumption / (nReceivedBytes*8);
	}

	for (i=0; i<max_pckt; i++) {
		total_retransmit += retransmit[i] ;		
	}




	printf( "%g\n%g\n%g\n%g\n%g\n%g\n%g\n%g done\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,rTime) ;
	printf("%g\n%g\n%g\n%g\n%g\n%g\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet, total_retransmit, rEnergyEfficeincy);


}


