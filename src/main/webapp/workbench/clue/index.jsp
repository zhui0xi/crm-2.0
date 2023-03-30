<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--前端的标准标签库--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
                pickerPosition: "top-left"
            });

            //给动态子复选框绑定单击事件
            $("#clueBody").on("click", $("input[name='xz']"), function () {
                $("#qx").prop("checked", $("input[name='xz']").length == $("input[name='xz']:checked").length)
            })

            //给全选复选框绑定单击事件
            $("#qx").click(function () {
                if ($("#qx").prop("checked")) {
                    $("input[name='xz']").prop("checked", true);
                } else {
                    $("input[name='xz']").prop("checked", false);
                }
            })

            //给查询按钮绑定单击事件
            $("#findBtn").click(function () {
                $("#hidden-fullname").val($.trim($("#find-fullname").val()));
                $("#hidden-owner").val($.trim($("#find-owner").val()));
                $("#hidden-company").val($.trim($("#find-company").val()));
                $("#hidden-phone").val($.trim($("#find-phone").val()));
                $("#hidden-mphone").val($.trim($("#find-mphone").val()));
                $("#hidden-source").val($("#find-source").val());
                $("#hidden-state").val($("#find-state").val());

                pageList(1, $("#cluePage").bs_pagination("getOption", "rowsPerPage"));
            })

            //给当前窗口绑定按下键盘事件
            $(window).keydown(function (event) {
                //按下回车键
                if (event.keyCode == 13) {
                    $("#hidden-fullname").val($.trim($("#find-fullname").val()));
                    $("#hidden-owner").val($.trim($("#find-owner").val()));
                    $("#hidden-company").val($.trim($("#find-company").val()));
                    $("#hidden-phone").val($.trim($("#find-phone").val()));
                    $("#hidden-mphone").val($.trim($("#find-mphone").val()));
                    $("#hidden-source").val($("#find-source").val());
                    $("#hidden-state").val($("#find-state").val());

                    pageList(1, $("#cluePage").bs_pagination("getOption", "rowsPerPage"));
                }
            })

            //为创建的模态窗口的保存按钮绑定单击事件
            $("#saveBtn").click(function () {
                $.ajax({
                    url: "workbench/clue/save.do",
                    data: {
                        "fullname": $.trim($("#create-surname").val()),
                        "appellation": $("#create-call").val(),
                        "owner": $("#create-clueOwner").val(),
                        "company": $.trim($("#create-company").val()),
                        "job": $.trim($("#create-job").val()),
                        "email": $.trim($("#create-email").val()),
                        "phone": $.trim($("#create-phone").val()),
                        "website": $.trim($("#create-website").val()),
                        "mphone": $.trim($("#create-mphone").val()),
                        "state": $("#create-status").val(),
                        "source": $("#create-source").val(),
                        "description": $.trim($("#create-describe").val()),
                        "contactSummary": $.trim($("#create-contactSummary").val()),
                        "nextContactTime": $("#create-nextContactTime").val(),
                        "address": $.trim($("#create-address").val())
                    },
                    dataType: "json",
                    success: function (data) {
                        //data {"success":true/false}
                        if (data.success) {
                            //刷新页面
                            pageList($("#cluePage").bs_pagination("getOption", "currentPage"),
                                $("#cluePage").bs_pagination("getOption", "rowsPerPage"));

                            //关闭模态窗口
                            $("#createClueModal").modal("hide");
                        } else {
                            alert("线索保存失败")
                        }
                    }
                })
            })

            //为创建按钮绑定单击事件
            $("#addBtn").click(function () {
                //所有者下拉框
                $.ajax({
                    url: "workbench/clue/getUserList.do",
                    dataType: "json",
                    type: "get",
                    success: function (data) {
                        //data {"uList":List<User>}
                        //所有者下拉框
                        var userList = "<option></option>";
                        $.each(data, function (i, n) {
                            userList += "<option value='" + n.id + "'>" + n.name + "</option>";
                        })
                        $("#create-clueOwner").html(userList);

                        //所有者下拉框默认选中当前登录的用户
                        $("#create-clueOwner").val("${sessionScope.user.id}");
                    }
                })

                //打开模态窗口
                $("#createClueModal").modal("show");
            })

            //给修改按钮绑定单击事件
            $("#editBtn").click(function () {

                if ($("input[name='xz']:checked").length == 0) {
                    alert("请选择要修改的线索");
                } else if ($("input[name='xz']:checked").length > 1) {
                    alert("抱歉，只能选择一条线索修改");
                } else {
                    //线索的id
                    var id = $("input[name='xz']:checked").val();

                    //去后台获取数据，页面铺上数据
                    $.ajax({
                        url: "workbench/clue/getUserAndClue.do",
                        data: {
                            "id": id
                        },
                        dataType: "json",
                        success: function (data) {
                            //data:{"uList":List<User>,"c":Clue}
                            //所有者下拉框
                            var uList = "<option></option>";
                            $.each(data.uList, function (i, n) {
                                if (n.name == data.c.owner) {
                                    uList += "<option value='" + n.id + "' selected>" + n.name + "</option>"
                                } else {
                                    uList += "<option value='" + n.id + "'>" + n.name + "</option>";
                                }
                            })
                            $("#edit-clueOwner").html(uList);

                            //称呼
                            $.each($("#edit-call option"), function (i, n) {
                                //这时n是原生的dom
                                if ($(n).val() == data.c.appellation) {
                                    $(n).prop("selected", true);
                                }
                            })
                            //线索的状态
                            $.each($("#edit-status option"), function (i, n) {
                                if ($(n).val() == data.c.state) {
                                    $(n).prop("selected", true);
                                }
                            })
                            //线索的来源
                            $.each($("#edit-source option"), function (i, n) {
                                if ($(n).val() == data.c.source) {
                                    $(n).prop("selected", true);
                                }
                            })

                            $("#edit-clueOwner").html(uList);
                            $("#edit-company").val(data.c.company);
                            $("#edit-surname").val(data.c.fullname);
                            $("#edit-job").val(data.c.job);
                            $("#edit-email").val(data.c.email);
                            $("#edit-phone").val(data.c.phone);
                            $("#edit-website").val(data.c.website);
                            $("#edit-mphone").val(data.c.mphone);
                            $("#edit-describe").val(data.c.description);
                            $("#edit-contactSummary").val(data.c.contactSummary);
                            $("#edit-nextContactTime").val(data.c.nextContactTime);
                            $("#edit-address").val(data.c.address);

                            //打开模态窗口
                            $("#editClueModal").modal("show");
                        }
                    })
                }
            })

            //给修改的模态窗口的更新按钮绑定单击事件
            $("#updateBtn").click(function () {
                //参数
                var appellation = $("#edit-call").val();
                var state = $("#edit-status").val();
                var source = $("#edit-source").val();

                var id = $("input[name='xz']:checked").val();
                //所有者传过去的是id
                var owner = $("#edit-clueOwner").val();
                var company = $("#edit-company").val();
                var fullname = $("#edit-surname").val();
                var job = $("#edit-job").val();
                var email = $("#edit-email").val();
                var phone = $("#edit-phone").val();
                var website = $("#edit-website").val();
                var mphone = $("#edit-mphone").val();
                var description = $("#edit-describe").val();
                var contactSummary = $("#edit-contactSummary").val();
                var nextContactTime = $("#edit-nextContactTime").val();
                var address = $("#edit-address").val();

                $.ajax({
                    url: "workbench/clue/update.do",
                    data: {
                        "id": id,
                        "appellation": appellation,
                        "state": state,
                        "source": source,
                        "owner": owner,
                        "company": company,
                        "fullname": fullname,
                        "job": job,
                        "email": email,
                        "phone": phone,
                        "website": website,
                        "mphone": mphone,
                        "description": description,
                        "contactSummary": contactSummary,
                        "nextContactTime": nextContactTime,
                        "address": address
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        //data:{"success":boolean}
                        if (data.success) {
                            //关闭模态窗口
                            $("#editClueModal").modal("hide");
                            alert("线索更新成功");
                            //刷新页面
                            pageList($("#cluePage").bs_pagination("getOption", "currentPage"),
                                $("#cluePage").bs_pagination("getOption", "rowsPerPage"));
                        } else {
                            alert("线索更新失败");
                        }
                    }
                })
            })

            //给删除按钮绑定单击事件
            $("#deleteBtn").click(function () {
                var $xz = $("input[name='xz']:checked");

                if ($xz.length == 0) {
                    alert("请选择要删除的线索");
                } else {
                    if (confirm("您确定要删除所选择的线索吗？")) {
                        //拼参数 id=..&id=..&id=..
                        var ids = "";
                        for (var i = 0; i < $xz.length; i++) {
                            ids += "id=" + $($xz[i]).val();
                            if (i != $xz.length - 1) {
                                ids += "&";
                            }
                        }

                        $.ajax({
                            url: "workbench/clue/deleteByIds.do",
                            data: ids, //只能用传统的拼凑参数的方式
                            type: "post",
                            dataType: "json",
                            success: function (data) {
                                //data:{"success":boolean}
                                if (data.success) {
                                    //刷新页面
                                    pageList($("#cluePage").bs_pagination("getOption", "currentPage"),
                                        $("#cluePage").bs_pagination("getOption", "rowsPerPage"));
                                } else {
                                    alert("线索删除失败");
                                }
                            }
                        })
                    }
                }
            })

        });

        //多条件分页查询
        function pageList(pageNo, pageSize) {
            //每次分页查询(刷新页面)把全选复选框的钩给干掉
            $("#qx").prop("checked", false);

            $("#find-fullname").val($.trim($("#hidden-fullname").val()));
            $("#find-owner").val($.trim($("#hidden-owner").val()));
            $("#find-company").val($.trim($("#hidden-company").val()));
            $("#find-phone").val($.trim($("#hidden-phone").val()));
            $("#find-mphone").val($.trim($("#hidden-mphone").val()));
            $("#find-source").val($("#hidden-source").val());
            $("#find-state").val($("#hidden-state").val());

            $.ajax({
                url: "workbench/clue/pageList.do",
                data: {
                    "pageNo": pageNo,
                    "pageSize": pageSize,
                    "fullname": $.trim($("#find-fullname").val()),
                    "company": $.trim($("#find-company").val()),
                    "phone": $.trim($("#find-phone").val()),
                    "source": $("#find-source").val(),
                    "owner": $.trim($("#find-owner").val()),
                    "mphone": $.trim($("#find-mphone").val()),
                    "state": $("#find-state").val()
                },
                dataType: "json",
                success: function (data) {
                    //data {"total":int,"dataList":"[{},{},...]"}
                    var clueBody = "";
                    $.each(data.dataList, function (i, n) {
                        clueBody += '<tr class="active">';
                        clueBody += '<td><input type="checkbox" name="xz" value="' + n.id + '"/></td>';
                        clueBody += '<td><a style="text-decoration: none; cursor: pointer;"';
                        clueBody += 'onclick="window.location.href=\'workbench/clue/detail.do?id=' + n.id + '\';">' + n.fullname + '</a>';
                        clueBody += '</td>';
                        clueBody += '<td>' + n.company + '</td>';
                        clueBody += '<td>' + n.phone + '</td>';
                        clueBody += '<td>' + n.mphone + '</td>';
                        clueBody += '<td>' + n.source + '</td>';
                        clueBody += '<td>' + n.owner + '</td>';
                        clueBody += '<td>' + n.state + '</td>';
                        clueBody += '</tr>';
                    })
                    $("#clueBody").html(clueBody);

                    //计算总页数
                    var totalPages = data.total % pageSize == 0 ? data.total / pageSize : (data.total / pageSize) + 1;

                    //处理完数据之后，结合分页查询，对前端展现分页信息
                    $("#cluePage").bs_pagination({
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
<%--隐藏域 保存查询条件--%>
<input type="hidden" id="hidden-fullname"/>
<input type="hidden" id="hidden-company"/>
<input type="hidden" id="hidden-phone"/>
<input type="hidden" id="hidden-source"/>
<input type="hidden" id="hidden-owner"/>
<input type="hidden" id="hidden-mphone"/>
<input type="hidden" id="hidden-state"/>


<!-- 创建线索的模态窗口 -->
<div class="modal fade" id="createClueModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">创建线索</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="create-clueOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-clueOwner">

                            </select>
                        </div>
                        <label for="create-company" class="col-sm-2 control-label">公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-company">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-call">
                                <option></option>
                                <c:forEach items="${applicationScope.appellation}" var="a">
                                    <option>${a.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-surname">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-job">
                        </div>
                        <label for="create-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-email">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-phone">
                        </div>
                        <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-website">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-mphone">
                        </div>
                        <label for="create-status" class="col-sm-2 control-label">线索状态</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-status">
                                <option></option>
                                <c:forEach items="${applicationScope.clueState}" var="c">
                                    <option>${c.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-source" class="col-sm-2 control-label">线索来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-source">
                                <option></option>
                                <c:forEach items="${applicationScope.source}" var="s">
                                    <option>${s.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>


                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">线索描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="create-nextContactTime" readonly>
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="create-address"></textarea>
                            </div>
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

<!-- 修改线索的模态窗口 -->
<div class="modal fade" id="editClueModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">修改线索</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="edit-clueOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-clueOwner">

                            </select>
                        </div>
                        <label for="edit-company" class="col-sm-2 control-label">公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-company"/>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-call">
                                <option></option>
                                <c:forEach items="${applicationScope.appellation}" var="a">
                                    <option>${a.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-surname"/>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-job"/>
                        </div>
                        <label for="edit-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-email"/>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-phone"/>
                        </div>
                        <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-website"/>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-mphone"/>
                        </div>
                        <label for="edit-status" class="col-sm-2 control-label">线索状态</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-status">
                                <option></option>
                                <c:forEach items="${applicationScope.clueState}" var="c">
                                    <option>${c.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-source" class="col-sm-2 control-label">线索来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-source">
                                <option></option>
                                <c:forEach items="${applicationScope.source}" var="s">
                                    <option>${s.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe"></textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="edit-nextContactTime" readonly>
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="edit-address"></textarea>
                            </div>
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
            <h3>线索列表</h3>
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
                        <input class="form-control" type="text" id="find-fullname">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司</div>
                        <input class="form-control" type="text" id="find-company">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司座机</div>
                        <input class="form-control" type="text" id="find-phone">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">线索来源</div>
                        <select class="form-control" id="find-source">
                            <option></option>
                            <c:forEach items="${applicationScope.source}" var="s">
                                <option>${s.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <br>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="find-owner">
                    </div>
                </div>


                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">手机</div>
                        <input class="form-control" type="text" id="find-mphone">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">线索状态</div>
                        <select class="form-control" id="find-state">
                            <option></option>
                            <c:forEach items="${applicationScope.clueState}" var="c">
                                <option>${c.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="findBtn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" id="addBtn">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editBtn">
                    <span class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteBtn">
                    <span class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>


        </div>
        <div style="position: relative;top: 50px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="qx"/></td>
                    <td>名称</td>
                    <td>公司</td>
                    <td>公司座机</td>
                    <td>手机</td>
                    <td>线索来源</td>
                    <td>所有者</td>
                    <td>线索状态</td>
                </tr>
                </thead>
                <tbody id="clueBody">
                <%--<tr>
                    <td><input type="checkbox"/></td>
                    <td><a style="text-decoration: none; cursor: pointer;"
                           onclick="window.location.href='workbench/clue/detail.jsp';">李四先生</a>
                    </td>
                    <td>***</td>
                    <td>010-84846003</td>
                    <td>12345678901</td>
                    <td>广告</td>
                    <td>zhangsan</td>
                    <td>已联系</td>
                </tr>
                <tr class="active">
                    <td><input type="checkbox"/></td>
                    <td><a style="text-decoration: none; cursor: pointer;"
                           onclick="window.location.href='workbench/clue/detail.jsp';">李四先生</a>
                    </td>
                    <td>***</td>
                    <td>010-84846003</td>
                    <td>12345678901</td>
                    <td>广告</td>
                    <td>zhangsan</td>
                    <td>已联系</td>
                </tr>--%>
                </tbody>
            </table>
        </div>

        <div style="height: 50px; position: relative;top: 60px;">
            <div id="cluePage">

            </div>
            <%--<div>
                <button type="button" class="btn btn-default" style="cursor: default;">共<b>50</b>条记录</button>
            </div>
            <div class="btn-group" style="position: relative;top: -34px; left: 110px;">
                <button type="button" class="btn btn-default" style="cursor: default;">显示</button>
                <div class="btn-group">
                    <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                        10
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="#">20</a></li>
                        <li><a href="#">30</a></li>
                    </ul>
                </div>
                <button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
            </div>
            <div style="position: relative;top: -88px; left: 285px;">
                <nav>
                    <ul class="pagination">
                        <li class="disabled"><a href="#">首页</a></li>
                        <li class="disabled"><a href="#">上一页</a></li>
                        <li class="active"><a href="#">1</a></li>
                        <li><a href="#">2</a></li>
                        <li><a href="#">3</a></li>
                        <li><a href="#">4</a></li>
                        <li><a href="#">5</a></li>
                        <li><a href="#">下一页</a></li>
                        <li class="disabled"><a href="#">末页</a></li>
                    </ul>
                </nav>
            </div>--%>
        </div>

    </div>

</div>
</body>
</html>