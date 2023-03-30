package com.chen.crm.settings.web.controller;

import com.chen.crm.settings.domain.User;
import com.chen.crm.settings.service.UserService;
import com.chen.crm.utils.MD5Util;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/settings/user")
public class UserController {

    @Autowired
    @Qualifier("userServiceImpl")
    private UserService userService;

    //登录
    @RequestMapping("/login")
    @ResponseBody
    private Object login(String loginAct, String loginPwd, HttpServletRequest request) {
        //给密码加密
        loginPwd = MD5Util.getMD5(loginPwd);
        //获取浏览器的ip地址
        //String ip = request.getRemoteAddr();

        Map<String, Object> rMap = new HashMap<>();
        try {
            //User user = userService.login(loginAct, loginPwd, ip);
            User user = userService.login(loginAct, loginPwd);

            //登录成功，把user放入session
            //返回 {"success":true}
            request.getSession().setAttribute("user", user);

            rMap.put("success", true);

            return rMap;
        } catch (Exception e) {
            e.printStackTrace(); //在后台输出错误信息

            //登录失败
            //返回 {"success":false,"msg":msg}
            String msg = e.getMessage(); //错误信息

            /*Map<String, Object> map = new HashMap<>();
            map.put("success", false);
            map.put("msg", msg);
            return map;*/

            rMap.put("success", false);
            rMap.put("msg", msg);

            return rMap;
        }

    }

    @RequestMapping("/updatePwd")
    @ResponseBody
    private Object updatePwd(String oldPwd, String newPwd, String confirmPwd, HttpServletRequest request) {

        //给原密码加密
        oldPwd = MD5Util.getMD5(oldPwd);
        //获取当前用户
        User u = (User) request.getSession().getAttribute("user");

        Map<String, Object> rMap = new HashMap<>();
        boolean flag = false;
        String msg = "";

        if (!u.getLoginPwd().equals(oldPwd)) {
            msg = "原密码输入错误";

            rMap.put("success", flag);
            rMap.put("msg", msg);

            return rMap;
        } else if (!newPwd.equals(confirmPwd)) {
            msg = "新密码与确认密码不一致";

            rMap.put("success", flag);
            rMap.put("msg", msg);

            return rMap;
        } else {
            //给新密码加密
            newPwd = MD5Util.getMD5(newPwd);
            try {
                flag = userService.updatePwd(u.getId(), newPwd);
            } catch (Exception e) {
                rMap.put("msg", e.getMessage());
            } finally {
                rMap.put("success", flag);

                return rMap;
            }
        }

    }

    @RequestMapping("/exit")
    @ResponseBody
    private void exit(HttpServletRequest request){
        //销毁session
        request.getSession().invalidate();
    }

}
