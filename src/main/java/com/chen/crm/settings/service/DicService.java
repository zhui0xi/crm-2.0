package com.chen.crm.settings.service;

import com.chen.crm.settings.domain.DicValue;

import java.util.List;
import java.util.Map;

public interface DicService {
    Map<String, List<DicValue>> getDicValue();
}
