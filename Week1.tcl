set ns [new Simulator]
set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(ifqLen) 50
set val(nn) 2
set val(rp) AODV
set val(x) 500
set val(y) 500

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

set namfile [open out.nam w]
$ns namtrace-all-wireless $namfile $val(x) $val(y)

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

set n1 [$ns node]
set n2 [$ns node]

$n1 color black
$n2 color black

$n1 set X_ 200
$n1 set Y_ 100
$n1 set Z_ 0

$n2 set X_ 200
$n2 set Y_ 300
$n2 set Z_ 0

$ns at 0.1 "$n1 color blue"
$ns at 0.1 "$n1 label node1"
$ns at 0.1 "$n2 label node2"

$ns initial_node_pos $n1 30
$ns initial_node_pos $n2 30

proc finish {} {
    global ns namfile tracefile
    $ns flush-trace
    close $namfile
    close $tracefile
    exec nam out.nam &
}

$ns at 10.0 "finish"
$ns run
