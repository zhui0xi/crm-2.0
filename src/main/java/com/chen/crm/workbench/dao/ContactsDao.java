package com.chen.crm.workbench.dao;

import com.chen.crm.workbench.domain.Contacts;

public interface ContactsDao {

    int save(Contacts con);

    Object getContacts(String contactsId);
}
