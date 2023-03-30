<%@ page import="com.chen.crm.workbench.domain.Tran" %>
<%@ page import="java.util.List" %>
<%@ page import="com.chen.crm.settings.domain.DicValue" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";

    Tran t = (Tran) request.getAttribute("t");
    //当前阶段
    String currentStage = t.getStage();
    //当前可能性
    String currentPossibility = t.getPossibility();

    //数据字典的阶段
    List<DicValue> dvList = (List<DicValue>) application.getAttribute("stage");
    //阶段和可能性的对应关系
    Map<String, String> pMap = (Map<String, String>) application.getAttribute("pMap");

    //前面正常阶段和后面丢失阶段的分界点下标
    int point = -1;
    for (int i = 0; i < dvList.size(); i++) {
        //每一个字典值
        DicValue dv = dvList.get(i);
        //每一个阶段
        String stage = dv.getValue();
        //根据阶段得到每一个可能性
        String possibility = pMap.get(stage);
        if ("0".equals(possibility)) {
            point = i;
            break;
        }
    }

%>
<html>
<head>
    <base href="<%=basePath%>"/>

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>

    <style type="text/css">
        .mystage {
            font-size: 20px;
            vertical-align: middle;
            cursor: pointer;
        }

        .closingDate {
            font-size: 15px;
            cursor: pointer;
            vertical-align: middle;
        }
    </style>

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


            //阶段提示框
            $(".mystage").popover({
                trigger: 'manual',
                placement: 'bottom',
                html: 'true',
                animation: false
            }).on("mouseenter", function () {
                var _this = this;
                $(this).popover("show");
                $(this).siblings(".popover").on("mouseleave", function () {
                    $(_this).popover('hide');
                });
            }).on("mouseleave", function () {
                var _this = this;
                setTimeout(function () {
                    if (!$(".popover:hover").length) {
                        $(_this).popover("hide")
                    }
                }, 100);
            });

            showTranHistoryList();

        });

        //加载阶段历史
        function showTranHistoryList() {
            $.ajax({
                url: "workbench/transaction/getTranHistoryList.do",
                data: {
                    "tranId": "${requestScope.t.id}"
                },
                type: "get",
                dataType: "json",
                success: function (data) {
                    //data {"thList":List<TranHistory>}
                    var tranHistoryBody = "";

                    $.each(data, function (i, n) {
                        tranHistoryBody += '<tr>';
                        tranHistoryBody += '<td>' + n.stage + '</td>';
                        tranHistoryBody += '<td>' + n.money + '</td>';
                        tranHistoryBody += '<td>' + n.possibility + '</td>';
                        tranHistoryBody += '<td>' + n.expectedDate + '</td>';
                        tranHistoryBody += '<td>' + n.createTime + '</td>';
                        tranHistoryBody += '<td>' + n.createBy + '</td>';
                        tranHistoryBody += '</tr>';
                    })
                    $("#tranHistoryBody").html(tranHistoryBody);
                }
            })
        }

        //更改阶段
        function changeStage(stage, index) {
            /*alert(stage);
            alert(index);*/

            $.ajax({
                url: "workbench/transaction/changeStage.do",
                data: {
                    "id": "${requestScope.t.id}",
                    "stage": stage,
                    "money": "${requestScope.t.money}", //添加交易历史用的
                    "expectedDate": "${requestScope.t.expectedDate}" //添加交易历史用的
                },
                type: "post",
                dataType: "json",
                success: function (data) {
                    //data {"success":true/false,"t":Tran}
                    alert(data.t)
                    if (data.success) {
                        //刷新交易信息
                        $("#stage").html(data.t.stage);
                        $("#possibility").html(data.t.possibility);
                        $("#editBy").html(data.t.editBy);
                        $("#editTime").html(data.t.editTime);
                        alert(data.success)
                        alert(data.t)

                        //刷新交易历史
                        showTranHistoryList();

                        //刷新阶段的图标
                        changeIcon(stage, index);
                    }

                }
            })
        }

        //stage 当前阶段
        //index 当前阶段的下标
        function changeIcon(stage, index) {
            //当前可能性
            var possibility = $("#possibility").html();

            //前面正常阶段和后面丢失阶段的分界点下标
            var point = <%=point%>;

            //当前可能性为0，前面7个阶段都是黑圈，后面1个黑叉1个红叉，顺序不定
            if (possibility == 0) {
                //前面7个阶段
                for (var i = 0; i < point; i++) {
                    //黑圈----------------------------------
                    //移除原有的样式
                    $("#"+i).removeClass();
                    //添加样式
                    $("#"+i).addClass("glyphicon glyphicon-record mystage");
                    //为新样式赋予颜色
                    $("#"+i).css("color","#000000");
                }
                //后面2个阶段
                for(var i = point; i < <%=dvList.size()%>; i++){
                    if(i==index){
                        //红叉--------------------------------------
                        $("#"+i).removeClass();
                        $("#"+i).addClass("glyphicon glyphicon-remove mystage");
                        $("#"+i).css("color","#FF0000");
                    }else{
                        //黑叉-------------------------------------
                        $("#"+i).removeClass();
                        $("#"+i).addClass("glyphicon glyphicon-remove mystage");
                        $("#"+i).css("color","#000000");
                    }
                }

            //当前可能性不为0，前面7个阶段可能绿圈、绿色标记、黑圈，后面2个都是黑叉
            } else {
                //前面7个阶段
                for (var i = 0; i < point; i++) {
                    if(i==index){
                        //绿色下标--------------------------------------
                        $("#"+i).removeClass();
                        $("#"+i).addClass("glyphicon glyphicon-map-marker mystage");
                        $("#"+i).css("color","#90F790");
                    }else if(i<index){
                        //绿圈----------------------------------------
                        $("#"+i).removeClass();
                        $("#"+i).addClass("glyphicon glyphicon-ok-circle mystage");
                        $("#"+i).css("color","#90F790");
                    }else{
                        //黑圈---------------------------------------
                        $("#"+i).removeClass();
                        $("#"+i).addClass("glyphicon glyphicon-record mystage");
                        $("#"+i).css("color","#000000");
                    }
                }
                //后面2个阶段
                for(var i = point; i < <%=dvList.size()%>; i++){
                    //黑叉--------------------------------
                    $("#"+i).removeClass();
                    $("#"+i).addClass("glyphicon glyphicon-remove mystage");
                    $("#"+i).css("color","#000000");
                }
            }
        }

    </script>

</head>
<body>

<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left"
                                                                         style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>${requestScope.t.name} <small>￥${requestScope.t.money}</small></h3>
    </div>
    <div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
        <button type="button" class="btn btn-default" onclick="window.location.href='edit.jsp';">
            <span class="glyphicon glyphicon-edit"></span> 编辑
        </button>
        <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
    </div>
</div>

<!-- 阶段状态 -->
<div style="position: relative; left: 40px; top: -50px;">
    阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

    <%
        //当前可能性为0，前面7个阶段都是黑圈，后面1个黑叉1个红叉，顺序不定
        if ("0".equals(currentPossibility)) {
            for (int i = 0; i < dvList.size(); i++) {
                //取出其对应的可能性
                DicValue dv = dvList.get(i);
                String stage = dv.getValue();
                String possibility = pMap.get(stage);

                if ("0".equals(possibility)) {
                    if (stage.equals(currentStage)) {
                        //红叉--------------------------------------------
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
          class="glyphicon glyphicon-remove mystage" data-toggle="popover" data-placement="bottom"
          data-content="<%=dv.getText()%>>" style="color: #FF0000;"></span>
    -----------
    <%
    } else {
        //黑叉--------------------------------------------
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
          class="glyphicon glyphicon-remove mystage" data-toggle="popover" data-placement="bottom"
          data-content="<%=dv.getText()%>>" style="color: #000000;"></span>
    -----------
    <%
        }
    } else {
        //黑圈------------------------------------------------
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
          class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom"
          data-content="<%=dv.getText()%>>" style="color: #000000;"></span>
    -----------
    <%
            }
        }
        //当前可能性不为0，前面7个阶段可能绿圈、绿色标记、黑圈，后面2个都是黑叉
    } else {
        //获得当前阶段的下标
        int index = -1;
        for (int i = 0; i < dvList.size(); i++) {
            //取出其对应的阶段
            DicValue dv = dvList.get(i);
            String stage = dv.getValue();
            if (stage.equals(currentStage)) {
                index = i;
                break;
            }
        }

        for (int i = 0; i < dvList.size(); i++) {
            //取出其对应的可能性
            DicValue dv = dvList.get(i);
            String stage = dv.getValue();
            String possibility = pMap.get(stage);

            if ("0".equals(possibility)) {
                //黑叉------------------------------------------------
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
          class="glyphicon glyphicon-remove mystage" data-toggle="popover" data-placement="bottom"
          data-content="<%=dv.getText()%>>" style="color: #000000;"></span>
    -----------
    <%
    } else {
        //当前阶段
        if (index == i) {
            //绿色下标-----------------------------------------
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
          class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom"
          data-content="<%=dv.getText()%>>" style="color: #90F790;"></span>
    -----------
    <%
        //小于当前阶段
    } else if (index > i) {
        //绿圈-----------------------------------------------
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
          class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom"
          data-content="<%=dv.getText()%>>" style="color: #90F790;"></span>
    -----------
    <%
        //大于当前阶段
    } else {
        //黑圈------------------------------------------------
    %>
    <span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
          class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom"
          data-content="<%=dv.getText()%>>" style="color: #000000;"></span>
    -----------
    <%
                    }
                }
            }
        }


    %>

    <%--<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom"
          data-content="资质审查" style="color: #90F790;"></span>
    -----------
    <span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom"
          data-content="需求分析" style="color: #90F790;"></span>
    -----------
    <span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom"
          data-content="价值建议" style="color: #90F790;"></span>
    -----------
    <span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom"
          data-content="确定决策者" style="color: #90F790;"></span>
    -----------
    <span class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom"
          data-content="提案/报价" style="color: #90F790;"></span>
    -----------
    <span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom"
          data-content="谈判/复审"></span>
    -----------
    <span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom"
          data-content="成交"></span>
    -----------
    <span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom"
          data-content="丢失的线索"></span>
    -----------
    <span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom"
          data-content="因竞争丢失关闭"></span>
    -----------
    --%>

    <span class="closingDate">${requestScope.t.expectedDate}</span>
</div>

<!-- 详细信息 -->
<div style="position: relative; top: 0px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.t.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.t.money}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.t.name}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.t.expectedDate}</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">客户名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.t.customerId}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="stage">${requestScope.t.stage}</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">类型</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.t.type}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b
                id="possibility">${requestScope.t.possibility}</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">来源</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.t.source}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.t.activityId}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">联系人名称</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.t.contactsId}</b></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>${requestScope.t.createBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${requestScope.t.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b id="editBy">${requestScope.t.editBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;" id="editTime">${requestScope.t.editTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 80px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${requestScope.t.description}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 90px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${requestScope.t.contactSummary}&nbsp;
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 100px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.t.nextContactTime}&nbsp;</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div style="position: relative; top: 100px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <!-- 备注1 -->
    <div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>哎呦！</h5>
            <font color="gray">交易</font> <font color="gray">-</font> <b>****-交易01</b> <small style="color: gray;">
            2017-01-22 10:10:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>

    <!-- 备注2 -->
    <div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>呵呵！</h5>
            <font color="gray">交易</font> <font color="gray">-</font> <b>****-交易01</b> <small style="color: gray;">
            2017-01-22 10:20:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>

    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>
            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button type="button" class="btn btn-primary">保存</button>
            </p>
        </form>
    </div>
</div>

<!-- 阶段历史 -->
<div>
    <div style="position: relative; top: 100px; left: 40px;">
        <div class="page-header">
            <h4>阶段历史</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTable" class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>阶段</td>
                    <td>金额</td>
                    <td>可能性</td>
                    <td>预计成交日期</td>
                    <td>创建时间</td>
                    <td>创建人</td>
                </tr>
                </thead>
                <tbody id="tranHistoryBody">
                <%--<tr>
                    <td>资质审查</td>
                    <td>5,000</td>
                    <td>10</td>
                    <td>2017-02-07</td>
                    <td>2016-10-10 10:10:10</td>
                    <td>zhangsan</td>
                </tr>
                <tr>
                    <td>需求分析</td>
                    <td>5,000</td>
                    <td>20</td>
                    <td>2017-02-07</td>
                    <td>2016-10-20 10:10:10</td>
                    <td>zhangsan</td>
                </tr>
                <tr>
                    <td>谈判/复审</td>
                    <td>5,000</td>
                    <td>90</td>
                    <td>2017-02-07</td>
                    <td>2017-02-09 10:10:10</td>
                    <td>zhangsan</td>
                </tr>--%>
                </tbody>
            </table>
        </div>

    </div>
</div>

<div style="height: 200px;"></div>

</body>
</html>