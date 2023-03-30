package com.chen.crm.settings.service.impl;

import com.chen.crm.settings.dao.UserDao;
import com.chen.crm.settings.domain.User;
import com.chen.crm.settings.service.UserService;
import com.chen.crm.utils.DateTimeUtil;
import org.apache.ibatis.logging.LogException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserServiceImpl implements UserService {

    //取出userDao对象
    @Autowired
    private UserDao userDao;

    //登录
    /*@Override
    public User login(String loginAct, String loginPwd, String ip) {
        User user = userDao.login(loginAct, loginPwd);

        if (user == null) {
            throw new LogException("账号密码错误");
        }

        //验证失效时间
        String nowTime = DateTimeUtil.getSysTime();
        if (nowTime.compareTo(user.getExpireTime()) > 0) {
            throw new LogException("账号已失效");
        }

        //验证锁定状态
        if ("0".equals(user.getLockState())) {
            throw new LogException("账号已锁定");
        }

        //验证浏览器的IP地址
        if (!user.getAllowIps().contains(ip)) {
            throw new LogException("ip受限");
        }

        return user;
    }*/

    @Override
    public User login(String loginAct, String loginPwd) {
        User user = userDao.login(loginAct, loginPwd);

        if (user == null) {
            throw new LogException("账号密码错误");
        }

        //验证失效时间
        String nowTime = DateTimeUtil.getSysTime();
        if (nowTime.compareTo(user.getExpireTime()) > 0) {
            throw new LogException("账号已失效");
        }

        //验证锁定状态
        if ("0".equals(user.getLockState())) {
            throw new LogException("账号已锁定");
        }

        return user;
    }

    @Override
    public List<User> getUserList() {
        return userDao.getUserList();
    }

    @Override
    public boolean updatePwd(String id, String newPwd) {
        return userDao.updatePwd(id,newPwd);
    }
}
