<%@ page import="java.util.Map" %>
<%@ page import="com.chen.crm.workbench.domain.Tran" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";

    //可能性
    Tran t = (Tran) request.getAttribute("t");
    Map<String, String> pMap = (Map<String, String>) application.getAttribute("pMap");
    String possibility = pMap.get(t.getStage());
%>
<html>
<head>
    <base href="<%=basePath%>"/>

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

    <script type="text/javascript">
        $(function () {

            //时间控件
            $(".time1").datetimepicker({
                minView: "month",
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "down-left"
            });
            $(".time2").datetimepicker({
                minView: "month",
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "top-left"
            });

            //铺上数据
            showDataList();
            showCustomer("${param.id}");
            showActivity("${param.id}");
            showContacts("${param.id}");

            //给更新按钮绑定单击事件
            $("#updateBtn").click(function () {
                //参数
                var id = "${param.id}";
                var owner = $("#edit-owner").val();
                var money = $.trim($("#edit-money").val());
                var name = $.trim($("#edit-name").val());
                var expectedDate = $("#edit-expectedDate").val();
                var customerId = $.trim($("#edit-customerId").val());
                var stage = $("#edit-stage").val();
                var type = $("#edit-type").val();
                var source = $("#edit-source").val();
                var activityId = $("#edit-activityId").val();
                var contactsId = $("#edit-contactsId").val();
                var description = $.trim($("#edit-description").val());
                var contactSummary = $.trim($("#edit-contactSummary").val());
                var nextContactTime = $("#edit-nextContactTime").val();

                $.ajax({
                    url: "workbench/transaction/update.do",
                    data: {
                        "id": id,
                        "owner": owner,
                        "money": money,
                        "name": name,
                        "expectedDate": expectedDate,
                        "customerId": customerId,
                        "stage": stage,
                        "type": type,
                        "source": source,
                        "activityId": activityId,
                        "contactsId": contactsId,
                        "description": description,
                        "contactSummary": contactSummary,
                        "nextContactTime": nextContactTime
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        //data:{"success":boolean}
                        if (data.success) {
                            alert("交易更新成功");
                            window.location.href = "workbench/transaction/index.jsp";
                        } else {
                            alert("交易更新失败");
                        }
                    }
                })
            })

            //给取消按钮绑定单击事件
            $("#exitBtn").click(function () {
                window.location.href = "workbench/transaction/index.jsp";
            })

        })

        //铺上数据
        function showDataList() {
            //所有者下拉框
            $.ajax({
                url: "workbench/transaction/getUserList.do",
                dataType: "json",
                success: function (data) {
                    //data:{"uList":List<User>}
                    var uList = "";
                    $.each(data, function (i, n) {
                        if (n.id == "${requestScope.t.owner}") {
                            uList += "<option value='" + n.id + "' selected>" + n.name + "</option>";
                        } else {
                            uList += "<option value='" + n.id + "'>" + n.name + "</option>";
                        }
                    })
                    $("#edit-owner").html(uList);
                }
            })
            //可能性
            $("#edit-possibility").val(<%=possibility%>);
        }

        //给客户名称铺上数据
        function showCustomer(tranId) {
            $.ajax({
                url: "workbench/transaction/getCustomerByTranId.do",
                data: {
                    "tranId": tranId
                },
                dataType: "json",
                success: function (data) {
                    //data:{"cus",Customer}
                    $("#edit-customer").val(data.name);
                    $("#edit-customerId").val(data.id);
                }
            })
        }

        //给市场活动源铺上数据
        function showActivity(tranId) {
            $.ajax({
                url: "workbench/transaction/getActivityByTranId.do",
                data: {
                    "tranId": tranId
                },
                dataType: "json",
                success: function (data) {
                    //data:{"a",Activity}
                    $("#edit-activity").val(data.name);
                    $("#edit-activityId").val(data.id);
                }
            })
        }

        //给联系人名称铺上数据
        function showContacts(tranId) {
            $.ajax({
                url: "workbench/transaction/getContactsByTranId.do",
                data: {
                    "tranId": tranId
                },
                dataType: "json",
                success: function (data) {
                    //data:{"con",Contacts}
                    $("#edit-contacts").val(data.fullname);
                    $("#edit-contactsId").val(data.id);
                }
            })
        }
    </script>
</head>
<body>

<!-- 查找市场活动 -->
<div class="modal fade" id="findMarketActivity" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input type="text" class="form-control" style="width: 300px;"
                                   placeholder="请输入市场活动名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable4" class="table table-hover"
                       style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>发传单</td>
                        <td>2020-10-10</td>
                        <td>2020-10-20</td>
                        <td>zhangsan</td>
                    </tr>
                    <tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>发传单</td>
                        <td>2020-10-10</td>
                        <td>2020-10-20</td>
                        <td>zhangsan</td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 查找联系人 -->
<div class="modal fade" id="findContacts" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找联系人</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input type="text" class="form-control" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>邮箱</td>
                        <td>手机</td>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>李四</td>
                        <td>lisi@bjpowernode.com</td>
                        <td>12345678901</td>
                    </tr>
                    <tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>李四</td>
                        <td>lisi@bjpowernode.com</td>
                        <td>12345678901</td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>


<div style="position:  relative; left: 30px;">
    <h3>更新交易</h3>
    <div style="position: relative; top: -40px; left: 70%;">
        <button type="button" class="btn btn-primary" id="updateBtn">更新</button>
        <button type="button" class="btn btn-default" id="exitBtn">取消</button>
    </div>
    <hr style="position: relative; top: -40px;">
</div>
<form class="form-horizontal" role="form" style="position: relative; top: -30px;">
    <div class="form-group">
        <label for="edit-owner" class="col-sm-2 control-label">所有者<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="edit-owner">

            </select>
        </div>
        <label for="edit-money" class="col-sm-2 control-label">金额</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="edit-money" value="${requestScope.t.money}">
        </div>
    </div>

    <div class="form-group">
        <label for="edit-name" class="col-sm-2 control-label">名称<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="edit-name" value="${requestScope.t.name}">
        </div>
        <label for="edit-expectedDate" class="col-sm-2 control-label">预计成交日期<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control time1" id="edit-expectedDate" value="${requestScope.t.expectedDate}"
                   readonly>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-customer" class="col-sm-2 control-label">客户名称<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" placeholder="支持自动补全，输入客户不存在则新建" id="edit-customer">
            <input type="hidden" id="edit-customerId">
        </div>
        <label for="edit-stage" class="col-sm-2 control-label">阶段<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="edit-stage">
                <c:forEach items="${applicationScope.stage}" var="s">
                    <c:if test="${s.text eq t.stage}">
                        <option selected>${s.text}</option>
                    </c:if>
                    <c:if test="${s.text ne t.stage}">
                        <option>${s.text}</option>
                    </c:if>
                </c:forEach>
            </select>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-type" class="col-sm-2 control-label">类型</label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="edit-type">
                <option></option>
                <c:forEach items="${applicationScope.transactionType}" var="tt">
                    <c:if test="${tt.text eq t.type}">
                        <option selected>${tt.text}</option>
                    </c:if>
                    <c:if test="${tt.text ne t.type}">
                        <option>${tt.text}</option>
                    </c:if>
                </c:forEach>
            </select>
        </div>
        <label for="edit-possibility" class="col-sm-2 control-label">可能性</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="edit-possibility">
        </div>
    </div>

    <div class="form-group">
        <label for="edit-source" class="col-sm-2 control-label">来源</label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="edit-source">
                <option></option>
                <c:forEach items="${applicationScope.source}" var="s">
                    <c:if test="${s.text eq t.source}">
                        <option selected>${s.text}</option>
                    </c:if>
                    <c:if test="${s.text ne t.source}">
                        <option>${s.text}</option>
                    </c:if>
                </c:forEach>
            </select>
        </div>
        <label for="edit-activity" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);"
                                                                                      data-toggle="modal"
                                                                                      data-target="#findMarketActivity"><span
                class="glyphicon glyphicon-search"></span></a></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="edit-activity" readonly>
            <input type="hidden" id="edit-activityId"/>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-contacts" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);"
                                                                                      data-toggle="modal"
                                                                                      data-target="#findContacts"><span
                class="glyphicon glyphicon-search"></span></a></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="edit-contacts" readonly>
            <input type="hidden" id="edit-contactsId">
        </div>
    </div>

    <div class="form-group">
        <label for="edit-description" class="col-sm-2 control-label">描述</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea class="form-control" rows="3" id="edit-description">${requestScope.t.description}</textarea>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea class="form-control" rows="3" id="edit-contactSummary">${requestScope.t.contactSummary}</textarea>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control time2" id="edit-nextContactTime"
                   value="${requestScope.t.nextContactTime}" readonly>
        </div>
    </div>

</form>
</body>
</html>