package com.chen.crm.workbench.dao;

import java.util.List;

public interface ClueRemarkDao {

    List<String> getClueRemarkByClueId(String clueId);

    int delete(String clueId);
}
