package com.chen.crm.workbench.service;

import com.chen.crm.web.vo.PageListVo;
import com.chen.crm.workbench.domain.Activity;
import com.chen.crm.workbench.domain.ActivityRemark;

import java.util.List;
import java.util.Map;

public interface ActivityService {

    boolean save(Activity a);

    PageListVo<Activity> getPageList(Map<String, Object> map);

    boolean delete(String[] ids);

    Map<String, Object> getUserAndActivity(String id);

    boolean update(Activity a);

    Activity detail(String id);

    List<ActivityRemark> getRemarkList(String activityId);

    boolean deleteRemark(String id);

    boolean saveRemark(ActivityRemark ar);

    boolean updateRemark(ActivityRemark ar);

    List<Activity> getActivityListByClueId(String clueId);

    List<Activity> getActivityListByNameAndNotByClueId(String aname, String clueId);

    boolean bund(String clueId, String[] ids);

    List<Activity> getActivityList();

    List<Activity> getActivityListByName(String aname);

    Object getActivityByTranId(String tranId);
}
