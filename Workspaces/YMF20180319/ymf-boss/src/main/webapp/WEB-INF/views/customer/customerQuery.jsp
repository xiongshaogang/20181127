<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/main/taglibs.jsp"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>商户查询</title>
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/datepicker.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/common/download.js"></script>
    <script>
        $().ready(function() {
            loadBusinessCode();
            loadSelectNameMessage("PayType","payTypeInfo");
        })
        function loadBusinessCode(){
            var bizCodeList = $("#bizCode");
            $.ajax({
                url: "${pageContext.request.contextPath}/business/loadBusinessCode",
                dataType: "json",
                success: function (json) {
                    if (json.length == 0) {
                        bizCodeList.empty();
                        bizCodeList.append('<option value="">无业务方，待配置</option>');
                    } else {
                        var selc = '';
                        var opt = '';
                        $.each(json, function (index, entry) {
                            opt = '<option value="' + entry['bizCode'] + '">' + entry['bizName'] + '</option> ';
                            selc =selc + opt;
                        });
                    }
                    $("#bizCode").append(selc);
                }

            });
        }
        function loadSelectNameMessage(type,id){
            var selectList =$("#"+id+"");
            $.ajax({
                url: "${pageContext.request.contextPath}/dictionary/getDictionariesByType",
                data: {"type": type},
                dataType: "json",
                success: function (json) {
                    if (json.length == 0) {
                        selectList.empty();
                        selectList.append('<option value="">待配置</option>');
                    } else {
                        var selc = '';
                        var opt = '';
                        $.each(json, function (index, entry) {
                            opt = '<option value="' + entry['name'] + '">' + entry['name'] + '</option> ';
                            selc =selc + opt;
                        });
                    }
                    $("#"+id+"").append(selc);
                }

            });
        }
        function addCustomer(){
            window.location="${pageContext.request.contextPath}/customer/toAdd";
        }
        function customerDetail(id){
            window.location="${pageContext.request.contextPath}/customer/detail?id="+id;
        }
        function toCustomerModify(id){
            window.location="${pageContext.request.contextPath}/customer/toModify?id="+id;
        }
        function toShopManager(id){
            window.location="${pageContext.request.contextPath}/shop/query?customerNumber="+id;
        }
        /**
         * excel下载
         */
        function downloadResult(){
            func_download({
                formId : "form",
                buttonId : "downid",
                queryId : "customerQuery",
                downloadType : "excel",
                url : "down"
            });
        }

        function toCustomerPayModify(id){
            var customerIds="";
            if(confirm('确认要为这些商户切换吗？')){
                $.ajax({
                    type: "post",
                    url: "${pageContext.request.contextPath}/customer/payModify",
                    data: {"id":id,"customerIds":customerIds},
                    dataType: "json",
                    success: function (json) {
                      if (json.status=='ok') {
                            alert("操作成功!");
                            window.location="${pageContext.request.contextPath}/customer/query";
                        } else if(json.status=='error'){
                            alert(json.msg);
                        }else{
                            alert("操作失败!");
                        }

                    }

                });
            }
        }
        function customerPay(){
            var customerIds ="";
            var id="";
            var checkboxs = document.getElementsByName("customerid");
            for(i=0;i<checkboxs.length;i++)
            {
                if(checkboxs[i].checked){
                    customerIds=customerIds+checkboxs[i].value+",";
                }
            }
            if(customerIds == ""){
                alert("请选择需要切换的商户");
                return false;
            }

            if(confirm('确认要为这些商户切换吗？')){
                $.ajax({
                    type: "post",
                    url: "${pageContext.request.contextPath}/customer/payModify",
                    data:{"customerIds":customerIds,"id":id},
                    dataType: "json",
                    success: function (json) {
                        if (json.status=='ok') {
                            alert("操作成功!");
                            window.location="${pageContext.request.contextPath}/customer/query";
                        } else if(json.status=='error'){
                            alert(json.msg);
                        }else{
                            alert("操作失败!");
                        }

                    }
                });
            }

        }
    </script>
</head>
<body>

<div class="Container">
    <div class="Content fontText">
        <form action="query" id="form" method="get">
            <div class="search">
                <div class="search_tit">
                    <h2 class="fw fleft f14">商户查询</h2>
                </div>
                <div class="clearer"></div>
                <div class="search_con">
                    <ul class="fix">
                        <li>
                            <p>
                                <label class="text_tit">商户编号：</label>
                                <input type="text" class="input_text" id="customerNumber"  name="customerNumber" value="${param.customerNumber}"/>
                            </p>
                        </li>
                        <li>
                            <p>
                                <label class="text_tit">商户名称：</label>
                                <input type="text" class="input_text" id="customerName" name="customerName" value="${param.customerName}"/>
                            </p>
                        </li>
                        <li>
                            <p>
                                <label class="text_tit">创建时间：</label>
                                    <input type="text" name="startDate" req="true" class="input_text" id="startDate"
                                           readonly="true" value="${param.startDate}"/>
                            </p>
                        </li>
                        <li>
                            <p>
                                <label class="text_tit">至&nbsp;&nbsp;</label>
                                <input type="text" name="endDate" class="input_text" req="true" id="endDate"
                                       readonly="true" value="${param.endDate}"/>
                            </p>
                        </li>
                    </ul>
                    <br/>

                    <ul class="fix">
                        <li>
                            <p>
                                <label class="text_tit">所属行业：</label>
                                <dic:select type="IndustryType" code="${param.industryType}" id="industryType" name="industryType" clazz="select" />
                            </p>
                        </li>
                        <%--<li>--%>
                            <%--<p>--%>
                                <%--<label class="text_tit">商户等级：</label>--%>
                                <%--<select class="input_text" id="customerLevel" name="customerLevel" value="${param.customerLevel}">--%>
                                    <%--<option value="">请选择</option>--%>
                                    <%--<option value="A">甲级</option>--%>
                                    <%--<option value="B">乙级</option>--%>
                                    <%--<option value="C">丙级</option>--%>
                                <%--</select>--%>
                            <%--</p>--%>
                        <%--</li>--%>
                        <%--<li>--%>
                            <%--<p>--%>
                                <%--<label class="text_tit">商户类型：</label>--%>
                                <%--<select class="input_text" id="customerType" name="customerType" value="${param.customerType}">--%>
                                    <%--<option value="">请选择</option>--%>
                                <%--</select>--%>
                            <%--</p>--%>
                        <%--</li>--%>
                        <li>
                            <p>
                                <label class="text_tit">业务方：</label>
                                <select class="input_text" id="bizCode" name="bizCode" value="${param.bizCode}">
                                    <option value="">请选择业务方</option>
                                </select>
                            </p>
                        </li>
                        <li>
                            <p>
                                <label class="text_tit">产品权限：</label>
                                <select id="status" name="status" value="${param.status}" class="input_text">
                                    <option value="">请选择</option>
                                    <option value="ACTIVE">开通</option>
                                    <option value="INACTIVE">关闭</option>
                                </select>
                            </p>
                        </li>
                        <li>
                            <p>
                                <label class="text_tit">支付方式：</label>
                                <select class="input_text" id="payTypeInfo" name="payTypeInfo" value="${param.payTypeInfo}">
                                    <option value="">请选择</option>
                                </select>
                            </p>
                        </li>
                    </ul>
                    <br/>
                    <ul class="fix">


                        <li>
                            <p>
                                <label class="text_tit">下单通道：</label>
                                <select class="input_text" id="tradesystem" name="tradesystem" value="${param.tradesystem}">
                                    <option value="">请选择</option>
                                    <option value="OPR">大算</option>
                                    <option value="CASHIER">收银台</option>
                                </select>
                            </p>
                        </li>

                    </ul>
                    <br/>
                    <%--<ul class="fix">--%>
                        <%--<li>--%>
                            <%--<p>--%>
                                <%--<label class="text_tit">业务方：</label>--%>
                                <%--<select class="input_text" id="bizCode" name="bizCode" value="${param.bizCode}">--%>
                                    <%--<option value="">请选择业务方</option>--%>
                                <%--</select>--%>
                            <%--</p>--%>
                        <%--</li>--%>
                        <%--<li>--%>
                            <%--<p>--%>
                                <%--<label class="text_tit">产品权限：</label>--%>
                                <%--<select id="status" name="status" value="${param.status}" class="input_text">--%>
                                    <%--<option value="">请选择</option>--%>
                                    <%--<option value="ACTIVE">开通</option>--%>
                                    <%--<option value="INACTIVE">关闭</option>--%>
                                <%--</select>--%>
                            <%--</p>--%>
                        <%--</li>--%>

                    <%--</ul>--%>
                    <br/>
                    <br/>
                    <br/>
                    <div class="btn">
                        <input type="submit"  class="btn_sure fw" id="queryid" value="查询" />
                        <input type="button"  class="btn_sure fw" id="downid" onclick="downloadResult()" value="EXCEL下载" />
                        <input type="reset"  class="btn_cancel fw" id="resetid" value="重置" />
                        <input type="button" onclick="addCustomer()"  class="btn_sure fw" value="新增" />
                        <input type="button" onclick="customerPay()"  class="btn_sure fw" value="切换" />
                    </div>
                    <div class="clearer"></div>
                </div>
            </div>
        </form>
        <div class="search">

            <q:table queryService="ymfDownloadQueryService" queryKey="customerQuery" class="list" formId="form">
                <q:nodata>无数据</q:nodata>
                <q:column title="序号" escapeHtml="false" width = "90px">
                    <c:if test="${flag==null}">
                        <input type="checkbox" name="customerid" id="customer${id}" value="${id}">&nbsp;&nbsp;${rowid}
                    </c:if>
                    <c:if test="${flag=='OPR_AFTER'}">
                        ${rowid}
                    </c:if>
                </q:column>
                <q:column title="商户编号" value="${customernumber}" />
                <q:column title="商户名称" value="${customername}" />
                <q:column title="所属行业" value="${industrytype}" />
                <%--<q:column title="商户等级" value="${customerlevel}" />--%>
                <%--<q:column title="商户类型" value="${customertype}" />--%>
                <q:column title="创建时间" value="${createtime}" />
                <q:column title="修改时间" value="${updatetime}" />
                <q:column title="产品权限" value="${status}" />
                <q:column title="业务方" value="${bizcode}" />
                <q:column title="支付方式" value="${paytypeinfo}" />
                <q:column title="下单通道" value="${tradesystem}" />
                <q:column title="操作" escapeHtml="false"  width = "130px">
                    <a href="javascript:customerDetail('${id }')">详情</a>
                    <a href="javascript:toCustomerModify('${id}')">修改</a>
                    <a href="javascript:toCustomerPayModify('${id}')">切换</a>
                    <a href="javascript:toShopManager('${customernumber}')">网点信息</a>
                </q:column>
            </q:table>
        </div>
    </div>
</div>
<%@ include file="/WEB-INF/main/footer.jsp"%>
</body>

</html>

