---
title: "Comparing cluster file systems MooseFS, BeeGFS, and Ceph"
layout: post
date:   2023-02-16 00:00:00 -0400
author: Juncheng
category: [system]
---

> TL;DR
> This blog posts talk about my experience setting up MooseFS, BeeGFS and Ceph on Cloudlab. 


# Background 

## What is a cluster file system
A cluster file system is a distributed file system that provides access to files stored on multiple servers in a cluster. It is designed to provide large capacity, high availability, scalability, and performance. 
## Why do I need a cluster file system
Some of my research heavily rely on large-scale measurement, data collection, and workload analysis, which involves 10s of TB of data. For example, my work at [OSDI’20](https://www.usenix.org/conference/osdi20/presentation/yang) studied the production workloads at Twitter; my work at [HotOS’23](https://dl.acm.org/doi/10.1145/3593856.3595887) revealed that *FIFO-based algorithms, e.g., FIFO-Reinsertionis not only faster and more scalable but also more efficient than LRU*. So there is no reason to use LRU for caching anymore.  
I use [Cloudlab](https://cloudlab.org) for my work (a great shoutout to the team at Cloudlab); however, there is no node possessing large and fast storage (TBs of NVMe drives). To solve this problem, I deploy a cluster file system on several nodes. Such deployment not only gives me more capacity with higher bandwidth but also allows me to run experiments in parallel. I have open-sourced [distComp](https://blog.jasony.me/), a tool that can schedule computation jobs on multiple nodes to maximize resource utilization. 
In this blog post, I will discuss different cluster file systems and my experience with them. 

## What are the options
I have deployed and benchmarked the following cluster file systems on Cloudab 
* MooseFS 
* BeeGFS
* Ceph

I have also evaluated the following. However, they do not meet my requirement of using local disks for a shared cluster file system
* GlusterFS
* SeaweedFS
* JuicyFS

SeaweedFS and JuicyFS are both written in Golang and have a similar architecture — decoupled metadata and data storage. However, they are not really cluster file systems, but rather a layer on top of existing object stores, e.g., S3. Both of them cannot use the local storage. They are good options if you plan to deploy a file system with S3 as the backend, but in such cases, there are also other easy-to-use options, such as goofys, which I have used extensively when I used to run experiments on AWS EC2. 

# Set up a cluster file system on Cloudlab

Setting up MooseFS and BeeGFS is not hard, simply follow the instructions on the website. I have also open-sourced my scripts for deploying MooseFS and BeeGFS on Cloudlab, you can [find them on GitHub](https://github.com/1a1a11a/blog_compare_cluster_file_system). 

Ceph is the hardest to deploy mostly because it fails to use the local disks without giving useful error messages. My deployment scripts can be used on Cloudlab, but may fail on other platforms. 



# Compare different cluster file systems 
## Ease of use
In my experience, Ceph is the most comprehensive system and is also the hardest to deploy. I met many errors during the deployment, and it took me more than two days to write some automated deployment scripts. In comparison, both BeeGFS and MooseFS have much better documentation and are easy to follow. 



## Features
Ceph has more features than the others. Besides being a file system, it also supports object storage and blocks device use cases. In comparison, BeeGFS and MooseFS are mostly designed to be cluster file systems. 

BeeGFS supports RDMA, which becomes the default networking protocol at some time point. 
In my earlier benchmarks of BeeGFS, it uses TCP/IP and does not have good performance, but the RDMA support seems to have changed the picture. 

Both BeeGFS and MooseFS use FUSE to mount the cluster file system, while Ceph can use either FUSE or kernel driver. 

All three file systems do not have good support for small files with large storage overheads. Moreover, small file accesses in all three are not good either due to the need for metadata access. 

## Fault tolerance
MooseFS supports replication in the default setting, while BeeGFS requires more complex setups to be fault tolerant. However, the free version of MooseFS does not support metadata redundancy. 
Ceph and MooseFS support erasure coding, while BeeGFS does not support erasure coding. 


## Performance 
### Setup
The experiments in this section were performed using 24 [r6525](http://docs.cloudlab.us/hardware.html) nodes from Cloudlab, each node has two sockets of 32-core AMD 7543 CPU with 256GB ECC memory, and a 480GB SATA SSD, a 1.6TB NVMe SSD, a Mellanox ConnectX-5 25 Gb NIC and a Mellanox ConnectX-6 100 Gb NIC.


I used the 1.6 TB NVMe SSD and the 100 Gbps NIC in the following experiments. The nodes are connected with a latency of less than 0.1 ms (most likely in a rack). The NVMe alone can provide 1 GB/s sustained sequential write bandwidth. 
I used the default setting in all systems without further tuning –- BeeGFS uses RDMA, and MooseFS and Ceph use kernel TCP/IP for communication. 

  
In this section, I will compare the performance of the cluster file systems, with a focus on bandwidth (measured by `fio` with io_uring engine). 
I choose to ignore availability, durability, and scalability since they are less important for my use cases. 


### Sequential Bandwidth 


<style>
    table {
        margin-left: auto;
        margin-right: auto;
    }
</style>


| file system | single node <br>sequential read <br>bandwidth (MB/s) | 24-node per-node<br>sequential read <br>bandwidth (MB/s) | single node <br>sequential write <br>bandwidth (MB/s) | 24-node per-node<br>sequential write <br>bandwidth (MB/s) |
|-------------|------------------------------------------------------|----------------------------------------------------------|-------------------------------------------------------|-----------------------------------------------------------|
| single nvme | 4080                                                 | -                                                        | 2200                                                  | -                                                         |
| MooseFS     | 3000                                                 | 4200                                                     | 1400                                                  | 1280                                                      |
| BeeGFS      | 2200                                                 | 148                                                      | 1400                                                  | 600                                                       |
| Ceph        | 9200                                                 | 560                                                      | 4400                                                  | 500                                                       |

Among all three file systems, Ceph has the best single node performance, significantly higher than the other two. I think this might be because of caching on the node. When the 24 nodes run benchmarks at the same time, the bandwidth BeeGFS and Ceph achieve is significantly lower than the corresponding single-node bandwidth. As a comparison, MooseFS can achieve almost perfect scaling. 


### Random IOPS


| file system | single node <br>random read (kIOPS) | 24-node per-node<br>random read (kIOPS) | single node <br>random write (kIOPS) | 24-node per-node<br>random write (kIOPS) |
|-------------|-------------------------------------|-----------------------------------------|--------------------------------------|------------------------------------------|
| single nvme | 320                                | -                                       | 460                                 | -                                        |
| MooseFS     | 108                                 | 100                                     | 16                                   | 7.6                                      |
| BeeGFS      | 68                                  | 6                                       | 5                                    | 6                                        |
| Ceph        | 150                                 | 90                                      | 110                                  | 70                                       |

When it comes to random read and write, BeeGFS has a much lower IOPS, no matter it is a single-node benchmark or multi-node benchmark. MooseFS and Ceph have comparable performance, both achieving 10x higher IOPS than BeeGFS. Between MooseFS and Ceph, MooseFS has a slightly lower IOPS except at the multi-node random write benchmark, on which MooseFS is as bad as BeeGFS. 
I have yet to look into why BeeGFS does not have similar performance, my guess would be metadata access and caching. 
 

### Latency
Because the network is not the bottleneck, there is no background traffic, and I did not write the drive to full, I did not notice high tail latency in any of the systems. In most cases, the P999 is close to P99, both of which are around 10 ms. 


### Other observations
BeeGFS’s performance is less consistent across runs. For example, within each run, the throughput may fluctuate over time by up to 20%. 
Moreover, there were multiple times, the random read performance was really bad — less than 100 IOPS. I am not sure what caused this, because both CPU and disks were not fully utilized during the benchmark. 


# My experience
Ceph has the best performance of all three cluster file systems. However, the setup experience is terrible. It failed at various places, most of the time OSD cannot be created even though there are disks available. Moreover, disk partitions cannot be used in Ceph, so if only have one disk in your server, even though the disk has a large partition, you cannot use Ceph. However, both MooseFS and BeeGFS do not have the problem. 
BeeGFS has the worst performance, which is very surprising because it uses RDMA, which should provide better performance. Moreover, I have tried the tuning guide, but it does not help.
MooseFS is the best in my view, mostly because it is easy to set up, and achieves performance close to Ceph. 


# Note
Although all scripts used in this blog are [open-sourced](https://github.com/1a1a11a/blog_compare_cluster_file_system), they are not meant for production, and they are not robust. For simple deployment on Cloudlab, they are good enough. 



