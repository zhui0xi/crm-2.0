<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<html>
<head>
    <base href="<%=basePath%>"/>
    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

    <script type="text/javascript">

        $(function () {
            pageList(1, 2);

            //时间控件
            $(".time").datetimepicker({
                minView: "month",
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "bottom-left"
            });

            //给创建按钮绑定单击事件
            $("#addBtn").click(function () {
                //所有者下拉框
                $.ajax({
                    url: "workbench/activity/getUserList.do",
                    dataType: "json",
                    type: "get",
                    success: function (data) {
                        //data {"uList":List<User>}
                        //所有者下拉框
                        var userList = "<option></option>";
                        $.each(data, function (i, n) {
                            userList += "<option value='" + n.id + "'>" + n.name + "</option>";
                        })
                        $("#create-marketActivityOwner").html(userList);

                        //所有者下拉框默认选中当前登录的用户
                        $("#create-marketActivityOwner").val("${sessionScope.user.id}");
                    }
                })

                //打开模态窗口
                $("#createActivityModal").modal("show");
            })

            //给创建的模态窗口的保存按钮绑定单击事件
            $("#saveBtn").click(function () {
                $.ajax({
                    url: "workbench/activity/save.do",
                    data: {
                        "owner": $.trim($("#create-marketActivityOwner").val()),
                        "name": $.trim($("#create-marketActivityName").val()),
                        "startDate": $("#create-startTime").val(),
                        "endDate": $("#create-endTime").val(),
                        "cost": $.trim($("#create-cost").val()),
                        "description": $.trim($("#create-describe").val())
                    },
                    dataType: "json",
                    success: function (data) {
                        if (data.success) {
                            //局部刷新市场活动
                            pageList(1, $("#activityPage").bs_pagination("getOption", "rowsPerPage"));

                            //重置添加表单
                            $("#addForm")[0].reset();

                            //关闭添加操作的模态窗口
                            $("#createActivityModal").modal("hide");
                        } else {
                            alert("添加失败");
                        }
                    }
                })
            })

            //给修改按钮绑定单击事件
            $("#editBtn").click(function () {
                var $xz = $("input[name='xz']:checked");
                if ($xz.length == 0) {
                    alert("请选择要修改的市场活动")
                } else if ($xz.length > 1) {
                    alert("抱歉，只能选择一场市场活动修改")
                } else {
                    //到这里，$xz只能是1了
                    var id = $xz.val();

                    //去后端拿数据铺到对应的框
                    $.ajax({
                        url: "workbench/activity/getUserAndActivity.do",
                        data: {
                            "id": id
                        },
                        dataType: "json",
                        type: "get",
                        success: function (data) {
                            //data {"uList":List<User>,"a":Activity}

                            //所有者下拉框
                            var uList = "<option></option>";
                            $.each(data.uList, function (i, n) {
                                if (n.id == data.a.owner) {
                                    uList += "<option value='" + n.id + "' selected>" + n.name + "</option>";
                                } else {
                                    uList += "<option value='" + n.id + "'>" + n.name + "</option>";
                                }
                            })
                            $("#edit-marketActivityOwner").html(uList);

                            //市场活动
                            $("#edit-id").val(data.a.id);
                            $("#edit-marketActivityName").val(data.a.name);
                            $("#edit-startTime").val(data.a.startDate);
                            $("#edit-endTime").val(data.a.endDate);
                            $("#edit-cost").val(data.a.cost);
                            $("#edit-describe").val(data.a.description);
                        }
                    })

                    //打开模态窗口
                    $("#editActivityModal").modal("show");
                }

            })

            //给修改的模态窗口的更新按钮绑定单击事件
            $("#updateBtn").click(function () {
                $.ajax({
                    url: "workbench/activity/update.do",
                    data: {
                        "id": $("#edit-id").val(),
                        "owner": $("#edit-marketActivityOwner").val(),
                        "name": $.trim($("#edit-marketActivityName").val()),
                        "startDate": $("#edit-startTime").val(),
                        "endDate": $("#edit-endTime").val(),
                        "cost": $.trim($("#edit-cost").val()),
                        "description": $.trim($("#edit-describe").val())
                    },
                    dataType: "json",
                    success: function (data) {
                        if (data.success) {
                            //局部刷新市场活动
                            //$("#activityPage").bs_pagination("getOption","currentPage")：操作后停留在当前页
                            //$("#activityPage").bs_pagination("getOption","rowsPerPage")：操作后维持已经设置好的每页展现的记录数
                            pageList($("#activityPage").bs_pagination("getOption", "currentPage"),
                                $("#activityPage").bs_pagination("getOption", "rowsPerPage"));

                            //关闭修改操作的模态窗口
                            $("#editActivityModal").modal("hide");
                            alert("市场活动更新成功");
                        } else {
                            alert("市场活动更新失败");
                        }
                    }
                })
            })

            //给查询按钮绑定单击事件
            $("#findBtn").click(function () {
                $("#hidden-name").val($.trim($("#find-name").val()));
                $("#hidden-owner").val($.trim($("#find-owner").val()));
                $("#hidden-startDate").val($("#find-startDate").val());
                $("#hidden-endDate").val($("#find-endDate").val());

                pageList(1, $("#activityPage").bs_pagination("getOption", "rowsPerPage"));
            })

            //给当前窗口绑定按下键盘事件
            $(window).keydown(function (event){
                //按下回车键
                if(event.keyCode == 13){
                    $("#hidden-name").val($.trim($("#find-name").val()));
                    $("#hidden-owner").val($.trim($("#find-owner").val()));
                    $("#hidden-startDate").val($("#find-startDate").val());
                    $("#hidden-endDate").val($("#find-endDate").val());

                    pageList(1, $("#activityPage").bs_pagination("getOption", "rowsPerPage"));
                }
            })

            //给全选的复选框绑定事件
            $("#qx").click(function () {
                $("input[name='xz']").prop("checked",this.checked);
            })

            /*
                动态生成的元素，是不能以普通绑定事件的形式来进行操作的

                要以on方法的形式来绑定事件
                语法：
                    $(需要绑定的元素的不是动态生成的外层元素).on(绑定事件的名称,需要绑定的元素的jquery对象,function(){})
             */
            $("#activityBody").on("click", $("input[name='xz']"), function () {
                $("#qx").prop("checked", $("input[name='xz']").length == $("input[name='xz']:checked").length);
            })

            //给删除按钮绑定单击事件
            $("#deleteBtn").click(function () {
                var $xz = $("input[name='xz']:checked");

                if ($xz.length == 0) {
                    alert("请选择需要删除的记录");
                } else {
                    if (confirm("您确定要删除所选的市场活动吗？")) {
                        //拼凑参数
                        //id=?&id=?...
                        //这种要用传统的拼凑方式，不能用json，因为json的key值是唯一的
                        var param = "";
                        for (var i = 0; i < $xz.length; i++) {
                            param += "id=" + $($xz[i]).val();

                            //不能最后一个元素，后面要加上一个&
                            if (i < $xz.length - 1) {
                                param += "&";
                            }
                        }

                        $.ajax({
                            url: "workbench/activity/delete.do",
                            data: param, //传统的拼凑参数的方式
                            dataType: "json",
                            type: "post",
                            success: function (data) {
                                //data {"success":true/false}
                                if (data.success) {
                                    //刷新页面
                                    pageList($("#activityPage").bs_pagination("getOption", "currentPage"),
                                        $("#activityPage").bs_pagination("getOption", "rowsPerPage"));
                                } else {
                                    alert("市场活动删除失败");
                                }
                            }
                        })
                    }
                }
            })

        });

        /*分页
        1.点击市场活动超链接
        2.保存，修改，删除
        3.查询
        4.页码
        pageNo:当前页码*/
        function pageList(pageNo, pageSize) {
            //每次分页查询(刷新页面)把全选复选框的钩给干掉
            $("#qx").prop("checked", false);

            $("#find-name").val($.trim($("#hidden-name").val()));
            $("#find-owner").val($.trim($("#hidden-owner").val()));
            $("#find-startDate").val($("#hidden-startDate").val());
            $("#find-endDate").val($("#hidden-endDate").val());

            $.ajax({
                url: "workbench/activity/pageList.do",
                data: {
                    "pageNo": pageNo,
                    "pageSize": pageSize,
                    "name": $.trim($("#find-name").val()),
                    "owner": $.trim($("#find-owner").val()),
                    "startDate": $("#find-startDate").val(),
                    "endDate": $("#find-endDate").val()
                },
                dataType: "json",
                success: function (data) {
                    //data {"total":int,"dataList":"[{},{},...]"}
                    var activityBody = "";
                    $.each(data.dataList, function (i, n) {
                        activityBody += '<tr class="active">';
                        activityBody += '<td><input type="checkbox" name="xz" value="' + n.id + '"/></td>';
                        activityBody += '<td><a style="text-decoration: none; cursor: pointer;"';
                        activityBody += 'onclick="window.location.href=\'workbench/activity/detail.do?id=' + n.id + '\'">' + n.name + '</a></td>';
                        activityBody += '<td>' + n.owner + '</td>';
                        activityBody += '<td>' + n.startDate + '</td>';
                        activityBody += '<td>' + n.endDate + '</td></tr>';
                    })
                    $("#activityBody").html(activityBody);

                    //计算总页数
                    var totalPages = data.total % pageSize == 0 ? data.total / pageSize : (data.total / pageSize) + 1;

                    //处理完数据之后，结合分页查询，对前端展现分页信息
                    $("#activityPage").bs_pagination({
                        currentPage: pageNo, //页码
                        rowsPerPage: pageSize, //每页显示的记录条数
                        maxRowsPerPage: 20, //每页最多显示的记录条数
                        totalPages: totalPages, //总页数
                        totalRows: data.total, //总记录条数

                        visiblePageLinks: 5, //显示几个卡片

                        showGoToPage: true,
                        showRowsPerPage: true,
                        showRowsInfo: true,
                        showRowsDefaultInfo: true,

                        onChangePage: function (event, data) {
                            pageList(data.currentPage, data.rowsPerPage);
                        }
                    })
                }
            })
        }
    </script>
</head>
<body>
<%--隐藏域 存储查询条件--%>
<input type="hidden" id="hidden-name"/>
<input type="hidden" id="hidden-owner"/>
<input type="hidden" id="hidden-startDate"/>
<input type="hidden" id="hidden-endDate"/>

<!-- 创建市场活动的模态窗口 -->
<div class="modal fade" id="createActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form" id="addForm">

                    <div class="form-group">
                        <label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-marketActivityOwner">

                            </select>
                        </div>
                        <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-marketActivityName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="create-startTime" readonly>
                        </div>
                        <label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="create-endTime" readonly>
                        </div>
                    </div>
                    <div class="form-group">

                        <label for="create-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-cost">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveBtn">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改市场活动的模态窗口 -->
<div class="modal fade" id="editActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form">

                    <input type="hidden" id="edit-id"/>

                    <div class="form-group">
                        <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-marketActivityOwner">
                            </select>
                        </div>
                        <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-marketActivityName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="edit-startTime" readonly>
                        </div>
                        <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="edit-endTime" readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-cost">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe"></textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="updateBtn">更新</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>市场活动列表</h3>
        </div>
    </div>
</div>
<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="find-name">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="find-owner">
                    </div>
                </div>


                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">开始日期</div>
                        <input class="form-control time" type="text" id="find-startDate" readonly/>
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">结束日期</div>
                        <input class="form-control time" type="text" id="find-endDate" readonly>
                    </div>
                </div>

                <button type="button" id="findBtn" class="btn btn-default">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <%--<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#createActivityModal">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>--%>
                <button type="button" class="btn btn-primary" id="addBtn">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <%--<button type="button" class="btn btn-default" data-toggle="modal" data-target="#editActivityModal"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>--%>
                <button type="button" class="btn btn-default" id="editBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteBtn"><span
                        class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>

        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="qx"/></td>
                    <td>名称</td>
                    <td>所有者</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                </tr>
                </thead>
                <tbody id="activityBody">
                <%--<tr class="active">
                    <td><input type="checkbox"/></td>
                    <td><a style="text-decoration: none; cursor: pointer;"
                           onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                    <td>zhangsan</td>
                    <td>2020-10-10</td>
                    <td>2020-10-20</td>
                </tr>
                <tr class="active">
                    <td><input type="checkbox"/></td>
                    <td><a style="text-decoration: none; cursor: pointer;"
                           onclick="window.location.href='detail.jsp';">发传单</a></td>
                    <td>zhangsan</td>
                    <td>2020-10-10</td>
                    <td>2020-10-20</td>
                </tr>--%>
                </tbody>
            </table>
        </div>

        <div style="height: 50px; position: relative;top: 30px;">
            <div id="activityPage"></div>
        </div>

    </div>

</div>
</body>
</html>