package com.chen.crm.workbench.service;

import java.util.List;

public interface CustomerService {
    List<String> getCustomerName(String name);

    Object getCustomerByTranId(String tranId);
}
