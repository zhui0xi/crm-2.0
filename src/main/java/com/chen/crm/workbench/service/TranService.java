package com.chen.crm.workbench.service;

import com.chen.crm.web.vo.PageListVo;
import com.chen.crm.workbench.domain.Tran;
import com.chen.crm.workbench.domain.TranHistory;

import java.util.List;
import java.util.Map;

public interface TranService {
    boolean save(Tran t, String customerName);

    List<Tran> getTranList();

    Tran detail(String id);

    List<TranHistory> getTranHistoryList(String tranId);

    boolean changeStage(Tran t);

    Map<String, Object> getCharts();

    PageListVo<Tran> getPageList(Map<String,Object> map);

    Tran getTranById(String id);

    boolean update(Tran t);
}
