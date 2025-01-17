
------------------
README TRACKER IDL
------------------


3 ETAPES:
--------
  1 - SELECT_MAXIMA : RECHERCHE DES POINTS REMPLISSANT LES CRITERES DE VENT, VORTICITE ET TEMPERATURE
  2 - BUILD_TRACKS  : RECONSTRUCTION DES TRAJECTOIRES A PARTIR DES POINTS RETENUS PAR "SELECT_MAXIMA"
  3 - POST-TRAITEMENT



SELECT_MAXIMA:
-------------
 - 2 VERSIONS: RVM (RAYON DE VENT MAX) OU RGM (RAYON DE GRADIENT MAX) POUR LE CALCUL DE L'ANOMALIE DE TEMPERATURE
 - EN INPUT  : FICHIER NETCDF CONTENANT VENT 10M + VORTICITE 850 OU 800 HPA + PRESSION SURFACE + TEMPERATURE A 700+500+300 HPA
               FICHIER NETCDF CONTENANT MASQUE TERRE-MER + COORDONNES LON-LAT GRILLE "TEMPERATURE"
 - EN OUTPUT : FICHIER IDL AU FORMAT (PAS DE TEMPS, NOMBRE DE POINTS SELECTIONNES)


BUILD_TRACKS :
------------
 - EN INPUT  : FICHIER IDL AU FORMAT (PAS DE TEMPS, NOMBRE DE POINTS SELECTIONNES) ISSU DE "SELECT_MAXIMA"
               FICHIER NETCDF CONTENANT MASQUE TERRE-MER + COORDONNES LON-LAT GRILLE "TEMPERATURE" 
 - EN OUTPUT : FICHIER IDL AU FORMAT (NOMBRE DE CYCLONES, PAS DE TEMPS CYCLONE (200 MAX))


POST-TRAITEMENT :
---------------
 - RECOLLE_MAXIMA : CONCATENATION DES FICHIERS ISSUS DE "SELECT_MAXIMA"
 - RECOLLE_TRACKS : CONCATENATION DES FICHIERS ISSUS DE "BUILD_TRACKS"
 - VIRE_TRACKS    : SELECTION DES TRACKS ISSUS DE "BUILD_TRACKS" SUIVANT DES CRITERES SUPPLEMENTAIRES (GEOGRAPHIQUES, DUREE, INTENSITE,...)
 - CALCUL_STATS   : CALCULE ET PLOT UN TAS DE STATS SUR LES TRAJECTOIRES ISSUS DE "VIRE_TRACKS"
 - INTERPOL_WRF   : INTERPOLATION VERTICALE EN NIVEAU DE PRESSION DES VARIABLES WRF NECESSAIRES AU TRACKER


PLOT :
----
 - PLOT_MAXIMA    : PLOT DES POINTS RETENUS PAR "SELECT_MAXIMA"
 - PLOT_TRAJ_BRUT : PLOT DES TRAJECTOIRES ISSUS DE "BUILD_TRACKS"
 - PLOT_TRAJ_LIGHT: PLOT DES TRAJECTOIRES ISSUS DE "VIRE_TRACKS"
 - PLOT_SCATTER   : SCATTER PLOT DES POINTS RETENUS PAR "SELECT_MAXIMA"