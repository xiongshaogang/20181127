//订单表增加索引
CREATE INDEX YMF.YMF_PAYMENT_ORDER_ID_INDEX ON YMF.YMF_PAYMENT(ORDER_ID);
CREATE INDEX YMF.YMF_SETTLE_DETAIL_YEEPAY_ORDER_ID_INDEX ON YMF.YMF_SETTLE_DETAIL(YEEPAY_ORDER_ID);
//结算记录表增加三个字段
ALTER TABLE YMF.YMF_SETTLE_DETAIL ADD COLUMN EXTERNAL_ID VARCHAR(64);
ALTER TABLE YMF.YMF_SETTLE_DETAIL ADD COLUMN SETTLE_STATUS VARCHAR(64) DEFAULT 'SUCCESS';
ALTER TABLE YMF.YMF_SETTLE_DETAIL ADD COLUMN REMARK VARCHAR(256);
CREATE INDEX YMF.YMF_SETTLE_DETAIL_EXTERNAL_ID_IDX ON YMF.YMF_SETTLE_DETAIL (EXTERNAL_ID);

CREATE INDEX YMF.USER_MEMBER_NO_IDX ON YMF.TBL_USER (MEMBER_NO);
CREATE INDEX YMF.SMS_PHONE_NO_IDX ON YMF.TBL_SMS_CODE (PHONE_NO);
//未执行
UPDATE YMF.TBL_ACCOUNT_OPEN
SET TBL_ACCOUNT_OPEN.SETTLE_CARD_NAME = TBL_ACCOUNT_OPEN.MERCHANT_NAME
WHERE ACCOUNT_TYPE = 'LOL' AND 	SETTLE_CARD_NAME IS NULL;




