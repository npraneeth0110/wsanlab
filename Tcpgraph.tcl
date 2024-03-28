set ns [new Simulator]

# Set simulation parameters
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

# Create a topology
set topo [new Topography]
$topo load_flatgrid 500 500

# Open trace file for nam and output
set namfile [open out.nam w]
$ns namtrace-all-wireless $namfile 500 500

set tracefile [open out.tr w]
$ns trace-all $tracefile

# Create a god object for packet routing
create-god $val(nn)

# Node configuration
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
    -macTrace ON \
    -movementTrace ON

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# Set up links between nodes
$ns duplex-link $n0 $n3 1Mb 100ms DropTail
$ns duplex-link $n1 $n3 1Mb 100ms DropTail
$ns duplex-link $n2 $n3 1Mb 100ms DropTail
$ns duplex-link $n3 $n4 1Mb 100ms DropTail

# Procedure to attach TCP traffic to nodes
proc attach-tcp-traffic {node sink size rate} {
    global ns
    set source [new Agent/TCP]
    $ns attach-agent $node $source

    set traffic [new Application/Traffic/CBR]
    $traffic set packetSize_ $size
    $traffic set rate_ $rate

    $traffic attach-agent $source
    $ns connect $source $sink
    return $traffic
}

# Attach traffic sources to nodes
set sink0 [new Agent/LossMonitor]
set sink1 [new Agent/LossMonitor]
set sink2 [new Agent/LossMonitor]
$ns attach-agent $n4 $sink0
$ns attach-agent $n4 $sink1
$ns attach-agent $n4 $sink2

set source0 [attach-tcp-traffic $n0 $sink0 200 100k]
set source1 [attach-tcp-traffic $n1 $sink1 200 200k]
set source2 [attach-tcp-traffic $n2 $sink2 200 300k]

# Open output files for writing
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]

# Procedure to finish simulation
proc finish {} {
    global ns f0 f1 f2
    close $f0
    close $f1
    close $f2
    exec xgraph out0.tr out1.tr out2.tr -geometry 800x400 &
    exit 0
}

# Procedure to record bandwidth
proc record {} {
    global ns sink0 sink1 sink2 f0 f1 f2
    set time 0.5
    set bw0 [$sink0 set bytes_]
    set bw1 [$sink1 set bytes_]
    set bw2 [$sink2 set bytes_]
    set now [$ns now]
    puts $f0 "$now [expr $bw0/$time*8/1000000]"
    puts $f1 "$now [expr $bw1/$time*8/1000000]"
    puts $f2 "$now [expr $bw2/$time*8/1000000]"
    $sink0 set bytes_ 0
    $sink1 set bytes_ 0
    $sink2 set bytes_ 0
    $ns at [expr $now+$time] "record"
}

# Schedule recording and traffic start/stop
$ns at 0.0 "record"
$ns at 10.0 "$source0 start"
$ns at 10.0 "$source1 start"
$ns at 10.0 "$source2 start"
$ns at 50.0 "$source0 stop"
$ns at 50.0 "$source1 stop"
$ns at 50.0 "$source2 stop"
$ns at 60.0 "finish"

# Run the simulation
$ns run
