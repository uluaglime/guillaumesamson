PRO select_maxima_RVM_offline


;-----------------------------------------------------------------------------------------
; SELECT_MAXIMA_RVM
;
; SELECTIONNE LES POINTS CORRESPONDANT AUX CRITERES UCRIT, VORCRIT ET TEMPCRIT
;
;
; methodology:
; -----------
; 1 - localisation des maxima de vent et de vorticite suivant les criteres choisis
; 2 - determination du nombre de systemes potentiels simultanes 
;     suivant un critere de distance (1000 km) pour les maxima des vents
; 3 - recherche du maximum de vent pour chaque systeme potentiel avec 3 iterations
; 4 - recherche du maximum de vorticite dans un rayon de 100 km autour du maximum de vent avec 3 iterations (3x100km)
; 5 - recherche du minimum de pression dans un rayon de 100 km autour du maximum de vorticite avec 3 iterations (3x100km)
; 6 - calcul du rayon de vent maximum (RVM) defini comme la distance entre le minimum de pression et le maximum de vent
; 7 - definition des zones "innercore" (2 ou 3 RVM) et "environnement" (6 ou 9 RVM) suivant Chauvin 2006 ou Jourdain 2010
; 8 - calcul de l'anomalie de temperature associee
; 9 - si le critere de temperature est rempli, le point est conserve, sinon rejete
;10 - sauvegarde des maxima selectionnes
;
; remarques:
; ---------
; possibilite de conserver ou pas les points sur terre qui remplissent uniquement les critères de vent et de vorticité
; mais dans ce cas on ne cherche pas le minimum de pression (a cause de l'altitude) ni l'anomalie de temperature (RVM deforme)
;-----------------------------------------------------------------------------------------



;-----------------------------------------------------------------------------------------
; PARAMETRES
;-----------------------------------------------------------------------------------------

expname = 'COUPLED_SW2_KF' & help, expname
ucrit    = 17.5   & help, ucrit
vorcrit  = 30.e-5 & help, vorcrit
;tempcrit = 0.5    & help, tempcrit
templist = [0.]



;-----------------------------------------------------------------------------------------
; MASQUE (1 sur terre, 0 sur mer pour WRF) + GRILLE "T"
;-----------------------------------------------------------------------------------------

maskfile = 'mask_wrf.nc'
initncdf,  maskfile, /fullcgrid
mask = ncdf_lec(maskfile, var = 'LANDMASK') & help, mask
lon = float(ncdf_lec(maskfile,var='longitude'))
lat = float(ncdf_lec(maskfile,var='latitude'))
lon2D = lon # replicate(1., n_elements(lat))
lat2D = replicate(1., n_elements(lon)) # lat

; creation d'un nouveau masque "elargi" pour eviter les effets cotiers et les forçages orographiques
newmask = mask
FOR i = 1, n_elements(lon)-2 DO BEGIN
  FOR j = 1, n_elements(lat)-2 DO BEGIN
    IF mask[i,j] EQ 1 THEN BEGIN
      newmask[i-1,j-1] = 1
      newmask[i-1,j  ] = 1
      newmask[i-1,j+1] = 1
      newmask[i,j-1] = 1
      newmask[i,j+1] = 1
      newmask[i+1,j-1] = 1
      newmask[i+1,j  ] = 1
      newmask[i+1,j+1] = 1
    ENDIF
  ENDFOR
ENDFOR
mask = temporary(newmask)



;-----------------------------------------------------------------------------------------
; BOUCLE TEMPORELLE
;-----------------------------------------------------------------------------------------

;momo = ['0106']
;momo = ['0712']
momo = ['0106','0712']

FOR y = 1990, 2009 DO BEGIN
year = strtrim(long(y),2)
FOR m = 0, n_elements(momo)-1 DO BEGIN
month = momo[m]

date = year + month & help, date



;-----------------------------------------------------------------------------------------
; LECTURE FICHIERS NETCDF
;-----------------------------------------------------------------------------------------

IF expname EQ 'COUPLED_SW2_BMJ' THEN BEGIN
  file_in1 = '/Volumes/TIME_MACHINE/EXP_'+ expname +'/VOR800/vor800_'+ strtrim(long(date),2) +'.nc' & help, file_in1
  file_in2 = '/Volumes/TIME_MACHINE/EXP_'+ expname +'/UV10_MSLP/uv10_mslp_'+ strtrim(long(date),2) +'.nc' & help, file_in2
  file_in3 = '/Volumes/TIME_MACHINE/EXP_'+ expname +'/TEMP/TEMP_TRACKER_'+ strtrim(long(date),2) +'.nc' & help, file_in3
  vor800 = ncdf_lec(file_in1,var='vor800') & help, vor800
  tstart = 0 & tend = n_elements(vor800[0,0,*])-1
;  vor800 = read_ncdf('vor800', tstart, tend, TIMESTEP=1, FILENAME=file_in1, /NOSTRUCT) & help, vor800
  u10 = read_ncdf('U10', tstart, tend, TIMESTEP=1, FILENAME=file_in2, /NOSTRUCT) & help, u10
  v10 = read_ncdf('V10', tstart, tend, TIMESTEP=1, FILENAME=file_in2, /NOSTRUCT) & help, v10
  uv10 = (temporary(u10)^2+temporary(v10)^2)^0.5
  mask3D = reform(reform(mask, n_elements(lon)*n_elements(lat))#replicate(1,n_elements(uv10[0,0,*])), n_elements(lon), n_elements(lat), n_elements(uv10[0,0,*]))
  mslp = read_ncdf('PSFC', tstart, tend, TIMESTEP=1, FILENAME=file_in2, /NOSTRUCT)/100. & help, mslp
  mslp[where(temporary(mask3D) EQ 1)] = !values.f_nan
  t700 = read_ncdf('T_700', tstart, tend, TIMESTEP=1, FILENAME=file_in3, /NOSTRUCT) & help, t700
  t500 = read_ncdf('T_500', tstart, tend, TIMESTEP=1, FILENAME=file_in3, /NOSTRUCT) & help, t500
  t300 = read_ncdf('T_300', tstart, tend, TIMESTEP=1, FILENAME=file_in3, /NOSTRUCT) & help, t300
ENDIF

IF expname EQ 'COUPLED_SW2_KF' THEN BEGIN
  file_in1 = '/Volumes/TIME_MACHINE/EXP_'+ expname +'/WRFOUT_TRACKER/WRFOUT_d01_TRACKER_'+ strtrim(long(date),2) +'.nc'
  vor800 = ncdf_lec(file_in1,var='Vort_850') & help, vor800
  tstart = 0 & tend = n_elements(vor800[0,0,*])-1
;  vor800 = read_ncdf('Vort_850', tstart, tend, TIMESTEP=1, FILENAME=file_in1, /NOSTRUCT) & help, vor800
  u10 = read_ncdf('U10', tstart, tend, TIMESTEP=1, FILENAME=file_in1, /NOSTRUCT) & help, u10
  v10 = read_ncdf('V10', tstart, tend, TIMESTEP=1, FILENAME=file_in1, /NOSTRUCT) & help, v10
  uv10 = (temporary(u10)^2+temporary(v10)^2)^0.5
  mask3D = reform(reform(mask, n_elements(lon)*n_elements(lat))#replicate(1,n_elements(uv10[0,0,*])), n_elements(lon), n_elements(lat), n_elements(uv10[0,0,*]))
  mslp = read_ncdf('P1', tstart, tend, TIMESTEP=1, FILENAME=file_in1, /NOSTRUCT) & help, mslp
  mslp[where(temporary(mask3D) EQ 1)] = !values.f_nan
  t700 = read_ncdf('T_700', tstart, tend, TIMESTEP=1, FILENAME=file_in1, /NOSTRUCT) & help, t700
  t500 = read_ncdf('T_500', tstart, tend, TIMESTEP=1, FILENAME=file_in1, /NOSTRUCT) & help, t500
  t300 = read_ncdf('T_300', tstart, tend, TIMESTEP=1, FILENAME=file_in1, /NOSTRUCT) & help, t300
ENDIF



;-----------------------------------------------------------------------------------------
; CREATION AXE TEMPS
;-----------------------------------------------------------------------------------------

date_ini = round(date / 100.) * 100. + 01.00d
juld_ini = date2jul(date_ini)
timejuld = juld_ini + indgen(n_elements(vor800[0,0,*]))*0.25
timedate = jul2date(timejuld)
;print, timedate, format='(f12.2)'



;-----------------------------------------------------------------------------------------
; BOUCLE CRITERES
;-----------------------------------------------------------------------------------------

FOR toto = 0, n_elements(templist)-1 DO BEGIN
tempcrit = templist[toto]  & help, tempcrit

path_data = 'EXP_'+ expname +'/DATA_u'+ strtrim(long(ucrit),2) +'_v'+ strtrim(long(vorcrit*100000),2) +'_t'+ strtrim(long(tempcrit*10),2) +'/'
spawn, 'echo "creation du repertoire '+ path_data +'"'
spawn, 'mkdir -p '+ path_data



;-----------------------------------------------------------------------------------------
; DECLARATIONS + INITIALISATIONS
;-----------------------------------------------------------------------------------------

; format: (pas de temps, nombre de tc simultanes)
uv10cyc  = fltarr(n_elements(vor800[0,0,*]), 20) + !values.f_nan
lonuvcyc = fltarr(n_elements(vor800[0,0,*]), 20) + !values.f_nan
latuvcyc = fltarr(n_elements(vor800[0,0,*]), 20) + !values.f_nan
vorcyc   = fltarr(n_elements(vor800[0,0,*]), 20) + !values.f_nan
lonvorcyc= fltarr(n_elements(vor800[0,0,*]), 20) + !values.f_nan
latvorcyc= fltarr(n_elements(vor800[0,0,*]), 20) + !values.f_nan
mslpcyc  = fltarr(n_elements(vor800[0,0,*]), 20) + !values.f_nan
loncyc   = fltarr(n_elements(vor800[0,0,*]), 20) + !values.f_nan
latcyc   = fltarr(n_elements(vor800[0,0,*]), 20) + !values.f_nan
rvmcyc   = fltarr(n_elements(vor800[0,0,*]), 20) + !values.f_nan
anomtcyc = fltarr(n_elements(vor800[0,0,*]), 20) + !values.f_nan



;-----------------------------------------------------------------------------------------
; BOUCLE TEMPORELLE
;-----------------------------------------------------------------------------------------

FOR t = 0, tend-tstart DO BEGIN
print, ''
print, '----------------------------------------------------------------------------------'
print, '- TIME STEP -', t
print, '----------------------------------------------------------------------------------'



;-----------------------------------------------------------------------------------------
; ETAPE 1
;-----------------------------------------------------------------------------------------

uv10t = uv10[*,*,t]
induvmax = where(uv10t GE ucrit, cntuvmax)
vort = vor800[*,*,t]
indvormax = where(abs(vort) GE vorcrit, cntvormax)
print, 'NOMBRE DE MAX DE VENTS DETECTES:', cntuvmax
print, 'NOMBRE DE MAX DE VORTICITE DETECTES:', cntvormax

IF cntuvmax GT 0 AND cntvormax GT 0 THEN BEGIN

mslpt = mslp[*,*,t]
t700t = t700[*,*,t]
t500t = t500[*,*,t]
t300t = t300[*,*,t]

uv10max  = uv10t[induvmax]
lonuvmax = lon2D[induvmax]
latuvmax = lat2D[induvmax]



;-----------------------------------------------------------------------------------------
; ETAPE 2 & 3
;-----------------------------------------------------------------------------------------

distsep = 1000.
cpt = 0
cntloin = 1

WHILE cntloin GT 0 DO BEGIN

; first guess
  distuv  = reform(map_npoints(lonuvmax[0],latuvmax[0],lonuvmax,latuvmax)/1000.)
  indprox = where(distuv LE distsep, cntprox)
  indloin = where(distuv GT distsep, cntloin)
  uv10cyc[t,cpt]  = max(uv10max[indprox], induv10cyc, /NAN)
  lonuvcyc[t,cpt] = lonuvmax[indprox[induv10cyc]]
  latuvcyc[t,cpt] = latuvmax[indprox[induv10cyc]]
;  print, 'FIRST GUESS:', lonuvcyc[t,cpt], latuvcyc[t,cpt], uv10cyc[t,cpt] 
; second guess
  distuv  = reform(map_npoints(lonuvcyc[t,cpt],latuvcyc[t,cpt],lonuvmax,latuvmax)/1000.)
  indprox = where(distuv LE distsep, cntprox)
  indloin = where(distuv GT distsep, cntloin)
  uv10cyc[t,cpt]  = max(uv10max[indprox], induv10cyc, /NAN)
  lonuvcyc[t,cpt] = lonuvmax[indprox[induv10cyc]]
  latuvcyc[t,cpt] = latuvmax[indprox[induv10cyc]]
;  print, 'SECOND GUESS:', lonuvcyc[t,cpt], latuvcyc[t,cpt], uv10cyc[t,cpt] 
; third guess
  distuv  = reform(map_npoints(lonuvcyc[t,cpt],latuvcyc[t,cpt],lonuvmax,latuvmax)/1000.)
  indprox = where(distuv LE distsep, cntprox)
  indloin = where(distuv GT distsep, cntloin)
  uv10cyc[t,cpt]  = max(uv10max[indprox], induv10cyc, /NAN)
  lonuvcyc[t,cpt] = lonuvmax[indprox[induv10cyc]]
  latuvcyc[t,cpt] = latuvmax[indprox[induv10cyc]]
;  print, 'THIRD GUESS:', lonuvcyc[t,cpt], latuvcyc[t,cpt], uv10cyc[t,cpt]

  cpt = cpt + 1
  IF cntloin GT 0 THEN BEGIN
    uv10max  = uv10max[indloin]
    lonuvmax = lonuvmax[indloin]
    latuvmax = latuvmax[indloin]
  ENDIF

ENDWHILE
print, 'NOMBRE DE MAX DE VENTS CONSERVES:', n_elements(where(finite(uv10cyc[t,*]) EQ 1))



;-----------------------------------------------------------------------------------------
; ETAPE 4
;-----------------------------------------------------------------------------------------

rayonsearch = 100.
vormax = vort[indvormax]
lonvormax = lon2D[indvormax]
latvormax = lat2D[indvormax]

indok = where(finite(lonuvcyc[t,*]) EQ 1, cntok)
FOR i = 0, cntok-1 DO BEGIN

; first guess
  distuvvor = reform(map_npoints(lonvormax,latvormax,lonuvcyc[t,indok[i]],latuvcyc[t,indok[i]])/1000.)
  indprox = where(distuvvor LE rayonsearch, cntprox)
  indloin = where(distuvvor GT rayonsearch, cntloin)
  IF cntprox GT 0 THEN BEGIN
    vorcyc[t,indok[i]] = max(abs(vormax[indprox]), indvorcyc, /NAN)
    lonvorcyc[t,indok[i]] = lonvormax[indprox[indvorcyc]]
    latvorcyc[t,indok[i]] = latvormax[indprox[indvorcyc]]
;    print, 'FIRST GUESS:', lonvorcyc[t,indok[i]], latvorcyc[t,indok[i]], vorcyc[t,indok[i]] 
; second guess   
    distuvvor = reform(map_npoints(lonvorcyc[t,indok[i]], latvorcyc[t,indok[i]], lonvormax,latvormax)/1000.)
    indprox = where(distuvvor LE rayonsearch, cntprox)
    indloin = where(distuvvor GT rayonsearch, cntloin)
    vorcyc[t,indok[i]] = max(abs(vormax[indprox]), indvorcyc, /NAN)
    lonvorcyc[t,indok[i]] = lonvormax[indprox[indvorcyc]]
    latvorcyc[t,indok[i]] = latvormax[indprox[indvorcyc]]
;    print, 'SECOND GUESS:', lonvorcyc[t,indok[i]], latvorcyc[t,indok[i]], vorcyc[t,indok[i]] 
; third guess
    distuvvor = reform(map_npoints(lonvorcyc[t,indok[i]], latvorcyc[t,indok[i]], lonvormax,latvormax)/1000.)
    indprox = where(distuvvor LE rayonsearch, cntprox)
    indloin = where(distuvvor GT rayonsearch, cntloin)
    vorcyc[t,indok[i]] = max(abs(vormax[indprox]), indvorcyc, /NAN)
    lonvorcyc[t,indok[i]] = lonvormax[indprox[indvorcyc]]
    latvorcyc[t,indok[i]] = latvormax[indprox[indvorcyc]]
;    print, 'THIRD GUESS:', lonvorcyc[t,indok[i]], latvorcyc[t,indok[i]], vorcyc[t,indok[i]]   
  ENDIF ELSE BEGIN
    uv10cyc[t,indok[i]]  = !values.f_nan
    lonuvcyc[t,indok[i]] = !values.f_nan
    latuvcyc[t,indok[i]] = !values.f_nan
  ENDELSE

ENDFOR

indok  = where(finite(lonuvcyc[t,*]) EQ 1, cntok)
indnan = where(finite(lonuvcyc[t,*]) EQ 0, cntnan)
IF cntok GT 0 THEN BEGIN
  uv10cyc[t,*]   = [[uv10cyc[t,indok]],[uv10cyc[t,indnan]]]
  lonuvcyc[t,*]  = [[lonuvcyc[t,indok]],[lonuvcyc[t,indnan]]]
  latuvcyc[t,*]  = [[latuvcyc[t,indok]],[latuvcyc[t,indnan]]]
  vorcyc[t,*]    = [[vorcyc[t,indok]],[vorcyc[t,indnan]]]
  lonvorcyc[t,*] = [[lonvorcyc[t,indok]],[lonvorcyc[t,indnan]]]
  latvorcyc[t,*] = [[latvorcyc[t,indok]],[latvorcyc[t,indnan]]]
ENDIF
print, 'NOMBRE DE MAX DE VENTS ASSOCIES A UN MAX DE VORTICITE:', cntok



;-----------------------------------------------------------------------------------------
; ETAPE 5, 6, 7 & 8
;-----------------------------------------------------------------------------------------

rayonsearch = 100.
indok  = where(finite(lonuvcyc[t,*]) EQ 1, cntok)
FOR i = 0, cntok-1 DO BEGIN

IF mask[where(lon EQ lonvorcyc[t,i]),where(lat EQ latvorcyc[t,i])] EQ 0 THEN BEGIN
; first guess
  rayon = reform(map_npoints(lonvorcyc[t,indok[i]], latvorcyc[t,indok[i]], lon2D, lat2D)/1000.)
  indsearch = where(rayon LE rayonsearch, cntsearch)
  mslpcyc[t,indok[i]] = min(mslpt[indsearch], indmslpcyc, /NAN)
  loncyc[t,indok[i]] = lon2D[indsearch[indmslpcyc]]
  latcyc[t,indok[i]] = lat2D[indsearch[indmslpcyc]]
;  print, 'FIRST GUESS:', loncyc[t,indok[i]], latcyc[t,indok[i]], mslpcyc[t,indok[i]]
; second guess
  rayon = reform(map_npoints(loncyc[t,indok[i]], latcyc[t,indok[i]], lon2D, lat2D)/1000.)
  indsearch = where(rayon LE rayonsearch, cntsearch)
  mslpcyc[t,indok[i]] = min(mslpt[indsearch], indmslpcyc, /NAN)
  loncyc[t,indok[i]] = lon2D[indsearch[indmslpcyc]]
  latcyc[t,indok[i]] = lat2D[indsearch[indmslpcyc]]
;  print, 'SECOND GUESS:', loncyc[t,indok[i]], latcyc[t,indok[i]], mslpcyc[t,indok[i]] 
; third guess
  rayon = reform(map_npoints(loncyc[t,indok[i]], latcyc[t,indok[i]], lon2D, lat2D)/1000.)
  indsearch = where(rayon LE rayonsearch, cntsearch)
  mslpcyc[t,indok[i]] = min(mslpt[indsearch], indmslpcyc, /NAN)
  loncyc[t,indok[i]] = lon2D[indsearch[indmslpcyc]]
  latcyc[t,indok[i]] = lat2D[indsearch[indmslpcyc]]
;  print, 'THIRD GUESS:', loncyc[t,indok[i]], latcyc[t,indok[i]], mslpcyc[t,indok[i]] 

  rvmcyc[t,indok[i]] = map_2points(loncyc[t,indok[i]],latcyc[t,indok[i]],lonuvcyc[t,indok[i]],latuvcyc[t,indok[i]], /meters) / 1000.

  IF rvmcyc[t,indok[i]] GE 25. THEN BEGIN

;   version Chauvin 2006
    indcore  = where(rayon LE 2*rvmcyc[t,indok[i]], cntcore)
    indenvi  = where(rayon GT 2*rvmcyc[t,indok[i]] AND rayon LE 6*rvmcyc[t,indok[i]], cntenvi)
;   version Jourdain 2010
;    indcore  = where(rayon LE 3*rvmcyc[t,indok[i]], cntcore)
;    indenvi  = where(rayon GT 3*rvmcyc[t,indok[i]] AND rayon LE 9*rvmcyc[t,indok[i]], cntenvi)

    tempcore = (mean(t700t[indcore], /NAN) + mean(t500t[indcore], /NAN) + mean(t300t[indcore], /NAN)) / 3.
    tempenvi = (mean(t700t[indenvi], /NAN) + mean(t500t[indenvi], /NAN) + mean(t300t[indenvi], /NAN)) / 3.
    anomtcyc[t,indok[i]] = tempcore - tempenvi
;    print, 'COORDONNES DU SYSTEME ', i, ':', loncyc[t,indok[i]], latcyc[t,indok[i]]
;    print, 'RAYON DE VENT MAX DU SYSTEME ', i, ':', rvmcyc[t,indok[i]]
;    print, 'ANOMALIE DE TEMP DU SYSTEME ', i, ':', anomtcyc[t,indok[i]]
  ENDIF ELSE BEGIN
    uv10cyc[t,indok[i]]   = !values.f_nan
    lonuvcyc[t,indok[i]]  = !values.f_nan
    latuvcyc[t,indok[i]]  = !values.f_nan
    vorcyc[t,indok[i]]    = !values.f_nan
    lonvorcyc[t,indok[i]] = !values.f_nan
    latvorcyc[t,indok[i]] = !values.f_nan
    mslpcyc[t,indok[i]]   = !values.f_nan
    loncyc[t,indok[i]]    = !values.f_nan
    latcyc[t,indok[i]]    = !values.f_nan
    rvmcyc[t,indok[i]]    = !values.f_nan
    anomtcyc[t,indok[i]]  = !values.f_nan
  ENDELSE

ENDIF; ELSE BEGIN
;  mslpcyc[t,indok[i]]  = !values.f_nan
;  loncyc[t,indok[i]]   = lonvorcyc[t,indok[i]]
;  latcyc[t,indok[i]]   = latvorcyc[t,indok[i]]
;  rvmcyc[t,indok[i]]   = !values.f_nan
;  anomtcyc[t,indok[i]] = !values.f_nan
;ENDELSE

ENDFOR



;-----------------------------------------------------------------------------------------
; ETAPE 9
;-----------------------------------------------------------------------------------------

indbad = where(anomtcyc[t,*] LT tempcrit, cntbad)
IF cntbad GT 0 THEN BEGIN
  uv10cyc[t,indbad]   = !values.f_nan
  lonuvcyc[t,indbad]  = !values.f_nan
  latuvcyc[t,indbad]  = !values.f_nan
  vorcyc[t,indbad]    = !values.f_nan
  lonvorcyc[t,indbad] = !values.f_nan
  latvorcyc[t,indbad] = !values.f_nan
  mslpcyc[t,indbad]   = !values.f_nan
  loncyc[t,indbad]    = !values.f_nan
  latcyc[t,indbad]    = !values.f_nan
  rvmcyc[t,indbad]    = !values.f_nan
  anomtcyc[t,indbad]  = !values.f_nan
ENDIF



;-----------------------------------------------------------------------------------------
; RANGEMENT
;-----------------------------------------------------------------------------------------

indsort = sort(loncyc[t,*])
mslpcyc[t,*]   = mslpcyc[t,indsort]
loncyc[t,*]    = loncyc[t,indsort]
latcyc[t,*]    = latcyc[t,indsort]
uv10cyc[t,*]   = uv10cyc[t,indsort]
lonuvcyc[t,*]  = lonuvcyc[t,indsort]
latuvcyc[t,*]  = latuvcyc[t,indsort]
vorcyc[t,*]    = vorcyc[t,indsort]
lonvorcyc[t,*] = lonvorcyc[t,indsort]
latvorcyc[t,*] = latvorcyc[t,indsort]
rvmcyc[t,*]    = rvmcyc[t,indsort]
anomtcyc[t,*]  = anomtcyc[t,indsort]

indhs = where(latcyc[t,*] LT 0., cnths)
indhn = where(latcyc[t,*] GT 0., cnthn)
indnan = where(finite(latcyc[t,*]) EQ 0., cntnan)

IF cnths GT 0 AND cnthn GT 0 THEN BEGIN
  mslpcyc[t,*]   = [[mslpcyc[t,indhs]],[mslpcyc[t,indhn]],[mslpcyc[t,indnan]]]
  loncyc[t,*]    = [[loncyc[t,indhs]],[loncyc[t,indhn]],[loncyc[t,indnan]]]
  latcyc[t,*]    = [[latcyc[t,indhs]],[latcyc[t,indhn]],[latcyc[t,indnan]]]
  uv10cyc[t,*]   = [[uv10cyc[t,indhs]],[uv10cyc[t,indhn]],[uv10cyc[t,indnan]]]
  lonuvcyc[t,*]  = [[lonuvcyc[t,indhs]],[lonuvcyc[t,indhn]],[lonuvcyc[t,indnan]]]
  latuvcyc[t,*]  = [[latuvcyc[t,indhs]],[latuvcyc[t,indhn]],[latuvcyc[t,indnan]]]
  vorcyc[t,*]    = [[vorcyc[t,indhs]],[vorcyc[t,indhn]],[vorcyc[t,indnan]]]
  lonvorcyc[t,*] = [[lonvorcyc[t,indhs]],[lonvorcyc[t,indhn]],[lonvorcyc[t,indnan]]]
  latvorcyc[t,*] = [[latvorcyc[t,indhs]],[latvorcyc[t,indhn]],[latvorcyc[t,indnan]]]
  rvmcyc[t,*]    = [[rvmcyc[t,indhs]],[rvmcyc[t,indhn]],[rvmcyc[t,indnan]]]
  anomtcyc[t,*]  = [[anomtcyc[t,indhs]],[anomtcyc[t,indhn]],[anomtcyc[t,indnan]]]
ENDIF

ENDIF; if uvmax existe
ENDFOR; boucle temps



;-----------------------------------------------------------------------------------------
; SAUVEGARDE POINTS SELECTIONNES
;-----------------------------------------------------------------------------------------

print, '----------------------------------------------------------------------------------'
print, '- SAUVEGARDE POINTS SELECTIONNES -'
print, '----------------------------------------------------------------------------------'

save, loncyc, latcyc, mslpcyc, lonuvcyc, latuvcyc, uv10cyc, lonvorcyc, latvorcyc, $
      vorcyc, anomtcyc, rvmcyc, timejuld, timedate, /VERBOSE, $
      filename = path_data +'maxima_RVM_FAB_MASK_u'+ strtrim(long(ucrit),2) +'_v'+ strtrim(long(vorcrit*100000),2) +'_t'+ strtrim(long(tempcrit*10),2) +'_'+ strtrim(long(date),2) +'.idl'


ENDFOR ; liste tempcrit
ENDFOR ; month
ENDFOR ; year

END
