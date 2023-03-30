package com.chen.crm.workbench.service.impl;

import com.chen.crm.utils.DateTimeUtil;
import com.chen.crm.utils.UUIDUtil;
import com.chen.crm.web.vo.PageListVo;
import com.chen.crm.workbench.dao.CustomerDao;
import com.chen.crm.workbench.dao.TranDao;
import com.chen.crm.workbench.dao.TranHistoryDao;
import com.chen.crm.workbench.domain.Customer;
import com.chen.crm.workbench.domain.Tran;
import com.chen.crm.workbench.domain.TranHistory;
import com.chen.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class TranServiceImpl implements TranService {
    @Autowired
    private TranDao tranDao;
    @Autowired
    private TranHistoryDao tranHistoryDao;

    @Autowired
    private CustomerDao customerDao;

    @Transactional
    @Override
    public boolean save(Tran t, String customerName) {
        boolean flag = true;

        //根据客户的名称精确查询客户
        //如果客户存在，取出客户的id，封装到t对象中
        //如果客户不存在，创建新的客户，取出客户的id，封装到t对象中
        Customer cus = customerDao.getCustomerByName(customerName);
        if (cus == null) {
            //创建客户
            cus = new Customer();
            cus.setId(UUIDUtil.getUUID());
            cus.setName(customerName);
            cus.setCreateBy(t.getCreateBy());
            cus.setCreateTime(DateTimeUtil.getSysTime());
            cus.setOwner(t.getOwner());
            cus.setDescription(t.getDescription());
            cus.setNextContactTime(t.getNextContactTime());
            int count1 = customerDao.save(cus);
            if (count1 != 1) {
                flag = false;
            }
        }

        //经过以上操作，怎么都有该customerName名称的客户了
        t.setCustomerId(cus.getId());

        //创建交易
        int count2 = tranDao.save(t);
        if (count2 != 1) {
            flag = false;
        }

        //创建交易历史
        TranHistory th = new TranHistory();
        th.setId(UUIDUtil.getUUID());
        th.setTranId(t.getId());
        th.setStage(t.getStage());
        th.setMoney(t.getMoney());
        th.setExpectedDate(t.getExpectedDate());
        th.setCreateBy(t.getCreateBy());
        th.setCreateTime(DateTimeUtil.getSysTime());
        int count3 = tranHistoryDao.save(th);
        if (count3 != 1) {
            flag = false;
        }

        return flag;
    }

    @Override
    public List<Tran> getTranList() {
        return tranDao.getTranList();
    }

    @Override
    public Tran detail(String id) {
        return tranDao.detail(id);
    }

    @Override
    public List<TranHistory> getTranHistoryList(String tranId) {
        return tranHistoryDao.getTranHistoryList(tranId);
    }

    @Transactional
    @Override
    public boolean changeStage(Tran t) {
        boolean flag = true;

        //更改交易
        int count1 = tranDao.changeStage(t);
        if (count1 != 1) {
            flag = false;
        }

        //添加交易历史
        TranHistory th = new TranHistory();
        th.setId(UUIDUtil.getUUID());
        th.setStage(t.getStage());
        th.setTranId(t.getId());
        th.setMoney(t.getMoney());
        th.setCreateBy(t.getEditBy());
        th.setCreateTime(t.getEditTime());
        th.setExpectedDate(t.getExpectedDate());
        int count2 = tranHistoryDao.save(th);
        if (count2 != 1) {
            flag = false;
        }

        return flag;
    }

    @Override
    public Map<String, Object> getCharts() {
        //交易总数
        int total = tranDao.getTotal();

        //各个阶段的交易dataList
        List<Map<String, Object>> dataList = tranDao.getCharts();

        //封装到map中
        Map<String, Object> map = new HashMap<>();
        map.put("total", total);
        map.put("dataList", dataList);
        return map;
    }

    @Override
    public PageListVo<Tran> getPageList(Map<String,Object> map) {
        //符合条件的记录总条数
        int total = tranDao.getTotalByCondition(map);
        //符合条件的分页的数据
        List<Tran> dataList = tranDao.getTranListByCondition(map);
        //封装到PageListVo
        PageListVo<Tran> pageList = new PageListVo<>();
        pageList.setTotal(total);
        pageList.setDataList(dataList);

        return pageList;
    }

    @Override
    public Tran getTranById(String id) {
        return tranDao.getTranById(id);
    }

    @Transactional
    @Override
    public boolean update(Tran t) {
        return tranDao.update(t);
    }

}
