PRO plot_sst_vs_didt


; parametres
explist = ['KF']
parlist = ['COUPLED','FORCED']
basin   = 'SIO'
freq    = '6H'
datebeg = '19900101'
var_typ = 'before' ; before / during / after


; definition bin
bin_var  = 'SST'
bin_deb  = 24.
bin_fin  = 32.
bin_size = 1.
bin_unit = 'degC'
bin_num  = (bin_fin - bin_deb) / bin_size  & print, bin_num
bin  = bin_deb+findgen(bin_num)*bin_size
bin_mid = bin_deb + findgen(bin_num)*bin_size+bin_size/2. & print, bin_mid


; declarations
dpresdtint_cpl = fltarr(bin_num, 10000)
dwinddtint_cpl = fltarr(bin_num, 10000)
dpresdtint_frc = fltarr(bin_num, 10000)
dwinddtint_frc = fltarr(bin_num, 10000)
dpresdtdec_cpl = fltarr(bin_num, 10000)
dwinddtdec_cpl = fltarr(bin_num, 10000)
dpresdtdec_frc = fltarr(bin_num, 10000)
dwinddtdec_frc = fltarr(bin_num, 10000)


; lecture best-track
FOR iexp = 0, n_elements(explist)-1 DO BEGIN
exp = explist[iexp] & help, exp
FOR ipar = 0, n_elements(parlist)-1 DO BEGIN
param = parlist[ipar] & help, param
expname = param + '_SW2_'+ exp & help, expname
IF exp EQ 'KF' AND param EQ 'FORCED' THEN period  = '1990-1998' ELSE period  = '1990-2009' & help, period
IF exp EQ 'KF' AND param EQ 'FORCED' THEN dateend = '19990101'  ELSE dateend = '20100101' & help, dateend
pathin  = '/net/adonis/usr/adonis/varclim/gslod/IDL/COLLOCALISATION/EXP_'+expname+'/DATA/' & help, pathin
restore, pathin + 'd1_TRACKS_'+ expname +'_IO_'+datebeg+'-'+dateend+'.dat', /VERBOSE


; lecture sst
restore, pathin + 'SST_1D_'+ expname +'_'+freq+'_IO_'+datebeg+'-'+dateend+'.dat', /VERBOSE
IF var_typ EQ 'before' THEN d1_var = d1_var_before
IF var_typ EQ 'during' THEN d1_var = d1_var_during
IF var_typ EQ 'after'  THEN d1_var = d1_var_after
IF bin_var EQ 'SST' THEN d1_var = d1_var-273.15 & help, d1_var


; calcul index didt
calcul_index_didt24h,d1_pres,d1_max_wnd,ind_int24h,ind_dec24h,d1_wind_smooth_24h,dwinddt,dpresdt,i_int24h,i_dec24h
iokint = ind_int24h[where(finite(d1_var[ind_int24h]) EQ 1)] & help, iokint
iokdec = ind_dec24h[where(finite(d1_var[ind_dec24h]) EQ 1)] & help, iokdec
iokall = [iokint,iokdec] & help, iokall
;iokall = where(finite(d1_var) EQ 1 AND finite(d1_pres) EQ 1 AND finite(d1_wind_smooth_24h) EQ 1) & help, iokall
;iokint = iokint[where(d1_wind_smooth_24h[iokint] GE 25.)] & help, iokint
;iokdec = iokdec[where(d1_wind_smooth_24h[iokdec] GE 25.)] & help, iokdec
;iokall = where(finite(d1_var) EQ 1 AND finite(d1_pres) EQ 1 AND finite(d1_wind_smooth_24h) EQ 1 AND d1_wind_smooth_24h GE 25.) & help, iokall


; declaration
nb_binint = intarr(bin_num)
nb_bindec = intarr(bin_num)
nb_binall = intarr(bin_num)
windint_bin = fltarr(bin_num)
winddec_bin = fltarr(bin_num)
windall_bin = fltarr(bin_num)
presint_bin = fltarr(bin_num)
presdec_bin = fltarr(bin_num)
presall_bin = fltarr(bin_num)
dwinddtint_bin = fltarr(bin_num)
dwinddtdec_bin = fltarr(bin_num)
dwinddtall_bin = fltarr(bin_num)
dpresdtint_bin = fltarr(bin_num)
dpresdtdec_bin = fltarr(bin_num)
dpresdtall_bin = fltarr(bin_num)
dpresdt_intper = fltarr(2,bin_num)
dwinddt_intper = fltarr(2,bin_num)
dpresdt_decper = fltarr(2,bin_num)
dwinddt_decper = fltarr(2,bin_num)
dpresdt_allper = fltarr(2,bin_num)
dwinddt_allper = fltarr(2,bin_num)


; calcul pdf
FOR i = 0, bin_num-2 DO BEGIN
  ibin_int = where(d1_var[iokint] GE bin[i] AND d1_var[iokint] LT bin[i+1])
  ibin_dec = where(d1_var[iokdec] GE bin[i] AND d1_var[iokdec] LT bin[i+1])
  ibin_all = where(d1_var[iokall] GE bin[i] AND d1_var[iokall] LT bin[i+1])
  ; sauvegarde intermediaire
  IF ibin_int[0] NE -1 THEN BEGIN
    IF param EQ 'COUPLED' THEN dpresdtint_cpl[i,0:n_elements(ibin_int)-1] = dpresdt[iokint[ibin_int]] $
    ELSE dpresdtint_frc[i,0:n_elements(ibin_int)-1] = dpresdt[iokint[ibin_int]]
    IF param EQ 'COUPLED' THEN dwinddtint_cpl[i,0:n_elements(ibin_int)-1] = dwinddt[iokint[ibin_int]] $
    ELSE dwinddtint_frc[i,0:n_elements(ibin_int)-1] = dwinddt[iokint[ibin_int]]
  ENDIF
  IF ibin_dec[0] NE -1 THEN BEGIN
    IF param EQ 'COUPLED' THEN dpresdtdec_cpl[i,0:n_elements(ibin_dec)-1] = dpresdt[iokdec[ibin_dec]] $
    ELSE dpresdtdec_frc[i,0:n_elements(ibin_dec)-1] = dpresdt[iokdec[ibin_dec]]
    IF param EQ 'COUPLED' THEN dwinddtdec_cpl[i,0:n_elements(ibin_dec)-1] = dwinddt[iokdec[ibin_dec]] $
    ELSE dwinddtdec_frc[i,0:n_elements(ibin_dec)-1] = dwinddt[iokdec[ibin_dec]]
  ENDIF
  ; moyenne
  IF n_elements(ibin_int) GT 1 THEN windint_bin[i] = mean(d1_wind_smooth_24h[iokint[ibin_int]],/nan)
  IF n_elements(ibin_int) GT 1 THEN presint_bin[i] = mean(d1_pres[iokint[ibin_int]],/nan)
  IF n_elements(ibin_int) GT 1 THEN dwinddtint_bin[i] = mean(dwinddt[iokint[ibin_int]],/nan)
  IF n_elements(ibin_int) GT 1 THEN dpresdtint_bin[i] = mean(dpresdt[iokint[ibin_int]],/nan)
  IF n_elements(ibin_dec) GT 1 THEN winddec_bin[i] = mean(d1_wind_smooth_24h[iokdec[ibin_dec]],/nan)
  IF n_elements(ibin_dec) GT 1 THEN presdec_bin[i] = mean(d1_pres[iokdec[ibin_dec]],/nan)
  IF n_elements(ibin_dec) GT 1 THEN dwinddtdec_bin[i] = mean(dwinddt[iokdec[ibin_dec]],/nan)
  IF n_elements(ibin_dec) GT 1 THEN dpresdtdec_bin[i] = mean(dpresdt[iokdec[ibin_dec]],/nan)
  IF n_elements(ibin_all) GT 1 THEN windall_bin[i] = mean(d1_wind_smooth_24h[iokall[ibin_all]],/nan)
  IF n_elements(ibin_all) GT 1 THEN presall_bin[i] = mean(d1_pres[iokall[ibin_all]],/nan)
  IF n_elements(ibin_all) GT 1 THEN dwinddtall_bin[i] = mean(dwinddt[iokall[ibin_all]],/nan)
  IF n_elements(ibin_all) GT 1 THEN dpresdtall_bin[i] = mean(dpresdt[iokall[ibin_all]],/nan)
  ; percentile
  IF n_elements(ibin_int) GT 1 THEN dpresdt_intper[*,i] = percentile(dpresdt[iokint[ibin_int]],0.25)
  IF n_elements(ibin_int) GT 1 THEN dwinddt_intper[*,i] = percentile(dwinddt[iokint[ibin_int]],0.25)
  IF n_elements(ibin_dec) GT 1 THEN dpresdt_decper[*,i] = percentile(dpresdt[iokdec[ibin_dec]],0.25)
  IF n_elements(ibin_dec) GT 1 THEN dwinddt_decper[*,i] = percentile(dwinddt[iokdec[ibin_dec]],0.25)
  IF n_elements(ibin_all) GT 1 THEN dpresdt_allper[*,i] = percentile(dpresdt[iokall[ibin_all]],0.25)
  IF n_elements(ibin_all) GT 1 THEN dwinddt_allper[*,i] = percentile(dwinddt[iokall[ibin_all]],0.25)
  ; nombre de points par bin
  IF ibin_int[0] NE -1 THEN nb_binint[i] = n_elements(ibin_int) ELSE nb_binint[i] = 0
  IF ibin_dec[0] NE -1 THEN nb_bindec[i] = n_elements(ibin_dec) ELSE nb_bindec[i] = 0
  IF ibin_all[0] NE -1 THEN nb_binall[i] = n_elements(ibin_all) ELSE nb_binall[i] = 0
ENDFOR
print, nb_binall
print, windall_bin, presall_bin

; test significativite
ts_dpresdtint = fltarr(bin_num,2)
ts_dpresdtdec = fltarr(bin_num,2)
ts_dpresdtall = fltarr(bin_num,2)
ts_dwinddtint = fltarr(bin_num,2)
ts_dwinddtdec = fltarr(bin_num,2)
ts_dwinddtall = fltarr(bin_num,2)
IF param EQ 'FORCED' THEN BEGIN
  FOR i = 0, bin_num-2 DO BEGIN
;    iok = where(dpresdtint_cpl[i,*] NE 0 AND dpresdtint_frc[i,*] NE 0, cntok)
;    IF iok[0] NE -1 THEN ts_int[i,*] = RS_TEST(reform(dpresdtint_cpl[i,where(dpresdtint_cpl[i,*] NE 0)]),reform(dpresdtint_frc[i,where(dpresdtint_frc[i,*] NE 0)]))
;    iok = where(dpresdtdec_cpl[i,*] NE 0 AND dpresdtdec_frc[i,*] NE 0, cntok)
;    IF iok[0] NE -1 THEN ts_dec[i,*] = RS_TEST(reform(dpresdtdec_cpl[i,where(dpresdtdec_cpl[i,*] NE 0)]),reform(dpresdtdec_frc[i,where(dpresdtdec_frc[i,*] NE 0)]))
    ts_dpresdtall[i,*] = RS_TEST([reform(dpresdtint_cpl[i,where(dpresdtint_cpl[i,*] NE 0)]),reform(dpresdtdec_cpl[i,where(dpresdtdec_cpl[i,*] NE 0)])], $
                          [reform(dpresdtint_frc[i,where(dpresdtint_frc[i,*] NE 0)]),reform(dpresdtdec_frc[i,where(dpresdtdec_frc[i,*] NE 0)])])
    ts_dwinddtall[i,*] = RS_TEST([reform(dwinddtint_cpl[i,where(dwinddtint_cpl[i,*] NE 0)]),reform(dwinddtdec_cpl[i,where(dwinddtdec_cpl[i,*] NE 0)])], $
                          [reform(dwinddtint_frc[i,where(dwinddtint_frc[i,*] NE 0)]),reform(dwinddtdec_frc[i,where(dwinddtdec_frc[i,*] NE 0)])])
  ENDFOR
ENDIF


GOTO, JUMP1

; plot
IF param EQ 'COUPLED' THEN window,1
IF param EQ 'FORCED' THEN wset,1
iok = where(windint_bin NE 0.)
IF param EQ 'COUPLED' THEN plot, bin_mid[iok],windint_bin[iok], $
xrange=[min(bin_mid),max(bin_mid)],xtitle=bin_unit,ytitle='m.s-1',yrange=[0,40]
IF param EQ 'FORCED' THEN plot, bin_mid[iok],windint_bin[iok],xrange=[min(bin_mid),max(bin_mid)],/noerase,linestyle=2,yrange=[0,40]
IF param EQ 'FORCED' THEN saveimage, 'FIGS_PDF/pdf_sst'+var_typ+'_wind_int_'+exp+'.gif'

IF param EQ 'COUPLED' THEN window,2
IF param EQ 'FORCED' THEN wset,2
iok = where(winddec_bin NE 0.)
IF param EQ 'COUPLED' THEN plot, bin_mid[iok],winddec_bin[iok], $
xrange=[min(bin_mid),max(bin_mid)],xtitle=bin_unit,ytitle='m.s-1',yrange=[0,40]
IF param EQ 'FORCED' THEN plot, bin_mid[iok],winddec_bin[iok],xrange=[min(bin_mid),max(bin_mid)],/noerase,linestyle=2,yrange=[0,40]
IF param EQ 'FORCED' THEN saveimage, 'FIGS_PDF/pdf_sst'+var_typ+'_wind_dec_'+exp+'.gif'

IF param EQ 'COUPLED' THEN window,3
IF param EQ 'FORCED' THEN wset,3
iok = where(presint_bin NE 0.)
IF param EQ 'COUPLED' THEN plot, bin_mid[iok],presint_bin[iok], $
xrange=[min(bin_mid),max(bin_mid)],xtitle=bin_unit,ytitle='hPa',yrange=[950,1000]
IF param EQ 'FORCED' THEN plot, bin_mid[iok],presint_bin[iok],xrange=[min(bin_mid),max(bin_mid)],/noerase,linestyle=2,yrange=[950,1000]
IF param EQ 'FORCED' THEN saveimage, 'FIGS_PDF/pdf_sst'+var_typ+'_pres_int_'+exp+'.gif'

IF param EQ 'COUPLED' THEN window,4
IF param EQ 'FORCED' THEN wset,4
iok = where(presdec_bin NE 0.)
IF param EQ 'COUPLED' THEN plot, bin_mid[iok],presdec_bin[iok], $
xrange=[min(bin_mid),max(bin_mid)],xtitle=bin_unit,ytitle='hPa',yrange=[950,1000]
IF param EQ 'FORCED' THEN plot, bin_mid[iok],presdec_bin[iok],xrange=[min(bin_mid),max(bin_mid)],/noerase,linestyle=2,yrange=[950,1000]
IF param EQ 'FORCED' THEN saveimage, 'FIGS_PDF/pdf_sst'+var_typ+'_pres_dec_'+exp+'.gif'


IF param EQ 'COUPLED' THEN window,5
IF param EQ 'FORCED' THEN wset,5
iok = where(dwinddtint_bin NE 0.)
IF param EQ 'COUPLED' THEN plot, bin_mid[iok],dwinddtint_bin[iok], $
xrange=[min(bin_mid),max(bin_mid)],xtitle=bin_unit,ytitle='m.s-1/6h',yrange=[0,2]
IF param EQ 'FORCED' THEN plot, bin_mid[iok],dwinddtint_bin[iok],xrange=[min(bin_mid),max(bin_mid)],/noerase,linestyle=2,yrange=[0,2]
IF param EQ 'FORCED' THEN saveimage, 'FIGS_PDF/pdf_sst'+var_typ+'_dwinddt_int_'+exp+'.gif'

IF param EQ 'COUPLED' THEN window,6
IF param EQ 'FORCED' THEN wset,6
iok = where(dwinddtdec_bin NE 0.)
IF param EQ 'COUPLED' THEN plot, bin_mid[iok],dwinddtdec_bin[iok], $
xrange=[min(bin_mid),max(bin_mid)],xtitle=bin_unit,ytitle='m.s-1/6h',yrange=[-3,0]
IF param EQ 'FORCED' THEN plot, bin_mid[iok],dwinddtdec_bin[iok],xrange=[min(bin_mid),max(bin_mid)],/noerase,linestyle=2,yrange=[-3,0]
IF param EQ 'FORCED' THEN saveimage, 'FIGS_PDF/pdf_sst'+var_typ+'_dwinddt_dec_'+exp+'.gif'

IF param EQ 'COUPLED' THEN window,7
IF param EQ 'FORCED' THEN wset,7
iok = where(dpresdtint_bin NE 0.)
IF param EQ 'COUPLED' THEN plot, bin_mid[iok],dpresdtint_bin[iok], $
xrange=[min(bin_mid),max(bin_mid)],xtitle=bin_unit,ytitle='hPa/6h',yrange=[-5,-1]
IF param EQ 'FORCED' THEN plot, bin_mid[iok],dpresdtint_bin[iok],xrange=[min(bin_mid),max(bin_mid)],/noerase,linestyle=2,yrange=[-5,-1]
IF param EQ 'FORCED' THEN saveimage, 'FIGS_PDF/pdf_sst'+var_typ+'_dpresdt_int_'+exp+'.gif'

IF param EQ 'COUPLED' THEN window,8
IF param EQ 'FORCED' THEN wset,8
iok = where(dpresdtdec_bin NE 0.)
IF param EQ 'COUPLED' THEN plot, bin_mid[iok],dpresdtdec_bin[iok], $
xrange=[min(bin_mid),max(bin_mid)],xtitle=bin_unit,ytitle='hPa/6h',yrange=[0,5]
IF param EQ 'FORCED' THEN plot, bin_mid[iok],dpresdtdec_bin[iok],xrange=[min(bin_mid),max(bin_mid)],/noerase,linestyle=2,yrange=[0,5]
IF param EQ 'FORCED' THEN saveimage, 'FIGS_PDF/pdf_sst'+var_typ+'_dpresdt_dec_'+exp+'.gif'


IF param EQ 'COUPLED' THEN window,9
IF param EQ 'FORCED' THEN wset,9
iok = where(windall_bin NE 0.)
IF param EQ 'COUPLED' THEN plot, bin_mid[iok],windall_bin[iok], $
xrange=[min(bin_mid),max(bin_mid)],xtitle=bin_unit,ytitle='m.s-1',yrange=[0,40]
IF param EQ 'FORCED' THEN plot, bin_mid[iok],windall_bin[iok],xrange=[min(bin_mid),max(bin_mid)],/noerase,linestyle=2,yrange=[0,40]
IF param EQ 'FORCED' THEN saveimage, 'FIGS_PDF/pdf_sst'+var_typ+'_wind_all_'+exp+'.gif'

IF param EQ 'COUPLED' THEN window,10
IF param EQ 'FORCED' THEN wset,10
iok = where(presall_bin NE 0.)
IF param EQ 'COUPLED' THEN plot, bin_mid[iok],presall_bin[iok], $
xrange=[min(bin_mid),max(bin_mid)],xtitle=bin_unit,ytitle='hPa',yrange=[950,1000]
IF param EQ 'FORCED' THEN plot, bin_mid[iok],presall_bin[iok],xrange=[min(bin_mid),max(bin_mid)],/noerase,linestyle=2,yrange=[950,1000]
IF param EQ 'FORCED' THEN saveimage, 'FIGS_PDF/pdf_sst'+var_typ+'_pres_all_'+exp+'.gif'


JUMP1:

IF param EQ 'COUPLED' THEN window,11
IF param EQ 'FORCED' THEN wset,11
iok = where(dwinddtall_bin NE 0.)
IF param EQ 'COUPLED' THEN plot, bin_mid[iok],dwinddtall_bin[iok], $
xrange=[min(bin_mid),max(bin_mid)],xtitle=bin_unit,ytitle='m.s-1/6h',yrange=[-2,2],linestyle=0,thick=2
IF param EQ 'FORCED' THEN plot, bin_mid[iok],dwinddtall_bin[iok],xrange=[min(bin_mid),max(bin_mid)],/noerase,linestyle=2,yrange=[-2,2],thick=2
oplot, [bin_deb,bin_fin],[0,0]
;oplot, bin_mid[iok],dwinddt_allper[0,iok], linestyle=1
;oplot, bin_mid[iok],dwinddt_allper[1,iok], linestyle=1
;IF param EQ 'COUPLED' THEN xyouts, bin_mid[iok],1.9,strtrim(nb_binall[iok],2)
;IF param EQ 'FORCED' THEN  xyouts, bin_mid[iok],1.8,strtrim(nb_binall[iok],2)
;IF param EQ 'FORCED' THEN  xyouts, bin_mid[iok],1.7,strtrim(ts_dwinddtall[iok,1],2)
IF param EQ 'FORCED' THEN saveimage, 'FIGS_PDF/pdf_sst'+var_typ+'_dwinddt_all_'+exp+'.gif'

IF param EQ 'COUPLED' THEN window,12
IF param EQ 'FORCED' THEN wset,12
iok = where(dpresdtall_bin NE 0.)
IF param EQ 'COUPLED' THEN plot, bin_mid[iok],dpresdtall_bin[iok], $
xrange=[min(bin_mid),max(bin_mid)],xtitle=bin_unit,ytitle='hPa/6h',yrange=[-4,4],linestyle=0,thick=2
IF param EQ 'FORCED' THEN plot, bin_mid[iok],dpresdtall_bin[iok],xrange=[min(bin_mid),max(bin_mid)],/noerase,linestyle=2,yrange=[-4,4],thick=2
oplot, [bin_deb,bin_fin],[0,0] 
;oplot, bin_mid[iok],dpresdt_allper[0,iok], linestyle=1
;oplot, bin_mid[iok],dpresdt_allper[1,iok], linestyle=1
;IF param EQ 'COUPLED' THEN xyouts, bin_mid[iok],3.8,strtrim(nb_binall[iok],2)
;IF param EQ 'FORCED' THEN  xyouts, bin_mid[iok],3.6,strtrim(nb_binall[iok],2)
;IF param EQ 'FORCED' THEN  xyouts, bin_mid[iok],3.4,strtrim(ts_dpresdtall[iok,1],2)
IF param EQ 'FORCED' THEN saveimage, 'FIGS_PDF/pdf_sst'+var_typ+'_dpresdt_all_'+exp+'.gif'


ENDFOR ; par
ENDFOR ; exp

END
