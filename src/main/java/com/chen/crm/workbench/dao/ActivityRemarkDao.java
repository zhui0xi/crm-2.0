package com.chen.crm.workbench.dao;

import com.chen.crm.workbench.domain.ActivityRemark;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ActivityRemarkDao {
    int getCountById(String[] ids);

    int delete(String[] ids);

    List<ActivityRemark> getRemarkList(String activityId);

    int deleteRemark(String id);

    int saveRemark(ActivityRemark ar);

    int updateRemark(ActivityRemark ar);

    int bund(@Param("id") String id, @Param("clueId") String clueId, @Param("aid") String aid);
}
