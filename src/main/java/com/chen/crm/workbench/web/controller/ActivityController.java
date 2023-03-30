package com.chen.crm.workbench.web.controller;

import com.chen.crm.settings.domain.User;
import com.chen.crm.settings.service.UserService;
import com.chen.crm.utils.DateTimeUtil;
import com.chen.crm.utils.UUIDUtil;
import com.chen.crm.web.vo.PageListVo;
import com.chen.crm.workbench.domain.Activity;
import com.chen.crm.workbench.domain.ActivityRemark;
import com.chen.crm.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/workbench/activity")
public class ActivityController {

    @Autowired
    @Qualifier("activityServiceImpl")
    private ActivityService activityService;

    @Autowired
    @Qualifier("userServiceImpl")
    private UserService userService;

    @RequestMapping("/updateRemark")
    @ResponseBody
    private Object updateRemark(HttpServletRequest request, ActivityRemark ar) {

        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User) request.getSession().getAttribute("user")).getName();
        String editFlag = "1";

        ar.setEditTime(editTime);
        ar.setEditBy(editBy);
        ar.setEditFlag(editFlag);

        boolean flag = activityService.updateRemark(ar);

        /*Map<String, Object> map = new HashMap<>();
        map.put("success", flag);
        map.put("ar", ar);
        return map;*/

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);
        rMap.put("ar", ar);

        return rMap;
    }

    @RequestMapping("/saveRemark")
    @ResponseBody
    private Object saveRemark(HttpServletRequest request, HttpServletResponse response, ActivityRemark ar) {

        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User) request.getSession().getAttribute("user")).getName();
        String editFlag = "0";

        ar.setId(id);
        ar.setCreateTime(createTime);
        ar.setCreateBy(createBy);
        ar.setEditFlag(editFlag);

        boolean flag = activityService.saveRemark(ar);

        /*Map<String, Object> map = new HashMap<>();
        map.put("success", flag);
        map.put("ar", ar);
        return map;*/

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);
        rMap.put("ar", ar);

        return rMap;
    }

    @RequestMapping("/deleteRemark")
    @ResponseBody
    private Object deleteRemark(String id) {

        boolean flag = activityService.deleteRemark(id);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);

        return rMap;
    }

    @RequestMapping("/gerRemarkListById")
    @ResponseBody
    private Object gerRemarkListById(String activityId) {
        return activityService.getRemarkList(activityId);
    }

    @RequestMapping("/detail")
    private String detail(HttpServletRequest request, String id) {

        Activity a = activityService.detail(id);
        request.setAttribute("a", a);

        return "forward:/workbench/activity/detail.jsp";
    }

    @RequestMapping("/update")
    @ResponseBody
    private Object update(HttpServletRequest request, HttpServletResponse response, Activity a) {

        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User) request.getSession().getAttribute("user")).getName(); //编辑人

        a.setEditTime(editTime);
        a.setEditBy(editBy);

        boolean flag = activityService.update(a);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);

        return rMap;
    }

    @RequestMapping("/getUserAndActivity")
    @ResponseBody
    private Object getUserAndActivity(HttpServletRequest request, HttpServletResponse response, String id) {

        Map<String, Object> rMap = activityService.getUserAndActivity(id);
        rMap.put("uList", rMap.get("uList"));
        rMap.put("a", rMap.get("a"));

        return rMap;
    }

    @RequestMapping("/delete")
    @ResponseBody
    private Object delete(String[] id) {

        boolean flag = activityService.delete(id);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);

        return rMap;
    }

    @RequestMapping("/pageList")
    @ResponseBody
    private Object pageList(String pageNo, String pageSize, String name, String owner, String startDate, String endDate) {

        //计算要略过的记录数
        int pageNum = ((Integer.parseInt(pageNo)) - 1) * (Integer.parseInt(pageSize));

        Map<String, Object> map = new HashMap<>();
        map.put("pageNum", pageNum);
        map.put("pageSize", Integer.parseInt(pageSize));
        map.put("name", name);
        map.put("owner", owner);
        map.put("startDate", startDate);
        map.put("endDate", endDate);

        PageListVo<Activity> pageList = activityService.getPageList(map);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("total", pageList.getTotal());
        rMap.put("dataList", pageList.getDataList());

        return rMap;
    }

    @RequestMapping("/save")
    @ResponseBody
    private Object save(HttpServletRequest request, HttpServletResponse response, Activity a) {

        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User) request.getSession().getAttribute("user")).getName(); //创建人

        a.setId(id);
        a.setCreateTime(createTime);
        a.setCreateBy(createBy);

        boolean flag = activityService.save(a);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);

        return rMap;
    }

    @RequestMapping("/getUserList")
    @ResponseBody
    private Object getUserList() {
        return userService.getUserList();
    }


}
