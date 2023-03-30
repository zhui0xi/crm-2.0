<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<html>
<head>
    <base href="<%=basePath%>"/>
    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

    <script type="text/javascript">

        //默认情况下取消和保存按钮是隐藏的
        var cancelAndSaveBtnDefault = true;

        $(function () {
            $("#remark").focus(function () {
                if (cancelAndSaveBtnDefault) {
                    //设置remarkDiv的高度为130px
                    $("#remarkDiv").css("height", "130px");
                    //显示
                    $("#cancelAndSaveBtn").show("2000");
                    cancelAndSaveBtnDefault = false;
                }
            });

            $("#cancelBtn").click(function () {
                //显示
                $("#cancelAndSaveBtn").hide();
                //设置remarkDiv的高度为130px
                $("#remarkDiv").css("height", "90px");
                cancelAndSaveBtnDefault = true;
            });

            $(".remarkDiv").mouseover(function () {
                $(this).children("div").children("div").show();
            });

            $(".remarkDiv").mouseout(function () {
                $(this).children("div").children("div").hide();
            });

            $(".myHref").mouseover(function () {
                $(this).children("span").css("color", "red");
            });

            $(".myHref").mouseout(function () {
                $(this).children("span").css("color", "#E6E6E6");
            });

            gerRemarkListById();

            //给每一个动态元素备注绑定鼠标悬停事件
            $("#remarkBody").on("mouseover",".remarkDiv",function (){
                $(this).children("div").children("div").show();
            })
            $("#remarkBody").on("mouseout",".remarkDiv",function (){
                $(this).children("div").children("div").hide();
            })

            //给备注的保存按钮绑定单击事件
            $("#saveBtn").click(function (){
                $.ajax({
                    url:"workbench/activity/saveRemark.do",
                    data:{
                        "noteContent":$.trim($("#remark").val()),
                        "activityId":"${requestScope.a.id}"
                    },
                    dataType:"json",
                    type:"post",
                    success:function (data){
                        //data {"success":true/false,"ar":ActivityRemark}
                        if(data.success){
                            //清空添加备注的文本框
                            $("#remark").val("");

                            var remark = "";
                            remark += '<div id="'+data.ar.id+'" class="remarkDiv" style="height: 60px;">';
                            remark += '<img id="t'+data.ar.id+'" title="'+data.ar.createBy+'" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
                            remark += '<div style="position: relative; top: -40px; left: 40px;">';
                            remark += '<h5 id="n'+data.ar.id+'">'+data.ar.noteContent+'</h5>';
                            remark += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${requestScope.a.name}</b> <small style="color: gray;" id="s'+data.ar.id+'">';
                            remark += ''+data.ar.createTime+' 由'+data.ar.createBy+'</small>';
                            remark += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                            remark += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+data.ar.id+'\')"><span class="glyphicon glyphicon-edit"';
                            remark += 'style="font-size: 20px; color: red;"></span></a>';
                            remark += '&nbsp;&nbsp;&nbsp;&nbsp;';
                            remark += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+data.ar.id+'\')"><span class="glyphicon glyphicon-remove"';
                            remark += 'style="font-size: 20px; color: red;"></span></a>';
                            remark += '</div>';
                            remark += '</div>';
                            remark += '</div>';
                            $("#remarkDiv").before(remark);
                        }else{
                            alert("添加失败");
                        }
                    }
                })
            })

            //修改备注的模态窗口的更新按钮绑定单击事件
            $("#updateRemarkBtn").click(function (){
                var id = $("#remarkId").val();

                $.ajax({
                    url:"workbench/activity/updateRemark.do",
                    data:{
                        "id":id,
                        "noteContent":$.trim($("#noteContent").val())
                    },
                    dataType:"json",
                    type:"post",
                    success:function (data){
                        //dara {"success":true/false,"ar":ActivityRemark}
                        if(data.success){
                            //更新备注信息
                            $("#t"+id).prop("title",data.ar.editBy);
                            $("#n"+id).html(data.ar.noteContent);
                            $("#s"+id).html(data.ar.editTime+" 由"+data.ar.editBy);

                            //关闭修改备注的模态窗口
                            $("#editRemarkModal").modal("hide");
                        }else{
                            alert("修改失败")
                        }
                    }
                })
            })

            //给编辑按钮绑定单击事件
            $("#editBtn").click(function (){



            })

        });

        function editRemark(id){
            //把所选择的备注的id保存在隐藏域中
            $("#remarkId").val(id);

            //获得所选择的备注信息
            var noteContent = $("#n"+id).html();

            //把备注信息填入到模态窗口的textarea中
            $("#noteContent").val(noteContent);

            //打开更新备注的模态窗口
            $("#editRemarkModal").modal("show");

        }

        function gerRemarkListById(){
            $.ajax({
                url:"workbench/activity/gerRemarkListById.do",
                data:{
                    "activityId":"${requestScope.a.id}" //在js代码中，el表达式要在字符串中
                },
                dataType:"json",
                type:"get",
                success:function (data){
                    //data {"arList":List<ActivityRemark>}
                    var remarkList = "";
                    $.each(data,function (i,n){
                        remarkList += '<div id="'+n.id+'" class="remarkDiv" style="height: 60px;">';
                        remarkList += '<img id="t'+n.id+'" title="'+(n.editFlag==0?n.createBy:n.editBy)+'" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
                        remarkList += '<div style="position: relative; top: -40px; left: 40px;">';
                        remarkList += '<h5 id="n'+n.id+'">'+n.noteContent+'</h5>';
                        remarkList += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${requestScope.a.name}</b> <small style="color: gray;" id="s'+n.id+'">';
                        remarkList += ''+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
                        remarkList += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                        remarkList += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-edit"';
                        remarkList += 'style="font-size: 20px; color: red;"></span></a>';
                        remarkList += '&nbsp;&nbsp;&nbsp;&nbsp;';
                        remarkList += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-remove"';
                        remarkList += 'style="font-size: 20px; color: red;"></span></a>';
                        remarkList += '</div>';
                        remarkList += '</div>';
                        remarkList += '</div>';
                    })
                    $("#remarkDiv").before(remarkList);
                }
            })
        }

        function deleteRemark(id){
            $.ajax({
                url:"workbench/activity/deleteRemark.do",
                data:{
                    "id":id
                },
                dataType: "json",
                type:"post",
                success:function (data){
                    //data {"success":true/false}
                    if(data.success){
                        //删除显示的备注，等同于刷新了备注页面
                        $("#"+id).remove();
                    }else{
                        alert("删除失败");
                    }
                }
            })
        }
    </script>

</head>
<body>

<!-- 修改市场活动备注的模态窗口 -->
<div class="modal fade" id="editRemarkModal" role="dialog">
    <%-- 备注的id --%>
    <input type="hidden" id="remarkId">
    <div class="modal-dialog" role="document" style="width: 40%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">修改备注</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">内容</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="noteContent"></textarea>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
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
                <h4 class="modal-title">修改市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-marketActivityOwner">
                                <option>zhangsan</option>
                                <option>lisi</option>
                                <option>wangwu</option>
                            </select>
                        </div>
                        <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-startTime" value="2020-10-10">
                        </div>
                        <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-endTime" value="2020-10-20">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-cost" value="5,000">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" data-dismiss="modal">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left"
                                                                         style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>市场活动-发传单 <small>2020-10-10 ~ 2020-10-20</small></h3>
    </div>
    <div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
        <button type="button" class="btn btn-default" id="editBtn"><span
                class="glyphicon glyphicon-edit"></span> 编辑
        </button>
        <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
    </div>
</div>

<!-- 详细信息 -->
<div style="position: relative; top: -70px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.a.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.a.name}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>

    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">开始日期</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.a.startDate}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.a.endDate}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">成本</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.a.cost}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.a.createBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${requestScope.a.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.a.editBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${requestScope.a.editTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${requestScope.a.description}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div style="position: relative; top: 30px; left: 40px;" id="remarkBody">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <!-- 备注1 -->
    <%--<div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>哎呦！</h5>
            <font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;">
            2017-01-22 10:10:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>--%>

    <!-- 备注2 -->
    <%--<div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>呵呵！</h5>
            <font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;">
            2017-01-22 10:20:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>--%>

    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>
            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button type="button" class="btn btn-primary" id="saveBtn">保存</button>
            </p>
        </form>
    </div>
</div>
<div style="height: 200px;"></div>
</body>
</html>