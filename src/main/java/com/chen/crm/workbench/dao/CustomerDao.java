package com.chen.crm.workbench.dao;

import com.chen.crm.workbench.domain.Customer;

import java.util.List;

public interface CustomerDao {

    int save(Customer cus);

    Customer getCustomerByName(String company);

    List<String> getCustomerName(String name);

    Object getCustomer(String customerId);
}
