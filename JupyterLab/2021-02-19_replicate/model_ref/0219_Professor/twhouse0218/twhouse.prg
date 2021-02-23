
%path = @runpath
cd %path
include sub_bootirf_new.prg

'=========================
!shocksign = -1          '     -1 if negative shock, 1 if positive shock
!shock = 1                 '      the !shock-th shock
!hrz = 20                  '      response horizons for IRF
!reps = 2000             '      # of replications in bootstrap
!estirf = 0                 '      0 if median, 1 if actural irf
'=========================

wfcreate(wf=twhouse)  q 1991:1 2020:3
read(b3,s=df_all) df.xls _
R Permit_TW1 Permit_TW2 Permit_TPE1 Permit_TPE2 Permit_TPE3 _
Loan1 Loan2 Loan3 pop_tw1 pop_tw2 pop_tpe1 pop_tpe2 hp_tw hp_tpe Sent
' 隔夜拆款利率(%)	臺閩地區核發建築物建造執照數(件)	 臺閩地區核發H類住宅建照執照戶數(戶)	 臺北市核發建造執照件數(件)	 臺北市核發H類住宅建照執照件數(件)	 臺北市核發H類住宅建照執照戶數(戶)	消費者貸款-購置住宅貸款(新台幣百萬元)	消費者貸款-購置住宅貸款、房屋修繕貸款(新台幣百萬元)	消費者貸款-購置住宅貸款、房屋修繕貸款、建築貸款(新台幣百萬元)	台灣總人口(人)	台灣總戶數(戶)	臺北市總人口(人)	臺北市總戶數(戶)	信義房價指數(台灣)	信義房價指數(臺北市)	Sentiment Index

group data_all _
R Permit_TW1 Permit_TW2 Permit_TPE1 Permit_TPE2 Permit_TPE3 _
Loan1 Loan2 Loan3 pop_tw1 pop_tw2 pop_tpe1 pop_tpe2 hp_tw hp_tpe Sent

freeze(dataplot) data_all.line(m) 

%vname = " Permit_TW1 Permit_TW2 Permit_TPE1 Permit_TPE2 Permit_TPE3 Loan1 Loan2 Loan3 pop_tw1 pop_tw2 pop_tpe1 pop_tpe2 hp_tw hp_tpe"

For %x {%vname}
genr L{%x} = log({%x})
next

genr Y1 = R  ' 隔夜拆款利率(%)
genr Y2 = Sent
genr Y3 = LPermit_TW1 '臺閩地區核發建築物建造執照數(件)
genr Y4 = 100*(Lloan3-Lloan3(-4)) '消費者貸款-購置住宅貸款、房屋修繕貸款、建築貸款(新台幣百萬元), 年增率 	
genr Y5 = 100*(lhp_tw-lhp_tw(-4)) '信義房價指數(台灣), 年增率 


group vargroup Y1 Y2 Y3 Y4 Y5
freeze(vargroupplot) vargroup.line(m)

var test.ls 1 5 vargroup 
	test.laglen(10, vname = vlag)
	!aic = vlag(3)
     !varlag = !aic

 ' Generate VAR estimation with restriction
	var var_hp.ls 1 !varlag vargroup
freeze(imp) var_hp.impulse(se=a)
do var_hp.impulse(!hrz, m, smat=rsp) @imp !shock

' VAR 殘差 
var_hp.makeresids(n=gres) err1 err2 err3 err4 err5

' make model to generate bootstrap data
var_hp.makemodel(bmod1)


' assign add factors for bootstrap residuals
bmod1.addassign(i) @all

'set random number generator
rndseed(type=mt) 23456


'declare storage matrices

for !i=1 to @columns(rsp)
   matrix(!hrz,!reps) brsp{!i}
next

'temporary working vector
vector vtmp

'count number of cases that converged
scalar cnt = 0

 

'bootstrap loop

for !i=1 to !reps

   'bootstrap residuals

   smpl @all if err1<>na

   gres.resample Y1_a Y2_a Y3_a Y4_a Y5_a 

   'generate bootstrap data

  bmod1.solve

   'estimate VAR with bootstrap data

   smpl @all

   var var_boot.ls 1 !varlag  Y1_0 Y2_0 Y3_0 Y4_0 Y5_0 

 
           'increment counter

          cnt = cnt + 1

          'get level and accumulated bootstrap responses

  
          do var_boot.impulse(!hrz, m,  smat=tmp_lvl)  @imp !shock
         

         'and store in appropriate position

          for !j=1 to @columns(rsp)

                  vtmp = @columnextract(tmp_lvl,!j)

                  colplace(brsp{!j}, vtmp, cnt)

             next

          delete tmp_lvl 



next




matrix rsp = rsp*!shocksign


'find bootstrap percentiles for each horizon

matrix(!hrz,@columns(rsp)) bupp
matrix(!hrz,@columns(rsp)) bmedian
matrix(!hrz,@columns(rsp)) blow

rowvector rtmp

for !i=1 to !hrz

   for !j=1 to @columns(rsp)

          rtmp = @rowextract(brsp{!j},!i)*!shocksign

          bupp(!i,!j) = @quantile(rtmp,0.975)
          bmedian(!i,!j) = @quantile(rtmp,0.5)
          blow(!i,!j) = @quantile(rtmp,0.025)

   next

next

 

'plot impulse responses with bootstrap error bounds


if !estirf = 1 then
call sub_bootirf(rsp, bupp, blow, "IRF")
else
call sub_bootirf(bmedian, bupp, blow, "IRF")
endif


' add title to graph
  
 %sname = "Monetary-Polocy Sentiment Supply Demand Specualtion" 
 svector shockname
 shockname = @wsplit(%sname)
 %name =  shockname(!shock)

  IRF.addtext(0.25,-1.5,font(Calibri,30,-b,-i,-u,-s)) {%name} Shock 
  IRF.addtext(0.25,-0.5,font(Calibri,20,-b,-i,-u,-s)) Overnight Rates
  IRF.addtext(8.15,-0.5,font(Calibri,20,-b,-i,-u,-s)) Sentiment
  IRF.addtext(0.25,3.56,font(Calibri,20,-b,-i,-u,-s)) Constrcution Permit
  IRF.addtext(8.15,3.56,font(Calibri,20,-b,-i,-u,-s)) Housing Loan
  IRF.addtext(0.25,8.50,font(Calibri,20,-b,-i,-u,-s)) Housing Loan
  
IRF.align(2,2,1.5)


