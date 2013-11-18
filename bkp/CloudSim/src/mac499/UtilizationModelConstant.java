package mac499;

import org.cloudbus.cloudsim.UtilizationModel;

public class UtilizationModelConstant implements UtilizationModel {
	private double utilization;

	public UtilizationModelConstant(double utilization){
		this.utilization = utilization;
	}
	
	@Override
	public double getUtilization(double time) {
		return utilization;
	}

}
