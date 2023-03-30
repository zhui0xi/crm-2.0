package com.chen.crm.workbench.dao;

import com.chen.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranDao {

    int save(Tran tran);

    List<Tran> getTranList();

    Tran detail(String id);

    int changeStage(Tran t);

    int getTotal();

    List<Map<String, Object>> getCharts();

    int getTotalByCondition(Map<String,Object> map);

    List<Tran> getTranListByCondition(Map<String,Object> map);

    Tran getTranById(String id);

    boolean update(Tran t);

    Tran getTran(String tranId);
}
