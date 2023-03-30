package com.chen.crm.workbench.dao;

import com.chen.crm.workbench.domain.Activity;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface ActivityDao {
    int save(Activity a);

    List<Activity> getActivityListByCondition(Map<String,Object> map);

    int getTotalByCondition(Map<String,Object> map);

    int delete(String[] ids);

    Activity getActivity(String id);

    int update(Activity a);

    Activity detail(String id);

    List<Activity> getActivityListByClueId(String clueId);

    List<Activity> getActivityListByNameAndNotByClueId(@Param("aname") String aname, @Param("clueId") String clueId);

    List<Activity> getActivityList();

    List<Activity> getActivityListByName(String aname);

}
