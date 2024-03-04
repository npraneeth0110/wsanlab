set ns [new Simulator]
set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(ifqLen) 50
set val(nn) 4
set val(rp) DSDV
set topo [new Topography]
$topo load_flatgrid 500 500
set namfile [open out.nam w]
$ns namtrace-all-wireless $namfile 500 500
set tracefile [open out.tr w]
$ns trace-all $tracefile
create-god $val(nn)
$ns node-config -adhocRouting $val(rp) \
    -channelType $val(chan) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -llType $val(ll) \
    -antType $val(ant) \
    -ifqLen $val(ifqLen) \
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace ON \
    -macTrace OFF \
    -movementTrace ON

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$n0 set X_ 200
$n0 set Y_ 100
$n0 set Z_ 0

$n1 set X_ 200
$n1 set Y_ 250
$n1 set Z_ 0

$n2 set X_ 200
$n2 set Y_ 300
$n2 set Z_ 0

$n3 set X_ 100
$n3 set Y_ 270
$n3 set Z_ 0

$ns initial_node_pos $n0 30
$ns initial_node_pos $n1 30
$ns initial_node_pos $n2 30
$ns initial_node_pos $n3 30

$ns at 0.2 "$n0 setdest 89 370 8"
$ns at 0.2 "$n1 setdest 40 250 8"
$ns at 0.2 "$n2 setdest 430 150 8"
$ns at 0.2 "$n3 setdest 60 90 8"

set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]

$ns attach-agent $n2 $tcp
$ns attach-agent $n1 $sink
$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.1 "$ftp start"

set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]

$ns attach-agent $n0 $tcp1
$ns attach-agent $n3 $sink1
$ns connect $tcp1 $sink1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns at 0.2 "$ftp1 start"

proc finish {} {
    global namfile tracefile
    close $namfile
    close $tracefile
    exec nam out.nam &
    exit
}

$ns at 12.0 "finish"
$ns run
