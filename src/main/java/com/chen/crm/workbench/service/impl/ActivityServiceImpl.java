package com.chen.crm.workbench.service.impl;

import com.chen.crm.settings.dao.UserDao;
import com.chen.crm.settings.domain.User;
import com.chen.crm.utils.UUIDUtil;
import com.chen.crm.web.vo.PageListVo;
import com.chen.crm.workbench.dao.ActivityDao;
import com.chen.crm.workbench.dao.ActivityRemarkDao;
import com.chen.crm.workbench.dao.TranDao;
import com.chen.crm.workbench.domain.Activity;
import com.chen.crm.workbench.domain.ActivityRemark;
import com.chen.crm.workbench.domain.Tran;
import com.chen.crm.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ActivityServiceImpl implements ActivityService {
    @Autowired
    private ActivityDao activityDao;
    @Autowired
    private ActivityRemarkDao activityRemarkDao;

    @Autowired
    private UserDao userDao;

    @Autowired
    private TranDao tranDao;

    @Transactional
    @Override
    public boolean save(Activity a) {
        int count = activityDao.save(a);

        if (count != 1) {
            return false;
        }

        return true;
    }

    @Override
    public PageListVo<Activity> getPageList(Map<String, Object> map) {
        //获取记录总条数
        int total = activityDao.getTotalByCondition(map);
        //获取dataList
        List<Activity> dataList = activityDao.getActivityListByCondition(map);
        //封装到PageListVo中
        PageListVo<Activity> vo = new PageListVo<>();
        vo.setTotal(total);
        vo.setDataList(dataList);
        return vo;
    }

    @Transactional
    @Override
    public boolean delete(String[] ids) {
        boolean flag = true;

        //查询是否有与市场活动表相关联的备注 市场活动备注表
        int count1 = activityRemarkDao.getCountById(ids);

        //先删除备注
        int count2 = activityRemarkDao.delete(ids);

        //在删除市场活动
        if (count1 != count2) {
            flag = false;
        } else {
            int count3 = activityDao.delete(ids);
            if (count3 != ids.length) {
                flag = false;
            }
        }

        return flag;
    }

    @Override
    public Map<String, Object> getUserAndActivity(String id) {
        //取uList List<User>
        List<User> uList = userDao.getUserList();
        //取a Activity
        Activity a = activityDao.getActivity(id);
        //封装成Map
        Map<String, Object> map = new HashMap<>();
        map.put("uList", uList);
        map.put("a", a);
        return map;
    }

    @Transactional
    @Override
    public boolean update(Activity a) {
        int count = activityDao.update(a);

        if (count != 1) {
            return false;
        }

        return true;
    }

    @Override
    public Activity detail(String id) {
        return activityDao.detail(id);
    }

    @Override
    public List<ActivityRemark> getRemarkList(String activityId) {
        return activityRemarkDao.getRemarkList(activityId);
    }

    @Transactional
    @Override
    public boolean deleteRemark(String id) {
        boolean flag = true;

        int count = activityRemarkDao.deleteRemark(id);

        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    @Transactional
    @Override
    public boolean saveRemark(ActivityRemark ar) {
        boolean flag = true;

        int count = activityRemarkDao.saveRemark(ar);

        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    @Transactional
    @Override
    public boolean updateRemark(ActivityRemark ar) {
        boolean flag = true;

        int count = activityRemarkDao.updateRemark(ar);

        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    @Override
    public List<Activity> getActivityListByClueId(String clueId) {
        return activityDao.getActivityListByClueId(clueId);
    }

    @Override
    public List<Activity> getActivityListByNameAndNotByClueId(String aname, String clueId) {
        return activityDao.getActivityListByNameAndNotByClueId(aname, clueId);
    }

    @Transactional
    @Override
    public boolean bund(String clueId, String[] ids) {
        boolean flag = true;

        for (String aid : ids) {
            String id = UUIDUtil.getUUID();
            int count = activityRemarkDao.bund(id, clueId, aid);
            if (count != 1) {
                flag = false;
            }
        }

        return flag;
    }

    @Override
    public List<Activity> getActivityList() {
        return activityDao.getActivityList();
    }

    @Override
    public List<Activity> getActivityListByName(String aname) {
        return activityDao.getActivityListByName(aname);
    }

    @Override
    public Object getActivityByTranId(String tranId) {

        Tran t = tranDao.getTran(tranId);

        return activityDao.getActivity(t.getActivityId());

    }

}
