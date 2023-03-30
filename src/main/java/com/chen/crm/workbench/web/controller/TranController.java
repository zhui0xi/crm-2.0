package com.chen.crm.workbench.web.controller;

import com.chen.crm.settings.domain.User;
import com.chen.crm.settings.service.UserService;
import com.chen.crm.utils.DateTimeUtil;
import com.chen.crm.utils.UUIDUtil;
import com.chen.crm.web.vo.PageListVo;
import com.chen.crm.workbench.domain.Tran;
import com.chen.crm.workbench.domain.TranHistory;
import com.chen.crm.workbench.service.ActivityService;
import com.chen.crm.workbench.service.ContactsService;
import com.chen.crm.workbench.service.CustomerService;
import com.chen.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/workbench/transaction")
public class TranController {

    @Autowired
    @Qualifier("tranServiceImpl")
    private TranService tranService;

    @Autowired
    @Qualifier("customerServiceImpl")
    private CustomerService customerService;

    @Autowired
    @Qualifier("userServiceImpl")
    private UserService userService;

    @Autowired
    @Qualifier("activityServiceImpl")
    private ActivityService activityService;

    @Autowired
    @Qualifier("contactsServiceImpl")
    private ContactsService contactsService;

    @RequestMapping("/getCharts")
    @ResponseBody
    private Object getCharts() {

        //如果这种返回值{"total":int,"dataList":[{ value: xx, name: xx },]}
        //用得频繁，可以封装成一个vo类
        Map<String, Object> rMap = tranService.getCharts();
        rMap.put("total", rMap.get("total"));
        rMap.put("dataList", rMap.get("dataList"));

        return rMap;
    }

    @RequestMapping("/changeStage")
    @ResponseBody
    private Object changeStage(HttpServletRequest request, Tran t) {

        String editBy = ((User) request.getSession().getAttribute("user")).getName();
        String editTime = DateTimeUtil.getSysTime();

        t.setEditBy(editBy);
        t.setEditTime(editTime);

        boolean flag = tranService.changeStage(t);

        //处理可能性
        Map<String, String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pMap");
        t.setPossibility(pMap.get(t.getStage()));

        /*Map<String, Object> map = new HashMap<>();
        map.put("success", flag);
        map.put("t", t);
        return map;*/

        /*JSONObject obj = new JSONObject();
        obj.put("success", flag);
        obj.put("t", t);
        return obj.toString();*/

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);
        rMap.put("t", t);

        return rMap;
    }

    @RequestMapping("/getTranHistoryList")
    @ResponseBody
    private Object getTranHistoryList(HttpServletRequest request, String tranId) {

        List<TranHistory> thList = tranService.getTranHistoryList(tranId);

        //增添属性————可能性
        Map<String, String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pMap");
        for (TranHistory th : thList) {
            String possibility = pMap.get(th.getStage());
            th.setPossibility(possibility);
        }

        return thList;
    }

    @RequestMapping("/detail")
    private String detail(HttpServletRequest request, String id) throws ServletException, IOException {

        Tran t = tranService.detail(id);

        //增添属性————可能性
        String stage = t.getStage();
        Map<String, String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pMap");
        String possibility = pMap.get(stage);
        t.setPossibility(possibility);

        request.setAttribute("t", t);

        return "/workbench/transaction/detail.jsp";
    }

    @RequestMapping("/getTranList")
    @ResponseBody
    private Object getTranList() {
        return tranService.getTranList();
    }

    @RequestMapping("save")
    private String save(HttpServletRequest request, Tran t, String customerName) {

        String id = UUIDUtil.getUUID();
        String createBy = ((User) request.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();

        t.setId(id);
        t.setCreateBy(createBy);
        t.setCreateTime(createTime);

        boolean flag = tranService.save(t, customerName);

        if (flag) {
            return "redirect:/workbench/transaction/index.jsp";
        } else {
            return "/workbench/transaction/save.jsp";
        }

    }

    @RequestMapping("/getCustomerName")
    @ResponseBody
    private Object getCustomerName(String name) {
        return customerService.getCustomerName(name);
    }

    @RequestMapping("/add")
    private String add(HttpServletRequest request) throws ServletException, IOException {
        List<User> uList = userService.getUserList();

        request.setAttribute("uList", uList);

        return "forward:/workbench/transaction/save.jsp";
    }

    @RequestMapping("/pageList")
    @ResponseBody
    private Object pageList(Tran t, String pageNo, String pageSize) {

        //计算要略过的记录条数
        int pageNum = (Integer.parseInt(pageNo) - 1) * Integer.parseInt(pageSize);

        Map<String, Object> map = new HashMap<>();
        map.put("pageNum", pageNum);
        map.put("pageSize", Integer.parseInt(pageSize));
        map.put("owner", t.getOwner());
        map.put("name", t.getName());
        map.put("customerId", t.getCustomerId());
        map.put("stage", t.getStage());
        map.put("type", t.getType());
        map.put("source", t.getSource());
        map.put("contactsId", t.getContactsId());

        PageListVo<Tran> pageList = tranService.getPageList(map);

        return pageList;
    }

    @RequestMapping("/getTranById")
    private String getTranById(String id, HttpServletRequest request) {

        Tran t = tranService.getTranById(id);

        //把交易存储在请求作用域
        request.setAttribute("t", t);

        return "/workbench/transaction/edit.jsp";
    }

    @RequestMapping("/getUserList")
    @ResponseBody
    private Object getUserList() {
        return userService.getUserList();
    }

    @RequestMapping("/update")
    @ResponseBody
    private Object update(Tran t, HttpServletRequest request) {

        User u = (User) request.getSession().getAttribute("user");

        t.setEditTime(DateTimeUtil.getSysTime());
        t.setEditBy(u.getName());

        boolean flag = tranService.update(t);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);

        return rMap;
    }

    @RequestMapping("/getActivityByTranId")
    @ResponseBody
    private Object getActivityByTranId(String tranId) {
        return activityService.getActivityByTranId(tranId);
    }

    @RequestMapping("/getCustomerByTranId")
    @ResponseBody
    private Object getCustomerByTranId(String tranId) {
        return customerService.getCustomerByTranId(tranId);
    }

    @RequestMapping("/getContactsByTranId")
    @ResponseBody
    private Object getContactsByTranId(String tranId) {

        return contactsService.getContactsByTranId(tranId);

    }

}
