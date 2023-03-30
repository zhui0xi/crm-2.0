package com.chen.crm.workbench.domain;

import java.io.Serializable;

public class ClueActivityRelation implements Serializable {

	private static final long serialVersionUID = -4678692430315852070L;
	private String id;
	private String clueId;
	private String activityId;
	
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getClueId() {
		return clueId;
	}
	public void setClueId(String clueId) {
		this.clueId = clueId;
	}
	public String getActivityId() {
		return activityId;
	}
	public void setActivityId(String activityId) {
		this.activityId = activityId;
	}
	
	

	
}
