package com.chen.crm.web.listener;

import com.chen.crm.settings.domain.DicValue;
import com.chen.crm.settings.service.DicService;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.util.*;

@WebListener
public class SysInitListener implements ServletContextListener {
    //服务器启动时
    @Override
    public void contextInitialized(ServletContextEvent event) {
        ServletContext application = event.getServletContext();

        ApplicationContext ac = new ClassPathXmlApplicationContext("classpath:applicationContext.xml");
        DicService dicService = (DicService) ac.getBean("dicServiceImpl");

        //返回值应为 map{key,value} key:code,value:List<DicValue>
        Map<String, List<DicValue>> map = dicService.getDicValue();
        Set keySet = map.keySet();
        for (Object key:keySet){
            application.setAttribute((String)key,map.get(key));
        }

        //-----------------------------------------------------------------------
        //处理完数据字典之后，处理Stage2Possibility.properties文件 2表示to
        Map<String,String> pMap = new HashMap<>();
        ResourceBundle rb = ResourceBundle.getBundle("Stage2Possibility");

        Enumeration<String> e = rb.getKeys();

        while(e.hasMoreElements()){
            //阶段
            String key = e.nextElement();
            //可能性
            String value = rb.getString(key);

            pMap.put(key,value);
        }

        //将pMap保存再服务器缓存中
        application.setAttribute("pMap",pMap);
    }

    @Override
    public void contextDestroyed(ServletContextEvent servletContextEvent) {
    }
}
