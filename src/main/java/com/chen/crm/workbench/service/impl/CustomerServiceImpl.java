package com.chen.crm.workbench.service.impl;

import com.chen.crm.workbench.dao.CustomerDao;
import com.chen.crm.workbench.dao.TranDao;
import com.chen.crm.workbench.domain.Tran;
import com.chen.crm.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomerServiceImpl implements CustomerService {
    @Autowired
    private CustomerDao customerDao;

    @Autowired
    private TranDao tranDao;

    @Override
    public List<String> getCustomerName(String name) {
        return customerDao.getCustomerName(name);
    }

    @Override
    public Object getCustomerByTranId(String tranId) {

        Tran t = tranDao.getTran(tranId);

        return customerDao.getCustomer(t.getCustomerId());
    }
}
