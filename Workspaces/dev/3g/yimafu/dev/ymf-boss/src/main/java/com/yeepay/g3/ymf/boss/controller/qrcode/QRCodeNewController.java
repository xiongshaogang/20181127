package com.yeepay.g3.ymf.boss.controller.qrcode; /**
 * 类名称: QRCodeWithShopController <br>
 * 类描述: <br>
 *
 * @author: dongxu.lu
 * @since: 16/10/28 上午11:04
 * @version: 1.0.0
 */

import com.yeepay.g3.core.ymf.biz.qrCode.QrCodeBizService;
import com.yeepay.g3.core.ymf.constants.Constants;
import com.yeepay.g3.core.ymf.entity.customer.Customer;
import com.yeepay.g3.core.ymf.entity.customer.CustomerResponse;
import com.yeepay.g3.core.ymf.entity.dictionary.Dictionary;
import com.yeepay.g3.core.ymf.entity.qrcode.QRCode;
import com.yeepay.g3.core.ymf.entity.qrcode.QrRelation;
import com.yeepay.g3.core.ymf.service.CustomerService;
import com.yeepay.g3.core.ymf.service.DictionaryService;
import com.yeepay.g3.core.ymf.service.qrcode.QrCodeService;
import com.yeepay.g3.core.ymf.service.qrcode.QrRelationService;
import com.yeepay.g3.core.ymf.utils.ConfigureSetting;
import com.yeepay.g3.core.ymf.utils.web.HttpUtil;
import com.yeepay.g3.facade.ymf.dto.qrCode.CreateQRCodeDTO;
import com.yeepay.g3.facade.ymf.enumtype.trade.BusinessType;
import com.yeepay.g3.facade.ymf.enumtype.trade.OrderStatus;
import com.yeepay.g3.facade.ymf.enumtype.trade.TrxCode;
import com.yeepay.g3.facade.ymf.exception.YmfTrxException;
import com.yeepay.g3.utils.common.json.JSONUtils;
import com.yeepay.g3.utils.common.log.Logger;
import com.yeepay.g3.utils.common.log.LoggerFactory;
import com.yeepay.g3.ymf.boss.controller.ValidateController;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import java.io.IOException;
import java.util.*;

@Controller
@RequestMapping("newQrCode")
public class QRCodeNewController extends ValidateController {
    Logger logger = LoggerFactory.getLogger(QRCodeNewController.class);
    @Autowired
    private CustomerService customerService;
    @Autowired
    private QrCodeService qrCodeService;
    @Autowired
    private DictionaryService dictionaryService;
    @Autowired
    private QrRelationService qrRelationService;
    @Autowired
    private QrCodeBizService qrCodeBizService;
    //二维码详情
    @RequestMapping("toCreate")
    public String toCreateQrCode(){
        return "qrcode/createQrCode";
    }
    @RequestMapping("toQuery")
    public String toQuery(){
        return "qrcode/qrCodeNewQuery";
    }
    @RequestMapping("create")
    public ModelAndView createQrCode(CreateQRCodeDTO qrCodeDTO) {
        ModelAndView mv = new ModelAndView();
        //@TODO 一期只有商户编号
        Customer customer = null;
        if(qrCodeDTO == null){
            mv.addObject("msg","参数都不填的啊,我可没你那么聪明!");
            mv.setViewName("error");
            return mv;
        }
        logger.info("createQrCode param: "+ JSONUtils.toJsonString(qrCodeDTO));
        String customerNumber = qrCodeDTO.getCustomerNumber();
        List<QRCode> qrCodeList = new ArrayList<QRCode>();
        if(qrCodeDTO.getQrCount()>200){
            mv.addObject("msg","一次最多允许生成200个,不要贪心啊亲!");
            mv.setViewName("error");
            return mv;
        }
        QrRelation qrRelation =new QrRelation();
        qrRelation.setCreateTime(new Date());
        qrRelation.setVersion(0l);
        qrRelation.setQrcount((short)qrCodeDTO.getQrCount());
        qrRelation.setStatus(OrderStatus.SUCCESS);
        String sales = qrCodeDTO.getSales();//销售名称
        String invoice =  qrCodeDTO.getQrInvoice();//单据号
        if(!StringUtils.isBlank(sales)){
            if(StringUtils.isEmpty(invoice)){
                mv.addObject("msg","请填写单据号!");
                mv.setViewName("error");
                return mv;
            }
            //销售信息有字符串传进来,根据格式进行拆分,获取销售信息
            String[] salesInfo = sales.split(",");
            String salesName = salesInfo[0];
            String  salesNo = salesInfo[2];
            List<QrRelation> list = qrRelationService.getBySalesNameAndRequestId(null,invoice);
            if(list.size()>0){
                mv.addObject("msg","销售单据已使用!");
                mv.setViewName("error");
                return mv;
            }
            qrRelation.setSalesNo(salesNo);
            qrRelation.setSalesName(salesName);
            qrRelation.setAgentNumber("");
            qrRelation.setRequestId(invoice);
            qrRelation.setInvoice(invoice);
            qrCodeBizService.createQrCodeWithRelation(qrRelation);
            mv.setViewName("qrcode/qrCodeNewQuery");
            return mv;
        }

        if(!StringUtils.isBlank(customerNumber)){
             customer = customerService.findByCustomerNumber(customerNumber);
        }
        if (null != customer) {
            mv.addObject("customer", customer);
        }

        try {

            for (int i = 0; i < qrCodeDTO.getQrCount(); i++) {
                QRCode code = new QRCode();
                if (null != customer) {
                    code.setCustomerNumber(customer.getCustomerNumber());
                    code.setBusinessType(qrCodeDTO.getBusinessType());
                }
                qrCodeList.add(code);
            }
            qrCodeService.batchCreateQrCode(qrCodeList);

        } catch (Exception e) {
            logger.error("###batchCreateQrCode Exception:",e);
            mv.addObject("msg","系统异常!");
            mv.setViewName("error");
            return mv;
        }
         mv.setViewName("qrcode/qrCodeNewQuery");
        return mv;
    }
    @RequestMapping("toModify")
    public ModelAndView toModify(@RequestParam(value = "id" )Long id){
        ModelAndView mv = new ModelAndView();
        QRCode qrCode = qrCodeService.getQrCodeById(id);
        if(null == qrCode){
            mv.addObject("msg","二维码 id:"+id+" 不存在");
            mv.setViewName("error");
            return mv;
        }
        mv.addObject("qrCode",qrCode);


        String customerNumber = qrCode.getCustomerNumber();
        Customer customer = customerService.findByCustomerNumber(customerNumber);
        if(null != customer){
            mv.addObject("customer",customer);
        }else{
            mv.addObject("msg"," 商户customerNumber :"+customerNumber+" 不存在!");
            mv.setViewName("error");
            return mv;
        }
        String appType = customer.getAppType();
        List<Dictionary> list = new ArrayList<Dictionary>();
        String[] apptypes =  appType.split(",");
        if(apptypes.length>1){
            for(String app:apptypes){
                List<Dictionary> codelist  = dictionaryService.getByDictionaryCode(app);
                list.addAll(codelist);
            }
        }else if(apptypes.length==1){
            List<Dictionary> codelist = dictionaryService.getByDictionaryCode(appType);
            list.addAll(codelist);
        }else{
            mv.addObject("msg",TrxCode.T1015.getMsg());
            mv.setViewName("error");
            return mv;
        }
        Map<String,String> businessMap = new HashMap<String, String>();
        if(list.size()>=1){
            for(Dictionary dic :list){
                String[] business = dic.getValue().split(",");
                for(String busines:business){
                    String disName = BusinessType.valueOf(busines).getDisplayName();
                    businessMap.put(busines,disName);
                }
            }
            mv.addObject("businessType",businessMap);
        }else{
            mv.addObject("msg",TrxCode.T1015.getMsg());
            mv.setViewName("error");
            return mv;
        }
        mv.setViewName("qrcode/qrCodeShopManage");
        return mv;
    }
    @ResponseBody
    @RequestMapping("getCustomerInfo")
    public CustomerResponse getCustomerInfo(@RequestParam("customerNumber") String customerNumber){
        CustomerResponse response = new CustomerResponse();
        Customer customer = customerService.findByCustomerNumber(customerNumber);
        if(null==customer){
            return null;
        }
        try {
            String appType = customer.getAppType();
            response.setCustomer(customer);
            List<Dictionary> list = new ArrayList<Dictionary>();
            String[] apptypes =  appType.split(",");
            if(apptypes.length>1){
                for(String app:apptypes){
                    List<Dictionary> codelist  = dictionaryService.getByDictionaryCode(app);
                    list.addAll(codelist);
                }
            }else if(apptypes.length==1){
                List<Dictionary> codelist = dictionaryService.getByDictionaryCode(appType);
                list.addAll(codelist);
            }else{
                response.setMsg(TrxCode.T1015.getMsg());
                return response;
            }
            Map<String,String> businessMap = new HashMap<String, String>();
            if(list.size()>=1){
                for(Dictionary dic :list){
                    String[] business = dic.getValue().split(",");
                    for(String busines:business){
                        String disName = BusinessType.valueOf(busines).getDisplayName();
                        businessMap.put(busines,disName);
                    }
                }
                response.setBusinessMap(businessMap);
            }else{
                throw new YmfTrxException(TrxCode.T1015);
            }
        } catch (YmfTrxException e) {
            logger.info("getByDictionaryCode exception:",e);
            response.setMsg(TrxCode.T1015.getMsg());
            return response;
        } catch (IllegalArgumentException e){
            logger.info("BusinessType.valueOf exception:",e);
            response.setMsg(TrxCode.T1016.getMsg());
            return response;
        }
        return response;
    }
    @ResponseBody
    @RequestMapping("getSalesInfo")
    public String getSalesInfo(){
        try {
            String url =  ConfigureSetting.getValue(Constants.SALES_DATA_URL,String.class);
            String result =  HttpUtil.httpGet(url,new HashMap());
            return result;
        } catch (IOException e) {
            logger.error(" getSalesInfo exception",e);
            return "false";
        }
    }


    @RequestMapping("updateQrCode")
    public ModelAndView updateQrCode(@RequestParam("qrcodeId") Long qrcodeId,
                                     @RequestParam("customerNumber") String customerNumber,
                                     @RequestParam("shopname") String shopname,
                                     @RequestParam("businessType") String businessType,
                                     QRCode qrCode){
        ModelAndView mv = new ModelAndView();
        Customer customer = customerService.findByCustomerNumber(customerNumber);
        if(null==customer){
            mv.addObject("msg","商户:"+customerNumber+" 不存在");
            mv.setViewName("error");
            return mv;
        }
        try {
            qrCode.setId(qrcodeId);
            qrCode.setShopname(shopname);
            qrCode.setCustomerNumber(customerNumber);
            qrCode.setBusinessType(BusinessType.valueOf(businessType));
            logger.info("qrCode  : "+qrCode.toString());
            qrCodeService.updateQrCode(qrCode);
        } catch (Exception e) {
            logger.error("###updateQrCode Exception qrCodeId:"+qrcodeId,e);
            mv.addObject("msg","系统异常!");
            mv.setViewName("error");
            return mv;
        }
        String appType = customer.getAppType();
        List<Dictionary> list = new ArrayList<Dictionary>();
        String[] apptypes =  appType.split(",");
        if(apptypes.length>1){
            for(String app:apptypes){
                List<Dictionary> codelist  = dictionaryService.getByDictionaryCode(app);
                list.addAll(codelist);
            }
        }else if(apptypes.length==1){
            List<Dictionary> codelist = dictionaryService.getByDictionaryCode(appType);
            list.addAll(codelist);
        }else{
            mv.addObject("msg",TrxCode.T1015.getMsg());
            mv.setViewName("error");
            return mv;
        }
        Map<String,String> businessMap = new HashMap<String, String>();
        if(list.size()>=1){
            for(Dictionary dic :list){
                String[] business = dic.getValue().split(",");
                for(String busines:business){
                    String disName = BusinessType.valueOf(busines).getDisplayName();
                    businessMap.put(busines,disName);
                }
            }
            mv.addObject("businessType",businessMap);
        }else{
            mv.addObject("msg",TrxCode.T1015.getMsg());
            mv.setViewName("error");
            return mv;
        }
        QRCode qrCodes = qrCodeService.getQrCodeById(qrCode.getId());
        mv.addObject("qrCode",qrCodes);
        mv.addObject("customer",customer);
        mv.setViewName("qrcode/qrCodeNewQuery");
        return mv;
    }

}
