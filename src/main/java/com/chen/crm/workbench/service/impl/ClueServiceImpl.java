package com.chen.crm.workbench.service.impl;

import com.chen.crm.utils.DateTimeUtil;
import com.chen.crm.utils.UUIDUtil;
import com.chen.crm.web.vo.PageListVo;
import com.chen.crm.workbench.dao.*;
import com.chen.crm.workbench.domain.*;
import com.chen.crm.workbench.service.ClueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
public class ClueServiceImpl implements ClueService {
    @Autowired
    private ClueDao clueDao;
    @Autowired
    private ClueRemarkDao clueRemarkDao;
    @Autowired
    private ClueActivityRelationDao clueActivityRelationDao;

    @Autowired
    private CustomerDao customerDao;
    @Autowired
    private CustomerRemarkDao customerRemarkDao;

    @Autowired
    private ContactsDao contactsDao;
    @Autowired
    private ContactsRemarkDao contactsRemarkDao;
    @Autowired
    private ContactsActivityRelationDao contactsActivityRelationDao;

    @Autowired
    private TranDao tranDao;
    @Autowired
    private TranHistoryDao tranHistoryDao;

    @Override
    public PageListVo<Clue> getPageList(Map<String, Object> map) {
        //先获取所有符合条件的线索的数量
        int total = clueDao.getTotalByCondition(map);

        //再获取所有符合条件的线索
        List<Clue> dataList = clueDao.getClueListByCondition(map);

        PageListVo<Clue> vo = new PageListVo<>();
        vo.setTotal(total);
        vo.setDataList(dataList);
        return vo;
    }

    @Transactional
    @Override
    public boolean save(Clue c) {
        boolean flag = true;

        int count = clueDao.save(c);

        if (count != 1) {
            flag = false;
        }

        return flag;
    }

    @Override
    public Clue detail(String id) {
        return clueDao.getClueById(id);
    }

    @Transactional
    @Override
    public boolean remove(String carId) {
        boolean flag = true;

        int count = clueDao.remove(carId);

        if (count != 1) {
            flag = false;
        }

        return flag;
    }

    @Transactional
    @Override
    public boolean convert(String clueId, Tran tran, String createBy) {

        boolean flag = true;

        //查询本线索的信息（潜在用户）
        Clue c = clueDao.getClue(clueId);

        String company = c.getCompany();
        //查看客户，如果存在了，就不需要创建客户了
        //要精确定位
        Customer customer = customerDao.getCustomerByName(company);

        //创建客户
        if (customer == null) {
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setOwner(c.getOwner());
            customer.setName(c.getCompany());
            customer.setWebsite(c.getWebsite());
            customer.setPhone(c.getPhone());
            customer.setCreateBy(createBy);
            customer.setCreateTime(DateTimeUtil.getSysTime());
            customer.setContactSummary(c.getContactSummary());
            customer.setNextContactTime(c.getNextContactTime());
            customer.setDescription(c.getDescription());
            customer.setAddress(c.getAddress());
            int count1 = customerDao.save(customer);
            if (count1 != 1) {
                flag = false;
            }
        }

        //创建联系人
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtil.getUUID());
        contacts.setOwner(c.getOwner());
        contacts.setSource(c.getSource());
        contacts.setCustomerId(customer.getId());
        contacts.setFullname(c.getFullname());
        contacts.setAppellation(c.getAppellation());
        contacts.setEmail(c.getEmail());
        contacts.setMphone(c.getMphone());
        contacts.setJob(c.getJob());
        contacts.setCreateBy(createBy);
        contacts.setCreateTime(DateTimeUtil.getSysTime());
        contacts.setDescription(c.getDescription());
        contacts.setContactSummary(c.getContactSummary());
        contacts.setNextContactTime(c.getNextContactTime());
        contacts.setAddress(c.getAddress());
        int count2 = contactsDao.save(contacts);
        if (count2 != 1) {
            flag = false;
        }

        //查询本线索的备注
        List<String> noteContentList = clueRemarkDao.getClueRemarkByClueId(clueId);
        if (noteContentList != null) {
            for (String noteContent : noteContentList) {
                //创建客户的备注
                CustomerRemark customerRemark = new CustomerRemark();
                customerRemark.setId(UUIDUtil.getUUID());
                customerRemark.setNoteContent(noteContent);
                customerRemark.setCreateBy(createBy);
                customerRemark.setCreateTime(DateTimeUtil.getSysTime());
                customerRemark.setEditFlag("0");
                customerRemark.setCustomerId(customer.getId());
                int count3 = customerRemarkDao.save(customerRemark);
                if (count3 != 1) {
                    flag = false;
                }

                //创建联系人的备注
                ContactsRemark contactsRemark = new ContactsRemark();
                contactsRemark.setId(UUIDUtil.getUUID());
                contactsRemark.setNoteContent(noteContent);
                contactsRemark.setCreateBy(createBy);
                contactsRemark.setCreateTime(DateTimeUtil.getSysTime());
                contactsRemark.setEditFlag("0");
                contactsRemark.setContactsId(contacts.getId());
                int count4 = contactsRemarkDao.save(contactsRemark);
                if (count4 != 1) {
                    flag = false;
                }
            }
        }

        //查询本线索的市场活动的关联
        List<String> activityIdList = clueActivityRelationDao.getByClueId(clueId);
        if (activityIdList != null) {
            for (String activityId : activityIdList) {
                //创建联系人与市场活动的关联
                ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
                contactsActivityRelation.setId(UUIDUtil.getUUID());
                contactsActivityRelation.setContactsId(contacts.getId());
                contactsActivityRelation.setActivityId(activityId);
                int count5 = contactsActivityRelationDao.save(contactsActivityRelation);
                if (count5 != 1) {
                    flag = false;
                }
            }
        }

        //创建交易
        if (tran != null) {
            //补充一下信息
            tran.setSource(c.getSource());
            tran.setOwner(c.getOwner());
            tran.setNextContactTime(c.getNextContactTime());
            tran.setDescription(c.getDescription());
            tran.setCustomerId(customer.getId());
            tran.setContactSummary(c.getContactSummary());
            tran.setContactsId(contacts.getId());
            int count6 = tranDao.save(tran);
            if (count6 != 1) {
                flag = false;
            }

            //创建交易历史
            TranHistory tranHistory = new TranHistory();
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setTranId(tran.getId());
            tranHistory.setStage(tran.getStage());
            tranHistory.setMoney(tran.getMoney());
            tranHistory.setExpectedDate(tran.getExpectedDate());
            tranHistory.setCreateBy(tran.getCreateBy());
            tranHistory.setCreateTime(DateTimeUtil.getSysTime());
            int count7 = tranHistoryDao.save(tranHistory);
            if (count7 != 1) {
                flag = false;
            }
        }

        //删除本线索的备注
        int count8 = clueRemarkDao.delete(clueId);
        if (count8 != 1) {
            flag = false;
        }

        //删除本线索与市场活动的关联
        int count9 = clueActivityRelationDao.delete(clueId);
        if (count9 != 1) {
            flag = false;
        }

        //删除本线索
        int count10 = clueDao.delete(clueId);
        if (count10 != 1) {
            flag = false;
        }

        return flag;
    }

    @Override
    public Clue getClueById(String id) {
        return clueDao.getClueById(id);
    }

    @Transactional
    @Override
    public boolean update(Clue c) {
        return clueDao.update(c);
    }

    @Transactional
    @Override
    public boolean deleteByIds(String[] id) {
        return clueDao.deleteByIds(id);
    }
}
