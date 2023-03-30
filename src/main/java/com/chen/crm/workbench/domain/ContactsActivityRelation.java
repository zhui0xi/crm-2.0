package com.chen.crm.workbench.domain;

import java.io.Serializable;

public class ContactsActivityRelation implements Serializable {

	private static final long serialVersionUID = 5841629257314730898L;
	private String id;
	private String contactsId;
	private String activityId;
	
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getContactsId() {
		return contactsId;
	}
	public void setContactsId(String contactsId) {
		this.contactsId = contactsId;
	}
	public String getActivityId() {
		return activityId;
	}
	public void setActivityId(String activityId) {
		this.activityId = activityId;
	}
	
	
	
}
