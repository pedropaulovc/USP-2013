/**
 * Copyright 2012-2013 University Of Southern California
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package mac499.power.examples;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.LinkedList;
import java.util.List;

import org.cloudbus.cloudsim.Cloudlet;
import org.cloudbus.cloudsim.CloudletSchedulerSpaceShared;
import org.cloudbus.cloudsim.DatacenterCharacteristics;
import org.cloudbus.cloudsim.Host;
import org.cloudbus.cloudsim.Log;
import org.cloudbus.cloudsim.Pe;
import org.cloudbus.cloudsim.Storage;
import org.cloudbus.cloudsim.Vm;
import org.cloudbus.cloudsim.VmAllocationPolicySimple;
import org.cloudbus.cloudsim.VmSchedulerTimeShared;
import org.cloudbus.cloudsim.VmSchedulerTimeSharedOverSubscription;
import org.cloudbus.cloudsim.core.CloudSim;
import org.cloudbus.cloudsim.examples.power.Constants;
import org.cloudbus.cloudsim.examples.power.Helper;
import org.cloudbus.cloudsim.power.PowerHost;
import org.cloudbus.cloudsim.power.PowerHostUtilizationHistory;
import org.cloudbus.cloudsim.provisioners.BwProvisionerSimple;
import org.cloudbus.cloudsim.provisioners.PeProvisionerSimple;
import org.cloudbus.cloudsim.provisioners.RamProvisionerSimple;

import com.sun.corba.se.impl.orbutil.closure.Constant;

import mac499.power.ClusterStorage;
import mac499.power.PowerDatacenterExtended;
import mac499.power.PowerCondorVM;
import mac499.power.PowerDatacenterExtended;
import mac499.power.Job;
import mac499.power.PowerWorkflowEngine;
import mac499.power.WorkflowPlanner;
import mac499.power.failure.FailureGenerator;
import mac499.power.failure.FailureMonitor;
import mac499.power.utils.ArgumentParser;
import mac499.power.utils.Parameters;

/**
 * This WorkflowSimExample creates a workflow planner, a workflow engine, and
 * one schedulers, one data centers and 20 vms. All the configuration of
 * CloudSim is done in WorkflowSimExamplex.java All the configuration of
 * WorkflowSim is done in the config.txt that must be specified in argument of
 * this WorkflowSimExample. The argument should have at least: "-p
 * path_to_config.txt"
 *
 * @author Weiwei Chen
 * @since WorkflowSim Toolkit 1.0
 * @date Apr 9, 2013
 */
public class PowerWSExample2 {

    private static List<Vm> createVM(int userId, int vms) {

        //Creates a container to store VMs. This list is passed to the broker later
        LinkedList<Vm> list = new LinkedList<Vm>();

        //VM Parameters
        long size = 500000; //image size (MB)
        int ram = 256; //vm memory (MB)
        int mips = 250;
        long bw = 1000;
        int pesNumber = 1; //number of cpus
        String vmm = "Xen"; //VMM name

        //create VMs
        PowerCondorVM[] vm = new PowerCondorVM[vms];

        for (int i = 0; i < vms; i++) {
            double ratio = 1.0;
            vm[i] = new PowerCondorVM(i, userId, mips * ratio, pesNumber, ram, bw, size, 1, vmm, new CloudletSchedulerSpaceShared(), Constants.SCHEDULING_INTERVAL);
            list.add(vm[i]);
        }

        return list;
    }

    ////////////////////////// STATIC METHODS ///////////////////////
    /**
     * Creates main() to run this example
     * This example has only one datacenter and one storage
     */
    public static void main(String[] args) {
    	String experimentName = "ws_dvfs";

        try {
            // First step: Initialize the CloudSim package. It should be called


            ArgumentParser option = new ArgumentParser(args);//init is done in option

            FailureMonitor.init();//it doesn't really matter?
            FailureGenerator.init();//must do it so as to initialize FTC

            // before creating any entities.
            int num_user = 1;   // number of grid users
            Calendar calendar = Calendar.getInstance();
            boolean trace_flag = false;  // mean trace events

            /**
             * Here we overwrites the vmNum set in config.txt.
             */
            /**
             * However, the exact number of vms may not necessarily be vmNum If
             * the data center or the host doesn't have sufficient resources the
             * exact vmNum would be smaller than that. Take care.
             */
            int vmNum = 0;//number of vms;
            Parameters.setVmNum(vmNum);

            // Initialize the CloudSim library
            CloudSim.init(num_user, calendar, trace_flag);

            PowerDatacenterExtended datacenter0 = createDatacenter("Datacenter_0");

            /**
             * Create a WorkflowPlanner with one schedulers.
             */
            WorkflowPlanner wfPlanner = new WorkflowPlanner("planner_0", 1);
            /**
             * Create a WorkflowEngine.
             */
            PowerWorkflowEngine wfEngine = wfPlanner.getWorkflowEngine();
            /**
             * Create a list of VMs.The userId of a vm is basically the id of the scheduler
             * that controls this vm. 
             */
            List<Vm> vmlist0 = createVM(wfEngine.getSchedulerId(0), Parameters.getVmNum());

            /**
             * Submits this list of vms to this WorkflowEngine.
             */
            wfEngine.submitVmList(vmlist0, 0);

            /**
             * Binds the data centers with the scheduler.
             */
            wfEngine.bindSchedulerDatacenter(datacenter0.getId(), 0);

            double lastClock = CloudSim.startSimulation();


            List<Job> outputList0 = wfEngine.getJobsReceivedList();

            CloudSim.stopSimulation();

            printJobList(outputList0);
            datacenter0.printDebts();
            
            Helper.printResults(
					datacenter0,
					vmlist0,
					lastClock,
					experimentName,
					Constants.OUTPUT_CSV,
					"");

        } catch (Exception e) {
            Log.printLine("The simulation has been terminated due to an unexpected error");
        }
    }

    private static PowerDatacenterExtended createDatacenter(String name) {

        // Here are the steps needed to create a PowerDatacenter:
        // 1. We need to create a list to store one or more
        //    Machines
        List<PowerHost> hostList = new ArrayList<PowerHost>();

        // 2. A Machine contains one or more PEs or CPUs/Cores. Therefore, should
        //    create a list to store these PEs before creating
        //    a Machine.
        for (int i = 0; i < 2; i++) {
        	int hostType = i % Constants.HOST_TYPES;
            List<Pe> peList1 = new ArrayList<Pe>();
            // 3. Create PEs and add these into the list.
            //for a quad-core machine, a list of 4 PEs is required:
            for(int j = 0; j < 1; j++)
            	peList1.add(new Pe(j, new PeProvisionerSimple(1000)));
            
            hostList.add(
                    new PowerHostUtilizationHistory(
                    i,
                    new RamProvisionerSimple(1024),
                    new BwProvisionerSimple(Constants.HOST_BW),
                    Constants.HOST_STORAGE,
                    peList1,
                    new VmSchedulerTimeSharedOverSubscription(peList1),
                    Constants.HOST_POWER[0])); // This is our first machine
        }

        // 5. Create a DatacenterCharacteristics object that stores the
        //    properties of a data center: architecture, OS, list of
        //    Machines, allocation policy: time- or space-shared, time zone
        //    and its price (G$/Pe time unit).
        String arch = "x86";      // system architecture
        String os = "Linux";          // operating system
        String vmm = "Xen";
        double time_zone = -3.0;         // time zone this resource located
        double cost = 3.0;              // the cost of using processing in this resource
        double costPerMem = 0.05;		// the cost of using memory in this resource
        double costPerStorage = 0.1;	// the cost of using storage in this resource
        double costPerBw = 0.1;			// the cost of using bw in this resource
        LinkedList<Storage> storageList = new LinkedList<Storage>();	//we are not adding SAN devices by now
        PowerDatacenterExtended datacenter = null;


        DatacenterCharacteristics characteristics = new DatacenterCharacteristics(
                arch, os, vmm, hostList, time_zone, cost, costPerMem, costPerStorage, costPerBw);


        // 6. Finally, we need to create a cluster storage object.
        /**
         * The bandwidth within a data center.
         */
        double intraBandwidth = 1.5e7;// the number comes from the futuregrid site, you can specify your bw
        intraBandwidth = Parameters.getOverheadParams().getBandwidth();

        try {
            ClusterStorage s1 = new ClusterStorage(name, 1e12);
            
            // The bandwidth within a data center
            s1.setBandwidth("local", intraBandwidth);
            // The bandwidth to the source site 
            s1.setBandwidth("source", intraBandwidth);
            storageList.add(s1);
            datacenter = new PowerDatacenterExtended(name, characteristics, new VmAllocationPolicySimple(hostList), storageList, 0);
        } catch (Exception e) {
        }

        return datacenter;
    }

    /**
     * Prints the job objects
     *
     * @param list list of jobs
     */
    private static void printJobList(List<Job> list) {
        int size = list.size();
        Job job;

        String indent = "    ";
        Log.printLine();
        Log.printLine("========== OUTPUT ==========");
        Log.printLine("Cloudlet ID" + indent + "STATUS" + indent
                + "Data center ID" + indent + "VM ID" + indent + indent + "Time" + indent + "Start Time" + indent + "Finish Time" + indent + "Depth");

        DecimalFormat dft = new DecimalFormat("###.##");
        for (int i = 0; i < size; i++) {
            job = list.get(i);
            Log.print(indent + job.getCloudletId() + indent + indent);

            if (job.getCloudletStatus() == Cloudlet.SUCCESS) {
                Log.print("SUCCESS");

                Log.printLine(indent + indent + job.getResourceId() + indent + indent + indent + job.getVmId()
                        + indent + indent + indent + dft.format(job.getActualCPUTime())
                        + indent + indent + dft.format(job.getExecStartTime()) + indent + indent + indent
                        + dft.format(job.getFinishTime()) + indent + indent + indent + job.getDepth());
            } else if (job.getCloudletStatus() == Cloudlet.FAILED) {
                Log.print("FAILED");

                Log.printLine(indent + indent + job.getResourceId() + indent + indent + indent + job.getVmId()
                        + indent + indent + indent + dft.format(job.getActualCPUTime())
                        + indent + indent + dft.format(job.getExecStartTime()) + indent + indent + indent
                        + dft.format(job.getFinishTime()) + indent + indent + indent + job.getDepth());
            }
        }

    }
}
