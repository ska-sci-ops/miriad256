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
* $Id: log.inc,v 4.25.1.2 2015/01/06 01:02:17 mcalabre Exp mcalabre $
*=======================================================================

*     Functions.
      EXTERNAL  LOGS2X, LOGX2S
      INTEGER   LOGS2X, LOGX2S

*     Error codes and messages.
      INTEGER   LOGERR_BAD_LOG_REF_VAL, LOGERR_BAD_WORLD, LOGERR_BAD_X,
     :          LOGERR_NULL_POINTER, LOGERR_SUCCESS

      PARAMETER (LOGERR_SUCCESS         = 0)
      PARAMETER (LOGERR_NULL_POINTER    = 1)
      PARAMETER (LOGERR_BAD_LOG_REF_VAL = 2)
      PARAMETER (LOGERR_BAD_X           = 3)
      PARAMETER (LOGERR_BAD_WORLD       = 4)

      CHARACTER LOG_ERRMSG(0:3)*80
      COMMON /LOG_DATA/ LOG_ERRMSG
