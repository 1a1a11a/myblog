---
title: "Running distributed computation on Cloudlab"
layout: post
date:   2023-08-01 00:00:00 -0400
author: Juncheng
category: [random, tool]
---


# Background
I like measurement and analysis, and I run a lot of trace analysis in the past. For example, I find that [FIFO-Reinsertion has a lower miss ratio than LRU for cache eviction](/system/cache/2023/06/24/fifo-lru.html), [simple FIFO-based algorithms can be more efficient and effective than state-of-the-art algorithms](/system/cache/2023/08/16/s3fifo.html). 

The analysis is performed using more than 6000 traces with more than 800 billion requests. In total, more than 1 million of CPU core hours are used. To perform such large-scale analysis, I need to run them in parallel. However, I cannot use existing platforms to do this easily because my scripts are highly-customized. Moreover, I need a platform that can **maximize resource utilization**. Because I cannot predict the CPU and memory usage of my jobs, the platform needs to run as many jobs as possible on each node, if later the resource usage grows beyond the capacity of the node, the latest job should be returned to the job pool.

Therefore, I need to build my own platform to run the analysis. 
So here is the distComp platform, it is open-sourced at [https://github.com/1a1a11a/distComp](https://github.com/1a1a11a/distComp).

# distComp
distComp is a platform to run distributed computation using data-parallel. Currently, it supports bash jobs and Python jobs. 
## Features
* **Utilization maximization**: distComp runs as many tasks as possible on each node. When memory usage is going to exceed node capacity, the most recent task will be returned to the to-do task queue.
* **On-demand task submission**: new tasks can be submitted at any time.
* **Fault tolerance**: Restarted workers can fetch their previous tasks to continue, and if some workers fail, the failed tasks can be moved to the todo queue.
* **Heterogeneous workers**: distComp supports heterogeneous workers, and it will assign more tasks to beefier workers.


## Architecture 
<center>
<figure style="width: 96%" class="align-center">
  <img src="https://github.com/1a1a11a/distComp/raw/main/diagram/diagram.svg" alt="architecture diagram" style="width:64%">
  <figcaption><h4>distComp architecture </h4></figcaption>
</figure> 
</center>

The architecture of distComp has evolved over time. The first version uses RPC with worker nodes fetching tasks from the master node. However, this design couples states into the master, which is hard to be fault-tolerant.
The current version of distComp uses a manager-worker architecture. The manager node submits the tasks to a Redis instance (running on the same node as the manager). 
The worker nodes perform the computation. 
The task submission and task execution are decoupled. Meanwhile, the state is persisted in Redis which periodically saves the state to disk.


## How to use 
### 0. Prepare worker nodes
You need to prepare the worker nodes to run the tasks, e.g., install dependencies. 
Besides the dependency of running the task, the worker and manager nodes need to install `redis` and `psutil` packages. 
```bash
pip install redis psutil
```
And the manager needs `parallel-ssh` to launch jobs. 

If your task requires data, the data must be accessible on the worker nodes.
You can consider using a cluster file system, e.g., [MooseFS](https://moosefs.com/), to aggregate disk capacity from all workers and provide high-bandwidth access to data. 

### 1. Setup Redis on the manager node
```bash
bash ./redis.sh
```

### 2. Create the tasks to be run
Create a file containing all the tasks. Each line in the file consists of a task in the following format:

```bash
# task type:priority:min_dram:min_cpu:task_params
# echo 'shell:4:2:2:./cachesim PARAM1 PARAM2' >> task

# submit the tasks to the Redis
python3 redisManager.py --task 'initRedis&loadTask' --taskfile task

```

### 3. Start the worker nodes
We use the `parallel-ssh` tool to start the scripts on the worker nodes. The list of workers (ip or hostname) is stored in the `host` file.

```bash
parallel-ssh -h host -i -t 0 '''
    cd /PATH/TO/DistComp;
    screen -S worker -L -Logfile workerScreen/$(hostname) -dm python3 redisWorker.py
'''
```

### 4. Monitor the progress
```bash
# check the task status
python3 redisManager.py --task checkTask --finished false --todo false --in_progress false --failed false

# check the worker status
python3 redisManager.py --task checkWorker

# monitor the task progress
watch "python3 redisManager.py --task 'checkTask&checkWorker' --finished false --print_result false --in_progress false"

```

## Caution
distComp is *not* designed for production use, and I have not extensively tested it nor have a well-designed user interface. 
distComp only support limited simple fault tolerance, and I have not tested against all possible failure scenarios.
