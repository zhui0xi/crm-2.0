package com.chen.crm.settings.dao;

import com.chen.crm.settings.domain.User;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface UserDao {

    User login(@Param("loginAct") String loginAct, @Param("loginPwd") String loginPwd);

    List<User> getUserList();

    boolean updatePwd(@Param("id") String id, @Param("loginPwd") String newPwd);
}
