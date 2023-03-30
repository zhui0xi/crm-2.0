package com.chen.crm.web.interception;

import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

//拦截恶意访问资源——动态资源
public class LoginInterception implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object o) throws Exception {

        //获取用户的session
        Object user = request.getSession().getAttribute("user");
        if (user != null) {
            return true;
        } else {
            //没有登录过，重定向到登录页面
            //用重定向是因为（除去资源文件）登录页的路径与访问的路径不同，所以不能用请求转发
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }

        return false;
    }

    @Override
    public void postHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o, ModelAndView modelAndView) throws Exception {
    }

    @Override
    public void afterCompletion(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o, Exception e) throws Exception {
    }

}
