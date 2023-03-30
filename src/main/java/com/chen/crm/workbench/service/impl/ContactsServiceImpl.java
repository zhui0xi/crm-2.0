package com.chen.crm.workbench.service.impl;

import com.chen.crm.workbench.dao.ContactsDao;
import com.chen.crm.workbench.dao.TranDao;
import com.chen.crm.workbench.domain.Tran;
import com.chen.crm.workbench.service.ContactsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ContactsServiceImpl implements ContactsService {

    @Autowired
    private TranDao tranDao;

    @Autowired
    private ContactsDao contactsDao;

    @Override
    public Object getContactsByTranId(String tranId) {

        Tran t = tranDao.getTran(tranId);

        return contactsDao.getContacts(t.getContactsId());
    }
}
