PRO super_ensemble
@all_cm


 exp_path = '/home/gsamson/WORK/AROME/TEST_CPL/'
 plt_path = '/home/gsamson/WORK/IDL/FIGURES/SUPER_ENSEMBLE/'
 tc_list  = [ 'IVAN' , 'GAEL' , 'GELANE' , 'GIOVANNA' , 'FELLENG' ]
; tc_year  = [ '2008' , '2009' , '2010'   , '2012'     , '2013'    ]
 nb_tc    = n_elements(tc_list)
 par_list = [ '2km_ECUME_AROME' , '2km_COARE_AROME' ]
 nb_par   = n_elements(par_list)
 var_list = [ 'errdist' , 'errwind' , 'errwrad' , 'errmslp' , 'err_rmw' , 'err_sst' ]
 unt_list = [ '(km)', '(m/s)' , '(m/s)' , '(hPa)' , '(km)' , '(K)' ]
 nb_var   = n_elements(var_list)
 nb_ech   = 96/6+1


 print, '' & print, 'LECTURE ERROR FILES...' & print, ''
 FOR j = 0, nb_par-1 DO BEGIN

   FOR i = 0, nb_tc-1 DO BEGIN


     ; ERREUR MOYENNE PAR CYCLONE+CRITERE
     tc_name = tc_list[i]
     tc_path = exp_path + 'EXPS_'+STRMID(tc_name,0,4)+STRMID(par_list[j],0,3)+'/'
     exp_name = STRMID(tc_name,0,4)+par_list[j]
     tc_file  = 'MEAN_ERROR_'+exp_name+'.idl'
     print, 'RESTORE: ', tc_path+tc_file
     RESTORE, tc_path+tc_file;, /VERBOSE
     FOR k = 0, nb_var-1 DO cmd = execute( 'help, '+var_list[k]+'_'+exp_name) & print, ''


     ; ERREUR DE TOUS LES MEMBRES PAR CYCLONE+CRITERE
     file_list = FILE_SEARCH(tc_path+'*'+par_list[j]+'*/ERRORS_TC.idl')
     nb_file   = n_elements(file_list)
     FOR k = 0, nb_var-1 DO cmd = execute( 'ALL_'+var_list[k]+'_'+exp_name+' = FLTARR(nb_file,nb_ech) + !VALUES.F_NAN' )
     print, ''
     FOR k = 0, nb_file-1 DO BEGIN    
       obj = OBJ_NEW('IDL_Savefile', file_list[k]) ; & help, obj, /st
       contents = obj->IDL_Savefile::Contents()    ; & help, contents, /st
       IF contents.n_var GE 1 THEN restore_list = obj->IDL_Savefile::Names()
       OBJ_DESTROY, obj
       print, 'RESTORE: ', file_list[k]
       RESTORE, file_list[k];, /VERBOSE
       file_id = STRMID(restore_list[0],9,1)
       FOR l = 0, nb_var-1 DO BEGIN
	 cmd = execute( 'nb_echvar = n_elements('+var_list[l]+'_'+file_id+')' )
	 cmd = execute( 'ALL_'+var_list[l]+'_'+exp_name+'[k,0:nb_echvar-1] = '+var_list[l]+'_'+file_id )
       ENDFOR
     ENDFOR
     FOR k = 0, nb_var-1 DO cmd = execute( 'help, ALL_'+var_list[k]+'_'+exp_name ) & print, ''


     ; VERIF
     print, '' & print, 'VERIFICATION...'
     FOR k = 0, nb_var-1 DO BEGIN
       cmd = execute( var_list[k]+'_'+exp_name+'_VERIF = FLTARR(nb_ech) + !VALUES.F_NAN' )
       FOR l = 0, nb_ech-1 DO BEGIN
         cmd = execute( var_list[k]+'_'+exp_name+'_VERIF[l] = MEAN(ALL_'+var_list[k]+'_'+exp_name+'[*,l], /NAN)' )
       ENDFOR
       cmd = execute( 'test = TOTAL(ROUND('+var_list[k]+'_'+exp_name+'*100.) - ROUND('+var_list[k]+'_'+exp_name+'_VERIF*100.), /PRESERVE_TYPE) ')
       print, 'test =', test
       IF test NE 0 THEN STOP
     ENDFOR
     print, 'VERIFICATION TERMINEE' & print, ''

   ENDFOR ; nb_tc loop


   ; ERREUR DE TOUS LES MEMBRES PAR CRITERE
   print, ''   
   file_list = FILE_SEARCH(exp_path+'EXPS_*'+STRMID(par_list[j],0,3)+'/*'+par_list[j]+'*/ERRORS_TC.idl')
   nb_file   = n_elements(file_list)
   FOR k = 0, nb_var -1 DO cmd = execute( 'ALL_'+var_list[k]+'_'+par_list[j]+' = FLTARR(nb_file,nb_ech) + !VALUES.F_NAN' )
   FOR k = 0, nb_file-1 DO BEGIN    
     obj = OBJ_NEW('IDL_Savefile', file_list[k]) ; & help, obj, /st
     contents = obj->IDL_Savefile::Contents()    ; & help, contents, /st
     IF contents.n_var GE 1 THEN restore_list = obj->IDL_Savefile::Names()
     OBJ_DESTROY, obj
     print, 'RESTORE: ', file_list[k]     
     RESTORE, file_list[k];, /VERBOSE
     file_id = STRMID(restore_list[0],9,1)
     FOR l = 0, nb_var-1 DO BEGIN
       cmd = execute( 'nb_echvar = n_elements('+var_list[l]+'_'+file_id+')' )
       cmd = execute( 'ALL_'+var_list[l]+'_'+par_list[j]+'[k,0:nb_echvar-1] = '+var_list[l]+'_'+file_id )
     ENDFOR
   ENDFOR
   print, ''
   FOR k = 0, nb_var-1 DO cmd = execute( 'help, ALL_'+var_list[k]+'_'+par_list[j] )
   

 ENDFOR
 print, 'LECTURE OK' & print, '' & STOP



 print, '' & print, 'CALCUL MEAN + STD_DEV...'
 FOR i = 0, nb_par-1 DO BEGIN
   FOR j = 0, nb_var-1 DO BEGIN

     ; MOYENNE DES MOYENNES PAR CYCLONES
     mean_list = STRARR(nb_tc)
     FOR k = 0, nb_tc-1 DO mean_list[k] = var_list[j]+'_'+STRMID(tc_list[k],0,4)+par_list[i]+'[k]'; & help, mean_list

     ; MOYENNE DES MOYENNES PAR CYCLONES ISSUE DE VERIF
     mean_list_verif = STRARR(nb_tc)
     FOR k = 0, nb_tc-1 DO mean_list_verif[k] = var_list[j]+'_'+STRMID(tc_list[k],0,4)+par_list[i]+'_VERIF[k]'; & help, mean_list_verif

     ; MOYENNE DE TOUS LES MEMBRES DE TOUS LES CYCLONES
     mean_list_noweight = STRARR(nb_tc)
     FOR k = 0, nb_tc-1 DO mean_list_noweight[k] = 'ALL_'+var_list[j]+'_'+STRMID(tc_list[k],0,4)+par_list[i]+'[*,k]'; & help, mean_list_noweight 

     cmd = execute( 'mean_'+var_list[j]+'_'+par_list[i]+' = FLTARR(nb_ech)' )
     cmd = execute( 'mean_'+var_list[j]+'_'+par_list[i]+'_verif = FLTARR(nb_ech)' )
     cmd = execute( 'mean_'+var_list[j]+'_'+par_list[i]+'_noweight = FLTARR(nb_ech)' )
     cmd = execute( 'mean_'+var_list[j]+'_'+par_list[i]+'_noweight_verif = FLTARR(nb_ech)' )
     cmd = execute( ' std_'+var_list[j]+'_'+par_list[i]+' = FLTARR(nb_ech)' )
     cmd = execute( ' std_'+var_list[j]+'_'+par_list[i]+'_noweight = FLTARR(nb_ech)' )

     FOR k = 0, nb_ech-1 DO BEGIN
       cmd = execute( 'mean_'+var_list[j]+'_'+par_list[i]+'[k] =   mean( ['+STRJOIN(mean_list,', ', /SINGLE)+'], /nan)' )
       cmd = execute( 'mean_'+var_list[j]+'_'+par_list[i]+'_verif[k] = mean( ['+STRJOIN(mean_list_verif,', ', /SINGLE)+'], /nan)' )
       cmd = execute( 'mean_'+var_list[j]+'_'+par_list[i]+'_noweight[k] = mean( ['+STRJOIN(mean_list_noweight,', ', /SINGLE)+'], /nan)' )
       cmd = execute( 'mean_'+var_list[j]+'_'+par_list[i]+'_noweight_verif[k] = mean( ALL_'+var_list[j]+'_'+par_list[i]+'[*,k], /nan)' )
       cmd = execute( ' std_'+var_list[j]+'_'+par_list[i]+'[k] = stddev( ['+STRJOIN(mean_list,', ', /SINGLE)+'], /nan)' )
       cmd = execute( ' std_'+var_list[j]+'_'+par_list[i]+'_noweight[k] = stddev( ['+STRJOIN(mean_list_noweight,', ', /SINGLE)+'], /nan)' )
     ENDFOR

     ; VERIFICATION
     cmd = execute( 'test = TOTAL(ROUND(mean_'+var_list[j]+'_'+par_list[i]+'*100.) - ROUND(mean_'+var_list[j]+'_'+par_list[i]+'_verif*100.), /PRESERVE_TYPE) ')
     print, 'test =', test
     IF test NE 0 THEN STOP
     cmd = execute( 'test_noweight = TOTAL(ROUND(mean_'+var_list[j]+'_'+par_list[i]+'_noweight*100.) - ROUND(mean_'+var_list[j]+'_'+par_list[i]+'_noweight_verif*100.), /PRESERVE_TYPE) ')
     print, 'test_noweight =', test_noweight
     IF test_noweight NE 0 THEN STOP

   ENDFOR
 ENDFOR
 print, ' CALCUL OK' & print, '' & STOP


 print, '' & print, 'TESTS SIGNIFICATIVITE...'
 IF nb_par EQ 2 THEN BEGIN
   FOR i = 0, nb_var-1 DO BEGIN
     cmd = execute( 'TMTEST_'+var_list[i]+' = FLTARR(nb_ech) + !VALUES.F_NAN' )
     cmd = execute( '    NB_'+var_list[i]+' = INTARR(nb_ech)' )
     cmd = execute( 'help, TMTEST_'+var_list[i])
     FOR j = 0, nb_ech-1 DO BEGIN
       cmd = execute( 'indok_0 = WHERE(finite(ALL_'+var_list[i]+'_'+par_list[0]+'[*,j]), nb_ok0)')
       cmd = execute( 'indok_1 = WHERE(finite(ALL_'+var_list[i]+'_'+par_list[1]+'[*,j]), nb_ok1)')
       cmd = execute( '    NB_'+var_list[i]+'[j] = nb_ok0 + nb_ok1' )
       cmd = execute( 'TMTEST_'+var_list[i]+'[j] = (TM_TEST(ALL_'+var_list[i]+'_'+par_list[0]+'[indok_0,j],'+' '+ $
                                                           'ALL_'+var_list[i]+'_'+par_list[1]+'[indok_1,j]))[1]' )
     ENDFOR
     cmd = execute( 'TMTEST_'+var_list[i]+'[WHERE(TMTEST_'+var_list[i]+' LE 0.10, complement=bad)] = 1 & TMTEST_'+var_list[i]+'[bad] = 0' )
     cmd = execute( 'TMTEST_'+var_list[i]+' = FIX(TMTEST_'+var_list[i]+')' )
   ENDFOR
 ENDIF
 print, 'TESTS OK' & print, ''


 print, '' & print, 'PLOTS MOYENNES...'
 lct, 60
 key_portrait=1
 color_factor=70
 write_ps = 0
 IF write_ps THEN thc = 6 ELSE thc = 2
 time = indgen(nb_ech)*6

 ; PLOTS "MOYENNE DE MOYENNES"
 FOR i = 0, nb_var-1 DO BEGIN

   cmd = execute( 'maxplot = max(mean_'+var_list[i]+'_'+par_list[0]+' + std_'+var_list[i]+'_'+par_list[0]+',/nan)' )
   cmd = execute( 'minplot = min(mean_'+var_list[i]+'_'+par_list[0]+' - std_'+var_list[i]+'_'+par_list[0]+',/nan)' )
   FOR j = 1, n_elements(par_list)-1 DO BEGIN
     cmd = execute( 'varmax = mean_'+var_list[i]+'_'+par_list[j]+' + std_'+var_list[i]+'_'+par_list[0] )
     cmd = execute( 'varmin = mean_'+var_list[i]+'_'+par_list[j]+' - std_'+var_list[i]+'_'+par_list[0] )
     maxplot=max([maxplot,varmax],/nan)
     minplot=min([minplot,varmin],/nan)
   ENDFOR
   maxplot = maxplot + 0.05*(maxplot-minplot)
   minplot = minplot - 0.05*(maxplot-minplot)

   IF nb_par EQ 1 THEN plt_name = 'mean_'+var_list[i]+'_'+par_list[0]
   IF nb_par EQ 2 THEN plt_name = 'mean_'+var_list[i]+'_'+par_list[0]+'_vs_'+par_list[1]
   IF nb_par GE 3 THEN plt_name = 'mean_'+var_list[i]
   IF write_ps THEN openps, filename = plt_path + plt_name

   cmd = execute( 'var = mean_'+var_list[i]+'_'+par_list[0] )
   splot, time, var, XTICKINTERVAL=12, xminor=2, yrange=[minplot,maxplot], xrange=[0, max(time)], $
   title='ENSEMBLE MEAN '+STRUPCASE(var_list[i]), xtitle='FORECAST TIME (hours)', thick=1, $
   ytitle=STRUPCASE(var_list[i])+' '+unt_list[i], xgridstyle=2, xticklen=1.0
   oplot, [0,max(time)], [0,0], thick=thc
   FOR j = 0, n_elements(par_list)-1 DO BEGIN
     cmd = execute( 'var = mean_'+var_list[i]+'_'+par_list[j] )
     cmd = execute( 'std =  std_'+var_list[i]+'_'+par_list[j] )
     oplot, time, var, color=color_factor*(j+3) MOD 256, thick=thc
     errplot, time, var-std, var+std, color=color_factor*(j+3) MOD 256, thick=1
     xyouts, 0.120, 0.150-0.020*(j+2), par_list[j], /normal, charsize=1.5, charthick=2, color=color_factor*(j+3) MOD 256
   ENDFOR
   IF nb_par EQ 2 THEN cmd = execute( 'xyouts, time, minplot-0.100*(maxplot-minplot), strtrim(tmtest_'+var_list[i]+',2), charsize=1.5, charthick=2' )
   IF nb_par EQ 2 THEN cmd = execute( 'xyouts, time, minplot-0.125*(maxplot-minplot), strtrim(    nb_'+var_list[i]+',2), charsize=1.5, charthick=2' )
   xyouts, 0.120, 0.150-0.020, 'TC LIST: '+STRJOIN(tc_list,', ', /SINGLE), /normal, charsize=1.5, charthick=2
   xyouts, time[0]-6, minplot-0.100*(maxplot-minplot), 'SIG: ', charsize=1.5, charthick=2, alignment=1
   xyouts, time[0]-6, minplot-0.125*(maxplot-minplot), 'NB: ', charsize=1.5, charthick=2, alignment=1
   IF write_ps THEN closeps ELSE saveimage, plt_path+plt_name, quality=100

 ENDFOR


 ; PLOTS "MOYENNE DE TOUS LES MEMBRES"
  FOR i = 0, nb_var-1 DO BEGIN

   cmd = execute( 'maxplot = max(mean_'+var_list[i]+'_'+par_list[0]+'_noweight + std_'+var_list[i]+'_'+par_list[0]+'_noweight, /nan)' )
   cmd = execute( 'minplot = min(mean_'+var_list[i]+'_'+par_list[0]+'_noweight - std_'+var_list[i]+'_'+par_list[0]+'_noweight, /nan)' )
   FOR j = 1, n_elements(par_list)-1 DO BEGIN
     cmd = execute( 'varmax = mean_'+var_list[i]+'_'+par_list[j]+'_noweight + std_'+var_list[i]+'_'+par_list[0]+'_noweight' )
     cmd = execute( 'varmin = mean_'+var_list[i]+'_'+par_list[j]+'_noweight - std_'+var_list[i]+'_'+par_list[0]+'_noweight' )
     maxplot=max([maxplot,varmax],/nan)
     minplot=min([minplot,varmin],/nan)
   ENDFOR
   maxplot = maxplot + 0.05*(maxplot-minplot)
   minplot = minplot - 0.05*(maxplot-minplot)

   IF nb_par EQ 1 THEN plt_name = 'mean_noweight_'+var_list[i]+'_'+par_list[0]
   IF nb_par EQ 2 THEN plt_name = 'mean_noweight_'+var_list[i]+'_'+par_list[0]+'_vs_'+par_list[1]
   IF nb_par GE 3 THEN plt_name = 'mean_noweight_'+var_list[i]
   IF write_ps THEN openps, filename = plt_path + plt_name

   cmd = execute( 'var = mean_'+var_list[i]+'_'+par_list[0]+'_noweight' )
   splot, time, var, XTICKINTERVAL=12, xminor=2, yrange=[minplot,maxplot], xrange=[0, max(time)], $
   title='ENSEMBLE MEAN (NO WEIGHT) '+STRUPCASE(var_list[i]), xtitle='FORECAST TIME (hours)', thick=1, $
   ytitle=STRUPCASE(var_list[i])+' '+unt_list[i], xgridstyle=2, xticklen=1.0
   oplot, [0,max(time)], [0,0], thick=thc
   FOR j = 0, n_elements(par_list)-1 DO BEGIN
     cmd = execute( 'var = mean_'+var_list[i]+'_'+par_list[j]+'_noweight' )
     cmd = execute( 'std =  std_'+var_list[i]+'_'+par_list[j]+'_noweight' )
     oplot, time, var, color=color_factor*(j+3) MOD 256, thick=thc
     errplot, time, var-std, var+std, color=color_factor*(j+3) MOD 256, thick=1
     xyouts, 0.120, 0.150-0.020*(j+2), par_list[j], /normal, charsize=1.5, charthick=2, color=color_factor*(j+3) MOD 256
   ENDFOR
   IF nb_par EQ 2 THEN cmd = execute( 'xyouts, time, minplot-0.100*(maxplot-minplot), strtrim(tmtest_'+var_list[i]+',2), charsize=1.5, charthick=2' )
   IF nb_par EQ 2 THEN cmd = execute( 'xyouts, time, minplot-0.125*(maxplot-minplot), strtrim(    nb_'+var_list[i]+',2), charsize=1.5, charthick=2' )
   xyouts, 0.120, 0.150-0.020, 'TC LIST: '+STRJOIN(tc_list,', ', /SINGLE), /normal, charsize=1.5, charthick=2
   xyouts, time[0]-6, minplot-0.100*(maxplot-minplot), 'SIG: ', charsize=1.5, charthick=2, alignment=1
   xyouts, time[0]-6, minplot-0.125*(maxplot-minplot), 'NB: ', charsize=1.5, charthick=2, alignment=1
   IF write_ps THEN closeps ELSE saveimage, plt_path+plt_name, quality=100

 ENDFOR

 print, 'PLOTS OK' & print, ''

STOP
END
