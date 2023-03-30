package com.chen.crm.workbench.web.controller;

import com.chen.crm.settings.domain.User;
import com.chen.crm.settings.service.UserService;
import com.chen.crm.utils.DateTimeUtil;
import com.chen.crm.utils.UUIDUtil;
import com.chen.crm.web.vo.PageListVo;
import com.chen.crm.workbench.domain.Clue;
import com.chen.crm.workbench.domain.Tran;
import com.chen.crm.workbench.service.ActivityService;
import com.chen.crm.workbench.service.ClueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/workbench/clue")
public class ClueController {

    @Autowired
    @Qualifier("clueServiceImpl")
    private ClueService clueService;

    @Autowired
    @Qualifier("activityServiceImpl")
    private ActivityService activityService;

    @Autowired
    @Qualifier("userServiceImpl")
    private UserService userService;

    @RequestMapping("/convert")
    private String convert(HttpServletRequest request, String clueId, String flag) throws IOException {
        //flag:是否需要创建交易的标识，true：表示需要创建

        String createBy = ((User) request.getSession().getAttribute("user")).getCreateBy();

        //用来标识是否需要创建交易
        Tran tran = null;
        if ("true".equals(flag)) {
            String id = UUIDUtil.getUUID();
            String createTime = DateTimeUtil.getSysTime();

            tran = new Tran();
            tran.setId(id);
            tran.setCreateBy(createBy);
            tran.setCreateTime(createTime);
        }

        clueService.convert(clueId, tran, createBy); //因为tran对象有可能是null，所以要传一个createBy

        return "redirect:/workbench/clue/index.jsp";
    }

    @RequestMapping("/getActivityListByName")
    @ResponseBody
    private Object getActivityListByName(String aname) {
        return activityService.getActivityListByName(aname);
    }

    @RequestMapping("/getActivityList")
    @ResponseBody
    private Object getActivityList(HttpServletRequest request, HttpServletResponse response) {
        return activityService.getActivityList();
    }

    @RequestMapping("/bund")
    @ResponseBody
    private Object bund(String clueId, String[] id) {

        boolean flag = activityService.bund(clueId, id);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);

        return rMap;
    }

    @RequestMapping("/getActivityListByNameAndNotByClueId")
    @ResponseBody
    private Object getActivityListByNameAndNotByClueId(String aname, String clueId) {
        return activityService.getActivityListByNameAndNotByClueId(aname, clueId);
    }

    @RequestMapping("/remove")
    @ResponseBody
    private Object remove(String carId) {

        boolean flag = clueService.remove(carId);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);

        return rMap;
    }

    @RequestMapping("/getActivityListByClueId")
    @ResponseBody
    private Object getActivityListByClueId(String clueId) {
        return activityService.getActivityListByClueId(clueId);
    }

    @RequestMapping("/detail")
    private String detail(HttpServletRequest request, String id) throws ServletException, IOException {

        Clue c = clueService.detail(id);
        request.setAttribute("c", c);

        return "forward:/workbench/clue/detail.jsp";
    }

    @RequestMapping("/save")
    @ResponseBody
    private Object save(HttpServletRequest request, Clue c) {

        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User) request.getSession().getAttribute("user")).getName();

        c.setId(id);
        c.setCreateTime(createTime);
        c.setCreateBy(createBy);

        boolean flag = clueService.save(c);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);

        return rMap;
    }

    @RequestMapping("/pageList")
    @ResponseBody
    private Object pageList(String pageNo, String pageSize, String fullname, String company, String phone, String source, String owner, String mphone, String state) {

        //计算要略过的记录数
        int pageNum = ((Integer.parseInt(pageNo)) - 1) * (Integer.parseInt(pageSize));

        Map<String, Object> map = new HashMap<>();
        map.put("pageNum", pageNum);
        map.put("pageSize", Integer.parseInt(pageSize));
        map.put("company", company);
        map.put("phone", phone);
        map.put("source", source);
        map.put("owner", owner);
        map.put("mphone", mphone);
        map.put("state", state);
        map.put("fullname", fullname);

        PageListVo<Clue> pageList = clueService.getPageList(map);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("total", pageList.getTotal());
        rMap.put("dataList", pageList.getDataList());

        return rMap;
    }

    @RequestMapping("/getUserList")
    @ResponseBody
    private Object getUserList() {
        return userService.getUserList();
    }

    @RequestMapping("/getUserAndClue")
    @ResponseBody
    private Object getUserAndClue(String id) {

        //获取全部的所有者
        List<User> uList = userService.getUserList();

        //根据id获取线索
        Clue c = clueService.getClueById(id);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("uList", uList);
        rMap.put("c", c);

        return rMap;
    }

    @RequestMapping("/update")
    @ResponseBody
    private Object update(Clue c, HttpServletRequest request) {

        //编辑时间
        c.setEditTime(DateTimeUtil.getSysTime());
        //编辑人
        c.setEditBy(((User) request.getSession().getAttribute("user")).getName());

        boolean flag = clueService.update(c);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);

        return rMap;
    }

    @RequestMapping("/deleteByIds")
    @ResponseBody
    private Object deleteByIds(String[] id) {

        boolean flag = clueService.deleteByIds(id);

        Map<String, Object> rMap = new HashMap<>();
        rMap.put("success", flag);

        return rMap;
    }

}
