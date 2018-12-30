BEGIN {

	totPktrecv=-1
	totPktsend=0
	drop=0
	totByteRecv=0
	totTime=0
	Throghput=0
	delay=0
	avgDelay=0
	pktIndex=10000000
	i=0
	pktId[pktIndex]
	num_pkt=-1
	totTime=0
	t=0
	Avg_Delay=0
	Pkt_del_ratio=0
	Pkt_drp_ratio=0
}
{
	intSrc=$3
	intDest=$4
	event=$1
	dest=$10
	pId=$12
	time=$2
	

	if(event=="r"&&intDest==dest)
	{

		++totPktrecv
		totByteRecv=totByteRecv+$6
		pktId[pId]=time-pktId[pId];
		totTime=totTime+pktId[pId]
		
		
	}
	
	if(event=="+"&&pktId[pId]==0)
	{
		pktId[pId]=time;
		++num
	}

	
	if(event=="d")
	{
		++drop
	}
}
END {

	#Compute Throuhput
	totByteRecv=totByteRecv*(8/1000000)
	Throghput=totByteRecv/totTime
	Avg_Delay=num/totTime
	Pkt_del_ratio=num/totPktrecv
	Pkt_drp_ratio=drop/num
	#printf("total pkts recv: %g\n",totPktrecv);
	#printf("total Bytes recv : %g MB\n",totByteRecv);
	#printf("total pkts drop: %g\n",drop);
	printf("%g\n",Throghput);
	#printf("Avg Delay: %g s\n",Avg_Delay);
	#printf("Packet delivery ratio: %g\n",Pkt_del_ratio)
	#printf("Packet drop ratio: %g\n",Pkt_drp_ratio)
	
}

#Throughput = received_data*8/DataTransmissionPeriod
#java -jar NSG2.1.jar
