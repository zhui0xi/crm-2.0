package com.chen.crm.workbench.service;

import com.chen.crm.web.vo.PageListVo;
import com.chen.crm.workbench.domain.Clue;
import com.chen.crm.workbench.domain.Tran;

import java.util.Map;

public interface ClueService {
    PageListVo<Clue> getPageList(Map<String, Object> map);

    boolean save(Clue c);

    Clue detail(String id);

    boolean remove(String carId);

    boolean convert(String clueId, Tran tran, String createBy);

    Clue getClueById(String id);

    boolean update(Clue c);

    boolean deleteByIds(String[] id);
}
