set ns [new Simulator]
set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(ifqLen) 50
set val(nn) 3
set val(rp) AODV

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

$n0 set X_ 180
$n0 set Y_ 90
$n0 set Z_ 0

$n1 set X_ 60
$n1 set Y_ 30
$n1 set Z_ 0

$n2 set X_ 130
$n2 set Y_ 130
$n2 set Z_ 0

$ns initial_node_pos $n0 30
$ns initial_node_pos $n1 30
$ns initial_node_pos $n2 30

$ns at 1.0 "$n0 setdest 200 350 8"
$ns at 1.0 "$n1 setdest 20 250 8"
$ns at 1.0 "$n2 setdest 430 150 8"

set udp [new Agent/UDP]
set null [new Agent/Null]

$ns attach-agent $n2 $udp
$ns attach-agent $n1 $null
$ns connect $udp $null

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp

$ns at 0.1 "$cbr start"

proc finish {} {
    global namfile tracefile
    close $namfile
    close $tracefile
    exec nam out.nam &
    exit
}

$ns at 12.0 "finish"
$ns run
