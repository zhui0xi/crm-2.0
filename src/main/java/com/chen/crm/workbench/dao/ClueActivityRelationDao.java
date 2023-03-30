package com.chen.crm.workbench.dao;

import java.util.List;

public interface ClueActivityRelationDao {

    List<String> getByClueId(String clueId);

    int delete(String clueId);
}
