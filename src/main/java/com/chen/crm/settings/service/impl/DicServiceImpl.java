package com.chen.crm.settings.service.impl;

import com.chen.crm.settings.dao.DicTypeDao;
import com.chen.crm.settings.dao.DicValueDao;
import com.chen.crm.settings.domain.DicType;
import com.chen.crm.settings.domain.DicValue;
import com.chen.crm.settings.service.DicService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DicServiceImpl implements DicService {
    @Autowired
    private DicTypeDao dicTypeDao;
    @Autowired
    private DicValueDao dicValueDao;

    @Override
    public Map<String, List<DicValue>> getDicValue() {
        Map<String, List<DicValue>> map = new HashMap<>();

        //先查询所有的数据字典的类型
        List<DicType> typeList = dicTypeDao.getType();

        //按照类型分别查询数据字典的值
        for (DicType type : typeList) {
            List<DicValue> dicValueList = dicValueDao.getValueByCode(type.getCode());
            map.put(type.getCode(), dicValueList);
        }

        return map;
    }
}
