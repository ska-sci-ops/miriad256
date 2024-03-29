*=======================================================================
*
* WCSLIB 4.25 - an implementation of the FITS WCS standard.
* Copyright (C) 1995-2015, Mark Calabretta
*
* This file is part of WCSLIB.
*
* WCSLIB is free software: you can redistribute it and/or modify it
* under the terms of the GNU Lesser General Public License as published
* by the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* WCSLIB is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
* FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
* License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with WCSLIB.  If not, see http://www.gnu.org/licenses.
*
* Direct correspondence concerning WCSLIB to mark@calabretta.id.au
*
* Author: Mark Calabretta, Australia Telescope National Facility, CSIRO.
* http://www.atnf.csiro.au/people/Mark.Calabretta
* $Id: wcs.inc,v 4.25.1.2 2015/01/06 01:02:17 mcalabre Exp mcalabre $
*=======================================================================

*     Functions.
      EXTERNAL  WCSBCHK, WCSCOMPARE, WCSCOPY, WCSFREE, WCSGET, WCSGTC,
     :          WCSGTD, WCSGTI, WCSINI, WCSMIX, WCSNPS, WCSNPV, WCSP2S,
     :          WCSPERR, WCSPRT, WCSSPTR, WCSPTC, WCSPTD, WCSPTI,
     :          WCSPUT, WCSS2P, WCSSET, WCSSUB
      INTEGER   WCSBCHK, WCSCOMPARE, WCSCOPY, WCSFREE, WCSGET, WCSGTC,
     :          WCSGTD, WCSGTI, WCSINI, WCSMIX, WCSNPS, WCSNPV, WCSP2S,
     :          WCSPERR, WCSPRT, WCSSPTR, WCSPTC, WCSPTD, WCSPTI,
     :          WCSPUT, WCSS2P, WCSSET, WCSSUB

*     Length of the WCSPRM data structure (INTEGER array) on 64-bit
*     machines.  Only needs to be 416 on 32-bit machines.
      INTEGER   WCSLEN
      PARAMETER (WCSLEN = 474)

*     Codes for WCS data structure elements used by WCSPUT and WCSGET.
      INTEGER   WCS_ALT, WCS_ALTLIN, WCS_CD, WCS_CDELT, WCS_CNAME,
     :          WCS_COLAX, WCS_COLNUM, WCS_CRDER, WCS_CROTA, WCS_CRPIX,
     :          WCS_CRVAL, WCS_CSYER, WCS_CTYPE, WCS_CUNIT, WCS_DATEAVG,
     :          WCS_DATEOBS, WCS_EQUINOX, WCS_FLAG, WCS_LATPOLE,
     :          WCS_LONPOLE, WCS_MJDAVG, WCS_MJDOBS, WCS_NAXIS, WCS_NPS,
     :          WCS_NPSMAX, WCS_NPV, WCS_NPVMAX, WCS_OBSGEO, WCS_PC,
     :          WCS_PS, WCS_PV, WCS_RADESYS, WCS_RESTFRQ, WCS_RESTWAV,
     :          WCS_SPECSYS, WCS_SSYSOBS, WCS_SSYSSRC, WCS_VELANGL,
     :          WCS_VELOSYS, WCS_VELREF, WCS_WCSNAME, WCS_ZSOURCE

      PARAMETER (WCS_FLAG     = 100)
      PARAMETER (WCS_NAXIS    = 101)
      PARAMETER (WCS_CRPIX    = 102)
      PARAMETER (WCS_PC       = 103)
      PARAMETER (WCS_CDELT    = 104)
      PARAMETER (WCS_CRVAL    = 105)
      PARAMETER (WCS_CUNIT    = 106)
      PARAMETER (WCS_CTYPE    = 107)
      PARAMETER (WCS_LONPOLE  = 108)
      PARAMETER (WCS_LATPOLE  = 109)
      PARAMETER (WCS_RESTFRQ  = 110)
      PARAMETER (WCS_RESTWAV  = 111)
      PARAMETER (WCS_NPV      = 112)
      PARAMETER (WCS_NPVMAX   = 113)
      PARAMETER (WCS_PV       = 114)
      PARAMETER (WCS_NPS      = 115)
      PARAMETER (WCS_NPSMAX   = 116)
      PARAMETER (WCS_PS       = 117)
      PARAMETER (WCS_CD       = 118)
      PARAMETER (WCS_CROTA    = 119)
      PARAMETER (WCS_ALTLIN   = 120)
      PARAMETER (WCS_VELREF   = 121)

      PARAMETER (WCS_ALT      = 122)
      PARAMETER (WCS_COLNUM   = 123)
      PARAMETER (WCS_COLAX    = 124)

      PARAMETER (WCS_CNAME    = 125)
      PARAMETER (WCS_CRDER    = 126)
      PARAMETER (WCS_CSYER    = 127)
      PARAMETER (WCS_DATEAVG  = 128)
      PARAMETER (WCS_DATEOBS  = 129)
      PARAMETER (WCS_EQUINOX  = 130)
      PARAMETER (WCS_MJDAVG   = 131)
      PARAMETER (WCS_MJDOBS   = 132)
      PARAMETER (WCS_OBSGEO   = 133)
      PARAMETER (WCS_RADESYS  = 134)
      PARAMETER (WCS_SPECSYS  = 135)
      PARAMETER (WCS_SSYSOBS  = 136)
      PARAMETER (WCS_VELOSYS  = 137)
      PARAMETER (WCS_ZSOURCE  = 138)
      PARAMETER (WCS_SSYSSRC  = 139)
      PARAMETER (WCS_VELANGL  = 140)
      PARAMETER (WCS_WCSNAME  = 141)

*     Codes for WCS data structure elements used by WCSGET (only).
      INTEGER   WCS_CEL, WCS_CUBEFACE, WCS_ERR, WCS_LAT, WCS_LATTYP,
     :          WCS_LIN, WCS_LNG, WCS_LNGTYP, WCS_NTAB, WCS_NWTB,
     :          WCS_SPC, WCS_SPEC, WCS_TAB, WCS_TYPES, WCS_WTB

      PARAMETER (WCS_NTAB     = 200)
      PARAMETER (WCS_NWTB     = 201)
      PARAMETER (WCS_TAB      = 202)
      PARAMETER (WCS_WTB      = 203)
      PARAMETER (WCS_LNGTYP   = 204)
      PARAMETER (WCS_LATTYP   = 205)
      PARAMETER (WCS_LNG      = 206)
      PARAMETER (WCS_LAT      = 207)
      PARAMETER (WCS_SPEC     = 208)
      PARAMETER (WCS_CUBEFACE = 209)
      PARAMETER (WCS_TYPES    = 210)
      PARAMETER (WCS_LIN      = 211)
      PARAMETER (WCS_CEL      = 212)
      PARAMETER (WCS_SPC      = 213)
      PARAMETER (WCS_ERR      = 214)

*     Flag bits for WCSSUB's AXES argument.
      INTEGER WCSSUB_CELESTIAL, WCSSUB_CUBEFACE, WCSSUB_LATITUDE,
     :        WCSSUB_LONGITUDE, WCSSUB_SPECTRAL, WCSSUB_STOKES

      PARAMETER (WCSSUB_LONGITUDE = 4096 +  1)
      PARAMETER (WCSSUB_LATITUDE  = 4096 +  2)
      PARAMETER (WCSSUB_CUBEFACE  = 4096 +  4)
      PARAMETER (WCSSUB_CELESTIAL = 4096 +  7)
      PARAMETER (WCSSUB_SPECTRAL  = 4096 +  8)
      PARAMETER (WCSSUB_STOKES    = 4096 + 16)

*     Flag bits for WCSCOMPARE's CMP argument.
      INTEGER WCSCOMPARE_ANCILLARY, WCSCOMPARE_TILING, WCSCOMPARE_CRPIX

      PARAMETER (WCSCOMPARE_ANCILLARY = 1)
      PARAMETER (WCSCOMPARE_TILING    = 2)
      PARAMETER (WCSCOMPARE_CRPIX     = 4)

*     Error codes and messages.
      INTEGER   WCSERR_BAD_COORD_TRANS, WCSERR_BAD_CTYPE,
     :          WCSERR_BAD_PARAM, WCSERR_BAD_PIX, WCSERR_BAD_SUBIMAGE,
     :          WCSERR_BAD_WORLD, WCSERR_BAD_WORLD_COORD,
     :          WCSERR_ILL_COORD_TRANS, WCSERR_MEMORY,
     :          WCSERR_NON_SEPARABLE, WCSERR_NO_SOLUTION,
     :          WCSERR_NULL_POINTER, WCSERR_SINGULAR_MTX, WCSERR_SUCCESS

      PARAMETER (WCSERR_SUCCESS         =  0)
      PARAMETER (WCSERR_NULL_POINTER    =  1)
      PARAMETER (WCSERR_MEMORY          =  2)
      PARAMETER (WCSERR_SINGULAR_MTX    =  3)
      PARAMETER (WCSERR_BAD_CTYPE       =  4)
      PARAMETER (WCSERR_BAD_PARAM       =  5)
      PARAMETER (WCSERR_BAD_COORD_TRANS =  6)
      PARAMETER (WCSERR_ILL_COORD_TRANS =  7)
      PARAMETER (WCSERR_BAD_PIX         =  8)
      PARAMETER (WCSERR_BAD_WORLD       =  9)
      PARAMETER (WCSERR_BAD_WORLD_COORD = 10)
      PARAMETER (WCSERR_NO_SOLUTION     = 11)
      PARAMETER (WCSERR_BAD_SUBIMAGE    = 12)
      PARAMETER (WCSERR_NON_SEPARABLE   = 13)

      CHARACTER WCS_ERRMSG(0:13)*80
      COMMON /WCS_DATA/ WCS_ERRMSG
