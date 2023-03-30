package com.chen.crm.web.filter;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

//防止恶意访问资源——JSP、HTML
public class JSPAndHTMLFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {

    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getServletPath();
        if ("/login.jsp".equals(path) || "/index.html".equals(path)) {
            //放行
            chain.doFilter(req, res);
        } else {
            Object user = request.getSession().getAttribute("user");
            if (user != null) {
                //放行
                chain.doFilter(req, res);
            } else {
                //恶意访问资源，重定向至登录页面
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
        }
    }

    @Override
    public void destroy() {

    }
}
