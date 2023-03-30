package com.chen.crm.settings.service;

import com.chen.crm.exception.UserLoginException;
import com.chen.crm.settings.domain.User;

import java.util.List;

public interface UserService {
    //User login(String loginAct, String loginPwd, String ip) throws UserLoginException;
    User login(String loginAct, String loginPwd) throws UserLoginException;

    List<User> getUserList();

    boolean updatePwd(String id, String newPwd);
}
