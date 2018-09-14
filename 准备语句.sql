--公共参数
--select
--1 code,
--'' message,
--convert(xml,(


--个人就诊记录查询
select 
jzxh visitNo,
brbh patientCode,
(select brxm from ms_brda where brid = brbh) patientNme,
convert(varchar(20),kssj,120) visitTime,
ksdm departmentCode,
(select ksmc from gy_ksdm where ksdm = ys_mz_jzls.KSDM) departmentName,
(select ygxm from gy_ygdm where ygdm = ys_mz_jzls.YSDM) doctorName,
(select convert(varchar(4),row_number() OVER(ORDER BY jlbh))+ '.' + jbmc + ';'   from ys_mz_jbzd where jzxh = 31545 for xml path('')) diagnsisName,
convert(xml,(select
(select ypmc from yk_typk where ypxh = ms_cf02.ypxh) drugName,
(select ypmc from yk_typk where ypxh = ms_cf02.ypxh) specifiation,
ms_cf02.ypsl quantity,
convert(varchar(8),ms_cf02.ycjl) + ((select jldw from yk_typk where ypxh = ms_cf02.ypxh)) onesDose,
(select PCMC from GY_SYPC where pcbm = ms_cf02.YPYF and jgid  = 0 ) frequency,
(select XMMC from zy_ypyf where ypyf = ms_cf02.GYTJ) usage
from ms_cf01,ms_cf02 where ms_cf01.cfsb = ms_cf02.cfsb and ms_cf01.jzxh = ys_mz_jzls.jzxh for xml path('drugItem'))) 
from ys_mz_jzls
where brbh in(203) for xml path ('data')

select * from ys_mz_jzls

--配药医生查询
--取同科室权限的医生
--根据排班取医生
--科室条件扩大到行政科室

--医生是否可配要根据排班

--select
--distinct 
--ysdm doctorCode,
--(select ygxm from gy_ygdm where ygdm = ms_yspb.ysdm) doctorName
--from ms_yspb
--where exists (select ksdm from ms_ghks where ms_ghks.ksdm = ms_yspb.ksdm and mzks  =  '60' ) 
--and gzrq >= '2016.01.01' for xml path ('data')

--医生是否有配药权限放在gy_ygdm
--select 
--gy_ygdm.ygdm doctorCode,
--gy_ygdm.YGXM doctorName
--from ys_mz_ksqx,gy_ygdm
--where exists (select ksdm from ms_ghks where ms_ghks.ksdm = ys_mz_ksqx.ksdm and mzks  =  '60') 
--and ys_mz_ksqx.YSDM = gy_ygdm.YGDM


--配药申请
--select 
--ms_yygh.yyxh hisOrderNo,
--convert(varchar(20) ,ghrq,120) endPayTime,
--case when ms_brda.brxz in (1000) then 0 else 1 end  arrears,
--ms_yygh.JZXH queueNumber
--from ms_yygh,ms_brda
--where ms_yygh.brid = ms_brda.brid 
--and ms_yygh.ghrq > '2016-06-07' for xml path ('data')


--配药诊疗费预结算


--配药诊疗费支付确认

--取消配药申请

--代缴费记录查询
--根据费用归并显示代缴费记录
--增加视图收费详
--alter view V_MOB_PAYMENTDETAIL
--as
--select
--a.brid patientCode,
--a.mzxh paymentSerial,
--convert(date,a.kfrq) costdate,
--(select ygxm from gy_ygdm where ygdm = a.ysdm) doctorName,
--(select ksmc from gy_ksdm where ksdm = a.ksdm) departmentName,
----b.hjje totalCost,
--a.cflx recipeType,
--a.cfts potion,
--'1-' + convert(varchar(20),a.cfsb) identificationNumber,
--a.jzxh visitNo,
--b.fygb mergingCode,
--(select gy_sfxm.sfmc from gy_sfxm where sfxm = b.fygb) mergingName,
----b.hjje mergingSubtota,

--(select ypmc from yk_typk where ypxh = b.ypxh) costName,
--b.ypsl itemNumber,
--b.ypdj price,
--b.hjje amount,
--b.yfdw unit,
--b.yfgg specifications
--from ms_cf01 a,ms_cf02 b
--where a.cfsb = b.cfsb
--union all
--select
--a.brid patientCode,
--a.mzxh paymentSerial,
--convert(date,a.kdrq) costdate,
--(select ygxm from gy_ygdm where ygdm = a.ysdm) doctorName,
--(select ksmc from gy_ksdm where ksdm = a.ksdm) departmentName,
--0 recipeType,
--1 potion,
--'0-' + convert(varchar(20),a.yjxh) identificationNumber,
--a.jzxh visitNo,
--b.fygb mergingCode,
--(select sfmc from gy_sfxm where sfxm = b.fygb ) mergingName,
--(select fymc from gy_ylsf where fyxh = b.ylxh ) costName,
--b.ylsl itemNumber,
--b.yldj price,
--b.hjje amount,
--(select fydw from gy_ylsf where fyxh = b.ylxh ) unit,
--(select fydw from gy_ylsf where fyxh = b.ylxh ) specifications
--from ms_yj01 a,ms_yj02 b
--where a.yjxh = b.yjxh 



--select * from gy_ylsf

--select
--a.costdate,
--a.doctorName,
--a.departmentName departmentName,
--sum(a.amount)  totalCost,
--(select identificationNumber + ',' from V_MOB_PAYMENTDETAIL b where b.visitNo = a.visitNo group by identificationNumber  for xml path('')) identificationNumber,
--convert(xml,
--(select c.mergingName,
--		c.mergingCode,
--		sum(c.amount) mergingSubtota,
--		convert(xml,(select d.costName,d.itemNumber,d.price,d.amount,d.unit,d.specifications from V_MOB_PAYMENTDETAIL d where d.visitNo = c.visitNo and d.mergingCode = c.mergingCode for xml path ('grugItems'))) 
--from  V_MOB_PAYMENTDETAIL c where c.visitNo = a.visitNo group by c.visitNo,c.mergingName,c.mergingCode for xml path('mergingItems'))
-- ) 

--from V_MOB_PAYMENTDETAIL a
--where a.patientCode = 210
--and a.costDate = '2018-02-10'
--group by a.doctorName,a.departmentName,a.costDate,a.visitNo 
--for xml path('data')


--门诊缴费确认

--门诊缴费记录查询

--select
--fphm invoiceNo,
--convert(varchar(20),sfrq,120) paymentTime,
----(select (select fkmc from gy_fkfs where fkfs = ms_fkxx.FKFS) + ':' + convert(varchar(18),round(FKJE,2)) from MS_FKXX where mzxh = ms_mzxx.mzxh for xml path('')) paymentWay,
--round(zjje,2) totalAmount,
--zfpb invlidSign
--from ms_mzxx
--where fphm = '10009' for xml path('data')



--门诊缴费详情

--select
--fphm invoiceNo,
--convert(varchar(20),sfrq,120) paymentTime,
--(select (select fkmc from gy_fkfs where fkfs = ms_fkxx.FKFS) + ':' + convert(varchar(18),round(FKJE,2)) from MS_FKXX where mzxh = ms_mzxx.mzxh for xml path('')) paymentWay,
--round(zjje,2) totalAmount,
--zfpb invlidSign,
--0 printSign,
--convert(xml,
--(select 
--	mergingCode,
--	mergingName,
--	sum(amount) mergingAmount,
--	convert(xml,
--	(select
--		b.costName,
--		b.itemNumber,
--		b.price,
--		b.amount,
--		b.unit,
--		b.specifications
--		from V_MOB_PAYMENTDETAIL b where b.paymentSerial = a.paymentSerial and b.mergingCode = a.mergingCode for xml path('costItems')))
--	from V_MOB_PAYMENTDETAIL a 
--	where a.paymentSerial= ms_mzxx.mzxh 
--	group by a.paymentSerial,a.mergingCode,a.mergingName for xml path('mergingItems')))
--from ms_mzxx
--where fphm = '10009' for xml path('data')


	




--就诊详情查询
--select 
--	jzxh visitNo,
--	jzlx visitType,
--	brbh patientCode,
--	convert(varchar(20),kssj ,120) beginVisitTime,
--	convert(varchar(20),jssj ,120) finishVisitTime,
--	ksdm departmentCode,
--	(select ksmc from gy_ksdm where ksdm = ys_mz_jzls.ksdm) departmentName,
--	ysdm doctorCode,
--	(select ygxm from gy_ygdm where ygdm = ysdm ) doctorName,
--	jzzt visitStatus,
--	convert(xml,(select 
--		jlbh diseaseRecordId,
--		jzxh visitNo,
--		brbh patientCode,
--		jbzh diseaseGroupId,
--		znxh sortId,
--		zdlb diseasClass,
--		zdxh diseasId,
--		jbmc diseasName,
--		mszd diseaseDescribe,
--		fjmc additonName,
--		icd icd,
--		qzbz confirm,
--		zfpb invalid
--		from ys_mz_jbzd where jzxh = ys_mz_jzls.jzxh for xml path('diseaseItems')))
--from ys_mz_jzls 
--where jzxh = 53 for xml path('data')


--门诊病历查询

--检查报告查询

--检验报告查询

--处方信息查询
--select 
--cfsb recipeId,
--cfhm recipeNumber,
--mzxh chargeSerial,
--cflx recipeType,
--brid patientCode,
--brxm patientName,
--kfrq recipeDate,
--cfts herbQuentity,
--ksdm departmentCode,
--(select ksmc from gy_ksdm where ksdm = ms_cf01.ksdm) departmentName,
--ysdm doctorCode,
--(select ygxm from gy_ygdm where ygdm = ms_cf01.ysdm) doctorName,
--fybz dispenseSign,
--fyrq dispenseTime,
--fygh dispenseUser,
--(select ygxm from gy_ygdm where ygdm = ms_cf01.fygh) userName,
--zfpb invalidSign,
--yfsb pharmacyId,
--(select yfmc from  yf_yflb where yfsb = ms_cf01.yfsb) pharmacyName,
--cfbz recipeStatus,
--jzxh visitNo,
--djybz boilHerbs,
--djly  recipeSource,
--convert(xml,(
--select 
--	sbxh drugRecordId,
--	cfsb recipeId,
--	ypzh GroupId,
--	plxh sortId,
--	ypxh drugId,
--	(select ypmc from yk_typk where ypxh = ms_cf02.ypxh) drugName,
--	ypcd factoryCode,
--	(select cdmc from yk_cddz where ypcd = ms_cf02.ypcd) factoryName,
--	yfgg specification,
--	ypsl quantity,
--	yfdw unit,
--	yfbz minUnit,
--	ypdj price,
--	xmlx drugType,
--	ycjl dose,
--	(select jldw from yk_typk where ypxh = ms_cf02.ypxh) doseUnit,
--	ypyf frequencyCode,
--	(select pcmc from gy_sypc where pcbm = ms_cf02.ypyf) frequencyName,
--	mrcs daytimes,
--	yyts takeDays,
--	cfts herbsDose,
--	gytj usageCode,
--	(select xmmc from zy_ypyf where  ypyf = ms_cf02.gytj) usage,
--	cfbz tips,
--	fygb feeClass,
--	hjje totalAmount,
--	0 inputDose,
--	'' inputDoseUnit
--	from ms_cf02 where cfsb = ms_cf01.cfsb for xml path('drugItems')))
--from ms_cf01 where cfsb = 216 for xml path('data')

--select * from zy_ypyf

--就诊记录更新

--处方信息更新

--药品字典查询
--未考虑库存冻结
select 
	b.ypxh drugId,
	b.ypmc drugName,
	a.yfgg specification,
	a.yfdw unit,
	a.yfbz minUnit,
	(select type from yk_typk where ypxh = a.ypxh) drugType,
	(select ycjl from yk_typk where ypxh = a.ypxh) dose,
	(select jldw from yk_typk where ypxh = a.ypxh) doseUnit,
	convert(xml,
	(select
		d.ypxh,
		d.ypcd factoryCode,
		(select cdmc from yk_cddz where ypcd = d.ypcd) factoryName,
		sum(d.ypsl) quantity,
		d.lsjg price
	from yf_kcmx d where d.ypxh = a.ypxh and d.yfsb = a.yfsb and d.jgid = a.jgid and jybz = 0 group by d.ypxh,d.ypcd,d.lsjg for xml path('invenrotyInfo'))) invenrotyInfos
from yf_ypxx a,yk_ypbm b
where a.ypxh = b.ypxh
and (a.jgid = b.jgid or b.jgid = 0)
--and a.yfsb = 1
and (b.ypmc + b.pydm) like '葡萄糖氯化钠%'  and a.yfgg like '%500%'
and a.jgid = 1


--for xml path ('data')

--))
--for xml path('root')

--select * from yf_ypxx

select * from yf_ypxx where ypxh = 8465




