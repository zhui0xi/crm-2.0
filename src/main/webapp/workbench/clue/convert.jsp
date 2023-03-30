<%@ page import="java.lang.annotation.Target" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<html>
<head>
    <base href="<%=basePath%>"/>

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>


    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

    <script type="text/javascript">
        $(function () {
            //时间控件
            $(".time").datetimepicker({
                minView: "month",
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "down-left"
            });

            $("#isCreateTransaction").click(function () {
                if (this.checked) {
                    $("#create-transaction2").show(200);
                } else {
                    $("#create-transaction2").hide(200);
                }
            });

            //给取消按钮绑定事件
            $("#exitBtn").click(function (){
                window.location.href = "workbench/clue/index.jsp"
            })

            //给关联市场活动的搜索框绑定按下键盘事件
            $("#searchModalBtn").keydown(function (event){
                if(event.keyCode==13){
                    $.ajax({
                        url:"workbench/clue/getActivityListByName.do",
                        data:{
                            "aname":$.trim($("#searchModalBtn").val())
                        },
                        type:"get",
                        dataType:"json",
                        success:function (data){
                            //data {"aList":List<Activity>}
                            var activityBodyModal = "";

                            $.each(data,function (i,n){
                                activityBodyModal += '<tr>';
                                activityBodyModal += '<td><input type="radio" name="activity" value="'+n.id+'"/></td>';
                                activityBodyModal += '<td>'+n.name+'</td>';
                                activityBodyModal += '<td>'+n.startDate+'</td>';
                                activityBodyModal += '<td>'+n.endDate+'</td>';
                                activityBodyModal += '<td>'+n.owner+'</td>';
                                activityBodyModal += '</tr>';
                            })
                            $("#activityBodyModal").html(activityBodyModal);

                            //清空搜索框的内容
                            $("#searchModalBtn").val("");
                        }
                    })
                }
                return false;
            })

            //给选择了市场活动的内容填充到表单中
            $("#addActivityBtn").click(function (){
                $aid = $("input[name='activity']:checked").val();
                $aname = $("#n"+$aid).html();
                /*alert($aid)
                alert($aname)*/

                $("#activity").val($aname);
                $("#activityId").val($aid);

                //关闭模态窗口
                $("#searchActivityModal").modal("hide");
            })

            //给为客户创建交易绑定单击事件
            $("#addBtn").click(function (){
                if ($("#isCreateTransaction").prop("checked")){
                    //需要创建交易
                    //提交表单
                    $("#tranForm").submit();
                }else{
                    //不用创建交易
                    window.location.href = "workbench/clue/convert.do?clueId=${param.clueId}";
                }
            })




        });

        //给关联市场活动的模态窗口，铺上尚未关联的市场活动数据
        function searchBodyModal(){
            $.ajax({
                url:"workbench/clue/getActivityList.do",
                type:"get",
                dataType:"json",
                success:function (data){
                    //data {"aList":List<Activity>}
                    var activityBodyModal = "";

                    $.each(data,function (i,n){
                        activityBodyModal += '<tr>';
                        activityBodyModal += '<td><input type="radio" name="activity" value="'+n.id+'"/></td>';
                        activityBodyModal += '<td id="n'+n.id+'">'+n.name+'</td>';
                        activityBodyModal += '<td>'+n.startDate+'</td>';
                        activityBodyModal += '<td>'+n.endDate+'</td>';
                        activityBodyModal += '<td>'+n.owner+'</td>';
                        activityBodyModal += '</tr>';
                    })
                    $("#activityBodyModal").html(activityBodyModal);

                    //打开模态窗口
                    $("#searchActivityModal").modal("show");
                }
            })
        }

    </script>

</head>
<body>

<!-- 搜索市场活动的模态窗口 -->
<div class="modal fade" id="searchActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">搜索市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input type="text" class="form-control" style="width: 300px;"
                                   placeholder="请输入市场活动名称，支持模糊查询" id="searchModalBtn">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                        <td></td>
                    </tr>
                    </thead>
                    <tbody id="activityBodyModal">
                    <%--<tr>
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
                    </tr>--%>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" id="addActivityBtn">提交</button>
            </div>
        </div>
    </div>
</div>

<div id="title" class="page-header" style="position: relative; left: 20px;">
    <h4>转换线索 <small>${param.fullname}${param.appellation}-${param.company}</small></h4>
</div>
<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
    新建客户：${param.company}
</div>
<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
    新建联系人：${param.fullname}${param.appellation}
</div>
<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
    <input type="checkbox" id="isCreateTransaction"/>
    为客户创建交易
</div>
<div id="create-transaction2"
     style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;">

    <form id="tranForm" action="workbench/clue/convert.do" method="post">
        <input type="hidden" name="flag" value="true"/>
        <input type="hidden" name="clueId" value="${param.clueId}"/>

        <div class="form-group" style="width: 400px; position: relative; left: 20px;">
            <label for="amountOfMoney">金额</label>
            <input type="text" class="form-control" id="amountOfMoney" name="money">
        </div>
        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="tradeName">交易名称</label>
            <input type="text" class="form-control" id="tradeName" name="name">
        </div>
        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="expectedClosingDate">预计成交日期</label>
            <input type="text" class="form-control time" id="expectedClosingDate" name="expectedDate" readonly>
        </div>
        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="stage">阶段</label>
            <select id="stage" class="form-control" name="stage">
                <option></option>
                <c:forEach items="${applicationScope.stage}" var="s">
                    <option value="${s.value}">${s.text}</option>
                </c:forEach>
            </select>
        </div>
        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="activity">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" onclick="searchBodyModal()" style="text-decoration: none;"><span
                    class="glyphicon glyphicon-search"></span></a></label>
            <input type="text" class="form-control" id="activity" placeholder="点击上面搜索" readonly>
            <input type="hidden" name="activityId"/>
        </div>
    </form>

</div>

<div id="owner" style="position: relative; left: 40px; height: 35px; top: 50px;">
    记录的所有者：<br>
    <b>${param.owner}</b>
</div>
<div id="operation" style="position: relative; left: 40px; height: 35px; top: 100px;">
    <input class="btn btn-primary" type="button" value="转换" id="addBtn">
    &nbsp;&nbsp;&nbsp;&nbsp;
    <input class="btn btn-default" type="button" value="取消" id="exitBtn">
</div>
</body>
</html>