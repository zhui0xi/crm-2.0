<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

    <script type="text/javascript">

        $(function () {
            pageList(1,2);

            //给查询按钮绑定单击事件
            $("#findBtn").click(function () {
                $("#hidden-owner").val($.trim($("#find-owner").val()));
                $("#hidden-name").val($.trim($("#find-name").val()));
                $("#hidden-customerId").val($.trim($("#find-customerId").val()));
                $("#hidden-stage").val($("#find-stage").val());
                $("#hidden-type").val($("#find-type").val());
                $("#hidden-source").val($("#find-source").val());
                $("#hidden-contactsId").val($.trim($("#find-contactsId").val()));

                pageList(1, $("#tranPage").bs_pagination("getOption", "rowsPerPage"));
            })

            //给当前窗口绑定按下键盘事件
            $(window).keydown(function (event){
                if(event.keyCode == 13){
                    $("#hidden-owner").val($.trim($("#find-owner").val()));
                    $("#hidden-name").val($.trim($("#find-name").val()));
                    $("#hidden-customerId").val($.trim($("#find-customerId").val()));
                    $("#hidden-stage").val($("#find-stage").val());
                    $("#hidden-type").val($("#find-type").val());
                    $("#hidden-source").val($("#find-source").val());
                    $("#hidden-contactsId").val($.trim($("#find-contactsId").val()));

                    pageList(1, $("#tranPage").bs_pagination("getOption", "rowsPerPage"));
                }
            })

            //给全选复选框绑定单击事件
            $("#qx").click(function (){
                $("input[name='xz']").prop("checked",this.checked);
            })

            //给动态元素子复选框绑定单击事件
            $("#tranBody").on("click",$("input[name='xz']"),function (){
                $("#qx").prop("checked",$("input[name='xz']").length == $("input[name='xz']:checked").length);
            })

            //给修改按钮绑定单击事件
            $("#editBtn").click(function (){
                //参数
                var $xz = $("input[name='xz']:checked");

                if($xz.length == 0){
                    alert("请选择要修改的交易");
                }else if($xz.length > 1){
                    alert("抱歉，只能选择一场交易修改");
                }else{
                    //去后台获取数据，在修改页面铺上数据
                    window.location.href = "workbench/transaction/getTranById.do?id="+$xz.val();
                }

            })
        });

        //多条件分页查询
        function pageList(pageNo, pageSize) {
            //每次刷新页面，把全选按钮去掉选中状态
            $("#qx").prop("checked", false);

            $("#find-owner").val($.trim($("#hidden-owner").val()));
            $("#find-name").val($.trim($("#hidden-name").val()));
            $("#find-customerId").val($.trim($("#hidden-customerId").val()));
            $("#find-stage").val($("#hidden-stage").val());
            $("#find-type").val($("#hidden-type").val());
            $("#find-source").val($("#hidden-source").val());
            $("#find-contactsId").val($.trim($("#hidden-contactsId").val()));

            $.ajax({
                url: "workbench/transaction/pageList.do",
                data: {
                    "pageNo": pageNo,
                    "pageSize": pageSize,
                    "owner":$.trim($("#find-owner").val()),
                    "name":$.trim($("#find-name").val()),
                    "customerId":$.trim($("#find-customerId").val()),
                    "stage":$("#find-stage").val(),
                    "type":$("#find-type").val(),
                    "source":$("#find-source").val(),
                    "contactsId":$("#find-contactsId").val()
                },
                dataType: "json",
                success: function (data) {
                    //data {"total":int,"dataList":"[{},{},...]"}
                    var tranBody = "";
                    $.each(data.dataList, function (i, n) {
                        tranBody += '<tr class="active">';
                        tranBody += '<td><input type="checkbox" name="xz" value="' + n.id + '"/></td>';
                        tranBody += '<td><a style="text-decoration: none; cursor: pointer;"';
                        tranBody += 'onclick="window.location.href=\'workbench/transaction/detail.do?id=' + n.id + '\';">' + n.name + '</a>';
                        tranBody += '</td>';
                        tranBody += '<td>' + n.customerId + '</td>';
                        tranBody += '<td>' + n.stage + '</td>';
                        tranBody += '<td>' + n.type + '</td>';
                        tranBody += '<td>' + n.owner + '</td>';
                        tranBody += '<td>' + n.source + '</td>';
                        tranBody += '<td>' + n.contactsId + '</td>';
                        tranBody += '</tr>';
                    })
                    $("#tranBody").html(tranBody);

                    //计算总页数
                    var totalPages = data.total % pageSize == 0 ? data.total / pageSize : (data.total / pageSize) + 1;

                    //处理完数据之后，结合分页查询，对前端展现分页信息
                    $("#tranPage").bs_pagination({
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


        //加载交易列表
        /*function showTranList() {
            $.ajax({
                url: "workbench/transaction/getTranList.do",
                type: "get",
                dataType: "json",
                success: function (data) {
                    //data {"tList":List<Tran>}
                    var tranBody = "";

                    $.each(data, function (i, n) {
                        tranBody += '<tr>';
                        tranBody += '<td><input type="checkbox" /></td>';
                        tranBody += '<td><a style="text-decoration: none; cursor: pointer;" onclick="detail(\'' + n.id + '\')">' + n.name + '</a></td>';
                        tranBody += '<td>' + n.customerId + '</td>';
                        tranBody += '<td>' + n.stage + '</td>';
                        tranBody += '<td>' + n.type + '</td>';
                        tranBody += '<td>' + n.owner + '</td>';
                        tranBody += '<td>' + n.source + '</td>';
                        tranBody += '<td>' + n.contactsId + '</td>';
                        tranBody += '</tr>';
                    })
                    $("#tranBody").html(tranBody);
                }
            })
        }*/

        /*function detail(id) {
            window.location.href = "workbench/transaction/detail.do?id=" + id;
        }*/
    </script>
</head>
<body>
<%--隐藏域 存储查询条件--%>
<input type="hidden" id="hidden-owner">
<input type="hidden" id="hidden-name">
<input type="hidden" id="hidden-customerId">
<input type="hidden" id="hidden-stage">
<input type="hidden" id="hidden-type">
<input type="hidden" id="hidden-source">
<input type="hidden" id="hidden-contactsId">

<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>交易列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="find-owner">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="find-name">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">客户名称</div>
                        <input class="form-control" type="text" id="find-customerId">
                    </div>
                </div>

                <br>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">阶段</div>
                        <select class="form-control" id="find-stage">
                            <option></option>
                            <c:forEach items="${applicationScope.stage}" var="s">
                                <option>${s.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">类型</div>
                        <select class="form-control" id="find-type">
                            <option></option>
                            <c:forEach items="${applicationScope.transactionType}" var="tt">
                                <option>${tt.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">来源</div>
                        <select class="form-control" id="find-source">
                            <option></option>
                            <c:forEach items="${applicationScope.source}" var="s">
                                <option>${s.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">联系人名称</div>
                        <input class="form-control" type="text" id="find-contactsId">
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="findBtn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary"
                        onclick="window.location.href='workbench/transaction/add.do';"><span
                        class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
            </div>


        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="qx"/></td>
                    <td>名称</td>
                    <td>客户名称</td>
                    <td>阶段</td>
                    <td>类型</td>
                    <td>所有者</td>
                    <td>来源</td>
                    <td>联系人名称</td>
                </tr>
                </thead>
                <tbody id="tranBody">
                <%--<tr>
                    <td><input type="checkbox" /></td>
                    <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/transaction/detail.jsp';">交易01</a></td>
                    <td>***</td>
                    <td>谈判/复审</td>
                    <td>新业务</td>
                    <td>zhangsan</td>
                    <td>广告</td>
                    <td>李四</td>
                </tr>
                <tr class="active">
                    <td><input type="checkbox" /></td>
                    <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/transaction/detail.jsp';">交易01</a></td>
                    <td>***</td>
                    <td>谈判/复审</td>
                    <td>新业务</td>
                    <td>zhangsan</td>
                    <td>广告</td>
                    <td>李四</td>
                </tr>--%>
                </tbody>
            </table>
        </div>

        <div style="height: 50px; position: relative;top: 20px;">
            <div id="tranPage">

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