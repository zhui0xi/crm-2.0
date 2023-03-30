package com.chen.crm.workbench.dao;

import com.chen.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueDao {

    int getTotalByCondition(Map<String, Object> map);

    List<Clue> getClueListByCondition(Map<String, Object> map);

    int save(Clue c);

    Clue getClueById(String id);

    int remove(String carId);

    Clue getClue(String id);

    int delete(String clueId);

    boolean update(Clue c);

    boolean deleteByIds(String[] id);
}
