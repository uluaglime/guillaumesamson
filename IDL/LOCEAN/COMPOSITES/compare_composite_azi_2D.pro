PRO compare_composite_2D
@common
computegrid,-200,-200,25,25,17,17


machine = 'cratos'
varlist = ['UV10'];,'T2','Q2'];,'Q2','LH','HFX','OLR','UST','T2','PSFC','GLW','GSW'];'RAINC','RAINNC'
explist = ['KF','BMJ']
typlist = ['WSC','NSC']
azi_dec = 1

basin   = 'SIO'
freq    = '6H'
windbin = [20,60]
datebeg1 = '19900101' & help, datebeg1
dateend1 = '20100101' & help, dateend1
datebeg2 = '19900101' & help, datebeg2
period1  = '1990-2009' & help, period1


FOR iexp = 0, n_elements(explist)-1 DO BEGIN

exp = explist[iexp] & help, exp
expname1 = 'COUPLED_SW2_'+ exp & help, expname1
expname2 = 'FORCED_SW2_'+ exp & help, expname2
IF exp EQ 'KF' THEN period2  = '1990-1998' ELSE period2  = '1990-2009' & help, period2
IF exp EQ 'KF' THEN dateend2 = '19990101'  ELSE dateend2 = '20100101' & help, dateend2

pathin1  = '/net/adonis/usr/adonis/varclim/gslod/IDL/COLLOCALISATION/EXP_'+expname1+'/DATA/' & help, pathin1
restore, pathin1 + 'd1_TRACKS_'+ expname1 +'_IO_'+datebeg1+'-'+dateend1+'.dat', /VERBOSE
d1_lon1 = temporary(d1_lon)
d1_lat1 = temporary(d1_lat)
d1_max_wnd1 = temporary(d1_max_wnd)
IF basin EQ 'SIO'  THEN idom1 = where(d1_lon1 GT 30. AND d1_lon1 LT 130. AND d1_lat1 LT 0.)
IF basin EQ 'SWIO' THEN idom1 = where(d1_lon1 GT 30. AND d1_lon1 LT 80. AND d1_lat1 LT 0.)
IF basin EQ 'SEIO' THEN idom1 = where(d1_lon1 GT 80. AND d1_lon1 LT 130. AND d1_lat1 LT 0.)
IF basin EQ 'NIO'  THEN idom1 = where(d1_lon1 GT 50. AND d1_lon1 LT 100. AND d1_lat1 GT 0.)
IF basin EQ 'NWIO' THEN idom1 = where(d1_lon1 GT 50. AND d1_lon1 LT 80. AND d1_lat1 GT 0.)
IF basin EQ 'NEIO' THEN idom1 = where(d1_lon1 GT 80. AND d1_lon1 LT 100. AND d1_lat1 GT 0.)
iwind1 = where(d1_max_wnd1 GE windbin[0] AND d1_max_wnd1 LE windbin[1]) & help, iwind1
iok1 =  intersect(idom1,iwind1) & help, iok1
ijok1 = array_indices([(size(d1_lon1))[1], (size(d1_lon1))[2]], iok1, /dim)

pathin2  = '/net/adonis/usr/adonis/varclim/gslod/IDL/COLLOCALISATION/EXP_'+expname2+'/DATA/' & help, pathin2
restore, pathin2 + 'd1_TRACKS_'+ expname2 +'_IO_'+datebeg2+'-'+dateend2+'.dat', /VERBOSE
d1_lon2 = temporary(d1_lon)
d1_lat2 = temporary(d1_lat)
d1_max_wnd2 = temporary(d1_max_wnd)
IF basin EQ 'SIO'  THEN idom2 = where(d1_lon2 GT 30. AND d1_lon2 LT 130. AND d1_lat2 LT 0.)
IF basin EQ 'SWIO' THEN idom2 = where(d1_lon2 GT 30. AND d1_lon2 LT 80. AND d1_lat2 LT 0.)
IF basin EQ 'SEIO' THEN idom2 = where(d1_lon2 GT 80. AND d1_lon2 LT 130. AND d1_lat2 LT 0.)
IF basin EQ 'NIO'  THEN idom2 = where(d1_lon2 GT 50. AND d1_lon2 LT 100. AND d1_lat2 GT 0.)
IF basin EQ 'NWIO' THEN idom2 = where(d1_lon2 GT 50. AND d1_lon2 LT 80. AND d1_lat2 GT 0.)
IF basin EQ 'NEIO' THEN idom2 = where(d1_lon2 GT 80. AND d1_lon2 LT 100. AND d1_lat2 GT 0.)
iwind2 = where(d1_max_wnd2 GE windbin[0] AND d1_max_wnd2 LE windbin[1]) & help, iwind2
iok2 =  intersect(idom2,iwind2) & help, iok2
ijok2 = array_indices([(size(d1_lon2))[1], (size(d1_lon2))[2]], iok2, /dim)


FOR ityp = 0, n_elements(typlist)-1 DO BEGIN
var_typ = typlist[ityp] & help, var_typ
FOR ivar = 0, n_elements(varlist)-1 DO BEGIN
var_name = varlist[ivar] & help, var_name

  print, pathin1 + var_name +'_2D_' + expname1 +'_'+freq+'_IO_'+datebeg1+'-'+dateend1+'.dat'
  restore, pathin1 + var_name +'_2D_' + expname1 +'_'+freq+'_IO_'+datebeg1+'-'+dateend1+'.dat', /VERBOSE
  IF var_typ EQ 'WSC' THEN dxy_var1 = temporary(dxy_var_wsc_rot)
  IF var_typ EQ 'NSC' THEN dxy_var1 = temporary(dxy_var_nsc_rot)
  var_1 = fltarr(n_elements(iok1), 17,17)
  FOR itmp = 0, n_elements(iok1)-1 DO var_1[itmp,*,*] = dxy_var1[ijok1[0, itmp], ijok1[1, itmp],*,*]
  varmoy_1 = m_mean(var_1, dim = 1, /nan) & help, varmoy_1
  varstd_1 = fltarr(17,17)
  FOR j= 0, 16 DO FOR i= 0, 16 DO varstd_1[i,j]=stddev(var_1[*,i,j], /nan)

  print, pathin2 + var_name +'_2D_' + expname2 +'_'+freq+'_IO_'+datebeg2+'-'+dateend2+'.dat'
  restore, pathin2 + var_name +'_2D_' + expname2 +'_'+freq+'_IO_'+datebeg2+'-'+dateend2+'.dat', /VERBOSE
  IF var_typ EQ 'WSC' THEN dxy_var2 = temporary(dxy_var_wsc_rot)
  IF var_typ EQ 'NSC' THEN dxy_var2 = temporary(dxy_var_nsc_rot)
  var_2 = fltarr(n_elements(iok2), 17,17)
  FOR itmp = 0, n_elements(iok2)-1 DO var_2[itmp,*,*] = dxy_var2[ijok2[0, itmp], ijok2[1, itmp],*,*]
  varmoy_2 = m_mean(var_2, dim = 1, /nan) & help, varmoy_2
  varstd_2 = fltarr(17,17)
  FOR j= 0, 16 DO FOR i= 0, 16 DO varstd_2[i,j]=stddev(var_2[*,i,j], /nan)

  IF var_name EQ 'Q2'  THEN BEGIN & varmoy_1 = varmoy_1 * 1000. & varmoy_2 = varmoy_2 * 1000. &
  varstd_1 = varstd_1 * 1000. & varstd_2 = varstd_2 * 1000. & var_unit = '(g/kg)' & ENDIF
  IF var_name EQ 'UST' THEN BEGIN & var_unit = '(m/s)' & ENDIF
  IF var_name EQ 'SST' THEN BEGIN & var_unit = '(degC)' & ENDIF
  IF var_name EQ 'LH' THEN BEGIN & var_unit = '(W/m^2)' & ENDIF
  IF var_name EQ 'HFX' THEN BEGIN & var_unit = '(W/m^2)' & ENDIF
  IF var_name EQ 'T2' THEN BEGIN & var_unit = '(degK)'  & ENDIF
  IF var_name EQ 'QS2' THEN var_unit = '(g/kg)'
  IF var_name EQ 'QS0' THEN var_unit = '(g/kg)'
  IF var_name EQ 'QS2-Q2' THEN var_unit = '(g/kg)'
  IF var_name EQ 'Q2-QS0' THEN var_unit = '(g/kg)'
  IF var_name EQ 'T2-SST' THEN var_unit = '(degK)' 
  IF var_name EQ 'OLR' THEN var_unit = '(W/m^2)'
  IF var_name EQ 'UV10' THEN var_unit = '(m/s)'

  vmin = min([min(varmoy_1),min(varmoy_2)])
  vmax = max([max(varmoy_1),max(varmoy_2)])
  smin = min([min(varstd_1),min(varstd_2)])
  smax = max([max(varstd_1),max(varstd_2)])
  vnmin = min([min(varmoy_1/max(abs(varmoy_1))),min(varmoy_2/max(abs(varmoy_2)))])
  vnmax = max([max(varmoy_1/max(abs(varmoy_1))),max(varmoy_2/max(abs(varmoy_2)))])
  snmin = min([min(abs(varstd_1)/max(varstd_1)),min(abs(varstd_2)/max(varstd_2))])
  snmax = max([max(abs(varstd_1)/max(varstd_1)),max(abs(varstd_2)/max(varstd_2))])

  leftfront = where(glamt LE 0 AND gphit GE 0)
  rightfront = where(glamt GE 0 AND gphit GE 0)
  leftrear = where(glamt LE 0 AND gphit LE 0)
  rightrear = where(glamt GE 0 AND gphit LE 0)

  diffvar = varmoy_1-varmoy_2
  diffvarn = varmoy_1/max(abs(varmoy_1)) - varmoy_2/max(abs(varmoy_2))

  pathfig = '/net/'+machine+'/usr/'+machine+'/varclim/gslod/IDL/COLLOCALISATION/FIGS_COMP_'+exp+'/'
  spawn, 'echo "creation du repertoire '+ pathfig +'"' & spawn, 'mkdir -p '+ pathfig  
  lct,39
  plt, varmoy_1/max(abs(varmoy_1)), vnmin, vnmax, title='NORM: '+var_name+' '+var_unit+' - '+var_typ+' - '+expname1, subtitle='min: '+strtrim(min(varmoy_1),2)+' - max: '+strtrim(max(varmoy_1),2), charsize=1., small=[3,1,1], /landscape
  plt, varmoy_2/max(abs(varmoy_2)), vnmin, vnmax, title='NORM: '+var_name+' '+var_unit+' - '+var_typ+' - '+expname2, subtitle='min: '+strtrim(min(varmoy_2),2)+' - max: '+strtrim(max(varmoy_2),2), charsize=1., small=[3,1,2], /noerase
  plt, diffvarn, title='DIFF CPL-FRC: '+var_name+' '+var_unit+' - '+var_typ+' - '+exp, subtitle='min: '+strtrim(min(varmoy_1-varmoy_2),2)+' - max: '+strtrim(max(diffvar),2), charsize=1., small=[3,1,3], /noerase
  
  xyouts, 0.1, 0.7, strtrim(m_mean(varmoy_1[leftfront],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.25, 0.7, strtrim(m_mean(varmoy_1[rightfront],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.1, 0.35, strtrim(m_mean(varmoy_1[leftrear],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.25, 0.35, strtrim(m_mean(varmoy_1[rightrear],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2

  xyouts, 0.4, 0.7, strtrim(m_mean(varmoy_2[leftfront],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.55, 0.7, strtrim(m_mean(varmoy_2[rightfront],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.4, 0.35, strtrim(m_mean(varmoy_2[leftrear],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.55, 0.35, strtrim(m_mean(varmoy_2[rightrear],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2

  xyouts, 0.7, 0.7, strtrim(m_mean(diffvar[leftfront],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.85, 0.7, strtrim(m_mean(diffvar[rightfront],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.7, 0.35, strtrim(m_mean(diffvar[leftrear],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.85, 0.35, strtrim(m_mean(diffvar[rightrear],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2

  xyouts, 0.15, 0.22, 'SAMPLE SIZE: '+strtrim(n_elements(iok1),2), align = 0, /normal, color=0, charsize=1.5
  xyouts, 0.45, 0.22, 'SAMPLE SIZE: '+strtrim(n_elements(iok2),2), align = 0, /normal, color=0, charsize=1.5
  saveimage, pathfig+'composite_norme_2D_'+var_name+'_'+strtrim(windbin[0],2)+'-'+strtrim(windbin[1],2)+'ms_'+var_typ+'_'+exp+'_'+freq+'_'+basin+'.gif', quality=100


  plt, varmoy_1, vmin, vmax, title='COMP: '+var_name+' '+var_unit+' - '+var_typ+' - '+expname1, subtitle='min: '+strtrim(min(varmoy_1),2)+' - max: '+strtrim(max(varmoy_1),2), charsize=1., small=[3,1,1], /landscape
  plt, varmoy_2, vmin, vmax, title='COMP: '+var_name+' '+var_unit+' - '+var_typ+' - '+expname2, subtitle='min: '+strtrim(min(varmoy_2),2)+' - max: '+strtrim(max(varmoy_2),2), charsize=1., small=[3,1,2], /noerase
  plt, diffvar, title='DIFF CPL-FRC: '+var_name+' '+var_unit+' - '+var_typ+' - '+exp, subtitle='min: '+strtrim(min(varmoy_1-varmoy_2),2)+' - max: '+strtrim(max(diffvar),2), charsize=1., small=[3,1,3], /noerase

  xyouts, 0.1, 0.7, strtrim(m_mean(varmoy_1[leftfront],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.25, 0.7, strtrim(m_mean(varmoy_1[rightfront],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.1, 0.35, strtrim(m_mean(varmoy_1[leftrear],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.25, 0.35, strtrim(m_mean(varmoy_1[rightrear],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2

  xyouts, 0.4, 0.7, strtrim(m_mean(varmoy_2[leftfront],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.55, 0.7, strtrim(m_mean(varmoy_2[rightfront],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.4, 0.35, strtrim(m_mean(varmoy_2[leftrear],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.55, 0.35, strtrim(m_mean(varmoy_2[rightrear],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2

  xyouts, 0.7, 0.7, strtrim(m_mean(diffvar[leftfront],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.85, 0.7, strtrim(m_mean(diffvar[rightfront],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.7, 0.35, strtrim(m_mean(diffvar[leftrear],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2
  xyouts, 0.85, 0.35, strtrim(m_mean(diffvar[rightrear],dim=1,/nan),2), align = 0, /normal, color=0, charsize=1.5,charthick=2

  xyouts, 0.15, 0.22, 'SAMPLE SIZE: '+strtrim(n_elements(iok1),2), align = 0, /normal, color=0, charsize=1.5
  xyouts, 0.45, 0.22, 'SAMPLE SIZE: '+strtrim(n_elements(iok2),2), align = 0, /normal, color=0, charsize=1.5
  saveimage, pathfig+'composite_2D_'+var_name+'_'+strtrim(windbin[0],2)+'-'+strtrim(windbin[1],2)+'ms_'+var_typ+'_'+exp+'_'+freq+'_'+basin+'.gif', quality=100


ENDFOR; var
ENDFOR; exp
ENDFOR; typ

END
