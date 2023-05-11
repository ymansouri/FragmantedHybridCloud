# FragmentedHybridCloud
* This project helps to design and implement a layered fragmented cloud framework in which a set of Linux-based tools enables us to create a mesh network,control latency and traffic, and handle network accessibility.
* Evaluate the impact of time-varying latency and bandwidth on distributed databases performance.
* Measure the impact of removing/adding computing nodes at application levels on the performance of databases.
* Assessed the effect of network accessibility on the responsiveness of databases.

Getting Started
---------------

This implementation involves two parts:

**Part-1 - Implementation of fragmented hybrid cloud framework**

**Part-2 - Running experimental scenarios mentioned in the paper**

Part-1 - Implementation of fragmented hybrid cloud framework
-----------

### Infrastructure deployment

1. Create a cluster of virtual machines using private cloud or public cloud (Microsoft Azure/AWS)
2. Install and setup databases (MongoDB, Cassandra, Redis, MySQl)

### Editing variable files and create symlink.

1. In home folder, please change the variables mentioned in **config** file. Create symlink for **config** file in each folder. 
2. Variables to change:
    * VM_USERNAME
    * SSH_KEY_FILE
    * IP_FOLDER
    * HOME_FOLDER
    * PUBLIC_IPS_FILE
    * PRIVATE_IPS_FILE
    * PRIVATE_IPS_SSH_FILE
    * PUBLIC_IPS_FILE_TCSET
    * PRIVATE_IPS_FILE_TCSET
    * PRIVATE_NETWORK_INTERFACE
    * PATH_PREFIX
    * NETWORK_INTERFACE
    * BANDWIDTH_FILE
    * LATENCY_FILE
    * WORKER_IP
    * WORKER_IP_IN_CLUSTER
    * RESULTS
    * PATH_PREFIX_FOR_EXPERIMENT
4. For example:
    ```sh
    ln –s FragmantedHybridCloud/config 01-wireguard-config/config 
    ```
2. Edit **CLUSTER-NODES** file and create symlink in each folder.

### Mesh network creation
1. Installation of wireguard on all VMs and mesh network creation will be done by running command:
    ```sh
    01-wireguard-config/00-wireguard-setup
    ```
2. A way to check if Step-1 is successfully completed.
      When the script finished execution, a file named as "**mesh_network_connected_links.csv**" will be found in "**02-tc-config/default-files**" folder.
      *Please note this file will give all the information about the mesh network created in step-1.*

### Mesh network destruction

1. Mesh network can be destroyed using command:
    ```sh
    01-wireguard-config/04-mesh-network-destruction
    ```
*Note: For successful running of all the scenarios, do not destroy mesh network until all the scenarios finished.*

### Creation of Geo-distributed hybrid cloud environment

1. Install tcset on all nodes, applying latency and bandwidth rules specified in "**02-tc-config/default-files/latency.csv**" & "**02-tc-config/default-files/bandwidth.csv**" files. Run command:
    ```sh
    02-tc-config/00-tc-setup.sh
    ```
2. Verify if Step-1 is successfully completed.

   When above script will finished properly, it will display the rules on terminal.
   
3. To remove rules applied in Step-2. Run command:
    ```sh
    02-tc-config/04-remove-bandwidth-latency-matrix-rules.sh
    ```
### Tinc setup

1. To install and configure tinc on all nodes. Run following commands
    ```sh
    ./03-tinc-config/00-tinc-setup
    ```
2. Verify if Step-1 is successfully completed.
    
    Ping test using tinc interface on all nodes.
    
3. To remove tinc on all nodes. Run:
    ```sh
    ./03-tinc-config/06-tinc-stop.sh
    ./03-tinc-config/07-tinc-remove
    ```
Part-2 - Running experimental scenarios mentioned in the paper
-----------
### Scenario -1 (Impact of time-varying latency between cluster nodes on the throughput of databases)

Assuming that, Part-1 has been successfully finished and verified.

1. Run the following command to run the whole experiments when latency changes from X to 5X.
    ```sh
    ./04-experiment-scenarios/frag-experiments-scenario-run 
    ```
### Scenario - 2 (Impact of down-sizing and up-sizing of cluster on the throughput)
1. Run the following command to run whole experiment when node(s) are added or removed from the cluster. This script run for 5X and X latencies.

    ```sh
    ./04-experiment-scenarios/frag-experiments-scenario-run-nodes-add-remove
    ```
### Scenario - 3 (Impact of links removal on the performance)
#### Densely connected network
1. Run the following command to run whole experiment when node(s) are added or removed from the cluster. This script run for 5X and X latencies.

    ```sh
    ./04-experiment-scenarios/frag-multiple-links-experiments-without-link-remove
    ```
#### Sparsely connected network
2. Run the following command to run whole experiment when node(s) are added or removed from the cluster. This script run for 5X and X latencies.

    ```sh
    ./02-tc-config/10-tcset-scenario_3.sh
    ./04-experiment-scenarios/frag-multiple-links-experiments
    ```
