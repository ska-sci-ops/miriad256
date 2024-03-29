c***********************************************************************
      program  uvgen
c
c= UVGEN - Compute visibilities for a model source.
c& rjs
c: uv analysis, map making
c+
c       UVGEN is a MIRIAD task which computes visibility data for a
c       model source distribution at u-v data points specified by a set
c       of antenna positions, hour angle range and sample interval.  The
c       model is specified by a set of Gaussian sources with given
c       positions and flux densities.  Analytic expressions are used to
c       calculate the value of the visibilities.  The calculation
c       includes the response to polarized sources with linear and
c       circularly polarized feeds.  U-V trajectories for all pairs of
c       antennas are computed.
c@ source
c       The name of a text file containing the source components, one
c       component per line.  There is no default.  The source components
c       are elliptical Gaussian components.  Each line consists of at
c       least three and up to ten values:
c         flux,dra,ddec,bmaj,bmin,bpa,iflux,ipa,vflux
c       where
c         flux:          Total flux in Jy.
c         dra,ddec:      Position offset from the phase center in
c                        arcsec.
c         bmaj,bmin,bpa: The full width to half maximum of the major and
c                        minor axes, and the position angle of the major
c                        axis measured from north to the east.  The
c                        default half width is 0."0001.
c         iflux,ipa:     The sources can be partially linearly
c                        polarized.  This information is given as a
c                        percentage polarization and position angle.
c                        The default is 0.
c         vflux:         Percentage circular polarization.  The default
c                        is 0.
c         alpha:         Spectral index. The default is 0.
c       The text file is free-format, with commas or blanks used to
c       separate the values.  Comments (starting with #) can be included
c       in the file.
c@ ant
c       The name of a text file containing the position of the antennas.
c       There is no default.  Each line of the text file gives three
c       values, being the x, y and z location of an antenna.  The
c       antenna positions can be given in either a right handed
c       equatorial system or as a local ground based coordinates
c       measured to the north, east and in elevation.  See the
c       "baseunit" parameter to specify the coordinate system.  Some
c       standard antenna configurations can be found in $MIRCAT/*.ant
c       for ATCA, BIMA and VLA telescopes.  The BIMA and VLA antenna
c       tables, use with baseunit=1, whereas for the ATCA, use
c       baseunit=-51.0204.
c
c       The text file is free-format, with commas or blanks used to
c       separate the values.  Comments (starting with #) can be included
c       in the file.
c@ baseunit
c       This specifies the coordinate system used in the antenna file.
c       A positive value for "baseunit" indicates an equatorial system,
c       whereas a negative value indicates a local system.  The
c       magnitude of "baseunit" gives the conversion factor between the
c       baseline units used in the antenna file, and nanoseconds.  The
c       default value is +1, which means that the antenna file gives the
c       antenna position in an equatorial system measured in nanosec.
c       E.g.    baseunit=-1 for topocentric coordinates in nanosec,
c               baseunit=3.33564 for geocentric coordinates in metres.
c@ telescop
c       This parameter determine the feed angle variation (i.e. the
c       parallactic angle plus the feed offset angle - evector).  It is
c       also used to set the name of the telescop variable in the output
c       dataset.  If can take two values, the first gives the antenna
c       mount type, and can be "altaz", "xyew", or "equatorial".  The
c       second value gives the feed offset angle ("evector") in degrees.
c       The default is 0.
c
c       Alternatively, you can give the name of a known telescope for
c       this parameter.  In this case, the mount type and feed offset
c       angle will be that of that particular telescope.
c
c       The default value is "hatcreek" (which is equivalent to
c       "altaz,0").
c@ corr
c       Defines the correlator setup.  The values are:
c         nchan:       Number of channels in each spectral window.
c                      Use 0 for a wideband only file.
c         nspect:      Number of spectral windows.  Default 1; max 4.
c         f1,f2,...:   "nspect" values giving the offset for the center
c                      frequency of each window, in MHz.  Default 0.
c         df1,df2,...: "nspect" values giving the total widths of each
c                      spectral window, in MHz.  Default 1000.
c       No checking is made for valid combinations.
c       Default is wideband only for each spectral window.
c@ spectra
c       Model a Gaussian spectral line.
c       The spectral line model line consists of three values:
c         famp:        The line to continuum ratio
c         fcen:        Line freq (GHz)
c         fwid:        Line width (GHz).
c       Default is no spectral line.
c@ time
c       The time of the observation (corresponding to ha=0) in the form
c         yymmmdd.ddd
c       or
c         yymmmdd:hh:mm:ss.s
c       The default is 80JAN01.0.  A function of this is also used
c       as a seed for the random number generator.
c@ freq
c       Frequency and IF frequency in GHz.
c       Defaults are 100,0.0 GHz.
c@ radec
c       Source right ascension and declination.  These can be given in
c       hh:mm:ss,dd:mm:ss format, or as decimal hours and decimal
c       degrees.  The default is 0,30.
c@ harange
c       Hour Angle range (start,stop,step) in hours.  Default is
c       -6 hrs to + 6 hrs, with a sample interval=0.1 (6 minute)
c@ ellim
c       Elevation limit in degrees.  The default is not to limit
c       uv coverage by elevation.  If set, then hour angles below the
c       limit are not "observed".
c@ stokes
c       This selects the polarization parameters formed.  Up to 4
c       polarizations can be formed in one run.  They can be 'i'
c       (default), 'xx', 'yy', 'xy', 'yx, 'lr', 'rl', 'rr' or 'll'.
c       For example:
c         stokes=xx,yy,xy,yx
c       will form a file with the 4 polarisations corresponding to an
c       array with linear feeds.  For linear feeds the convention is
c       that the X feed has a position angle of 0, and the Y feed is
c       90 (measured north towards east).
c@ polar
c       Polarization patterns for generating time shared polarization
c       data.  Up to MAXPOLAR=20 strings of the characters R and L, or X
c       and Y, to represent the polarization of each antenna R (right
c       circular polarization), L (left circular polarization) X (linear
c       polarization PA=0), Y (linear polarization PA=90).  E.g. for 3
c       antennas, the polar=LLL,LRR,RRL,RLR cycles through all
c       combinations of LCP and RCP for each baseline every 4
c       integrations.  The default is to use the stokes keyword.
c@ leakage
c       Polarization leakage errors, given as a percent.  This gives the
c       rms value of leakages of one polarisation feed into another.
c       Polarization leakage errors are constant over the observation.
c       To use this, you must set
c         stokes=xx,yy,xy,yx
c       or
c         stokes=rr,ll,rl,lr
c       The default is 0 (i.e. no polarization leakage).
c@ zeeman
c       Zeeman effect; the keyword gives the product B * Z, where,
c          Stokes V = B * Z * dI/dnu + Leakage * I
c          B = line of sight field, and Z = Zeeman splitting term.
c       This generates a circular polarization for a spectral line.
c       Default = 0.
c@ lat
c       Latitude of observatory, in degrees.  Default is 40 degrees.
c@ cycle
c       This gives two values, being the time on-source, and the time
c       off-source cycle times, both in hours.  This allows simulation
c       of time segments lost while observing calibrators, etc.  For
c       example, if simulating an observation which observes the source
c       for 24 minutes and then is off-source (observing a calibrator)
c       for 6 minutes, use:
c         cycle=0.4,0.1
c       Similarly, if simulating this calibrator, use:
c         cycle=0.1,0.4
c       The default is harange(3),0 (i.e. do not interrupt the
c       observations).
c@ pbfwhm
c       This dictates the primary beam model used in the simulation.  It
c       gives the FWHM of a gaussian primary beam, in arcsec.
c       The default is no primary beam attenuation.
c@ center
c       Offset observing centers for a mosaiced observation, in arcsec
c       Two values (x and y offset) are required per pointing.  Several
c       values can be given.  Default is 0,0 (i.e. a plain, single
c       pointing observation).  The time spent on each pointing is given
c       by the value of "cycle(1)".  Note that the default value of
c       cycle(1) means that the observing center changes every
c       integration.
c@ gnoise
c       Antenna based gain noise, given as a percentage.  This gives the
c       multiplicative gain variations, specified by the rms amplitude
c       to be added to the gain of each antenna at each sample interval.
c       The gain error stays constant over the period given by the
c       "cycle(1)" parameter (see above).  Thus "cycle(1)" can be varied
c       to give different atmosphere/instrument stabilities.  Note that
c       the default of the "cycle" parameter means that the gain changes
c       every integration.
c
c       A gain error can also be used to mimic random pointing errors
c       provided the source is a point source.
c       The default is 0 (i.e. no gain error).
c@ pnoise
c       Antenna based phase noise, in degrees.  This gives the phase
c       noise, specified by the rms phase noise to be added to each
c       antenna.  Up to 4 values can be given to compute the phase noise
c         pnoise(1) + pnoise(2)*(baseline)**pnoise(3)*sinel**pnoise(4)
c       where ``baseline'' is the baseline length in km.  Typical values
c       for pnoise(2) are 1mm rms pathlength (e.g. 2 radians at 100GHz),
c       For Kolmogorov turbulence pnoise(3)=5/6 for baseline < 100m
c       and 0.33 for baseline > 100m (outer scale of turbulence).
c       pnoise(4)=-0.5 for a thick turbulent screen, and -1 for a thin
c       layer.  See also the ``gnoise'' parameter.  Default is 0,0,0,0
c       (i.e. no phase error).
c@ systemp
c       System temperature used to compute additive random noise and
c       total power.  One or 3 values can be given; either the average
c       single sideband systemp including the atmosphere (TELEPAR gives
c       typical values), or the double sideband receiver temperature,
c       sky temperature, and zenith opacity, when systemp is computed
c       as:
c         systemp = 2.*(Trx + Tsky*(1-exp(-tau/sinel)))*exp(tau/sinel)
c       where systemp, Trx and Tsky are in Kelvin.  Typical values for
c       Hat Creek Trx, Tsky, and tau are 75,290,0.15.  (OBSTAU gives
c       values for tau).  systemp is used to generate random Gaussian
c       noise to add to each data point.  Default is 0,0,0 (i.e. no
c       additive noise).
c@ tpower
c       Two values can be given to represent the total power variations
c       due to receiver instability (Trms), and atmospheric noise
c       (Tatm):
c          tpower = Trms * systemp +  Tatm * pnoise
c       The receiver instablity is modeled as multiplicative Gaussian
c       noise.  The atmospheric noise is modeled to be correlated with
c       the antenna phase noise.  Typical values at 3mm wavelength are
c       Trms = 0.001 and Tatm = 0.2 K/radian (280 degrees/K).
c       Default is tpower=0,0
c@ jyperk
c       The system sensitivity, in Jy/K.  Its value is given by
c       2*k/(eta * A) where k is Boltzmans constant (1.38e3 Jy m**2/K),
c       A is the physical area of each antenna (pi/4 * D**2), and eta is
c       an efficiency.  For the ATCA, D is 22 metres, and eta is
c       composed of a correlator efficiency (0.88) and an antenna
c       efficiency (0.65 at 6 cm).  The overall result is jyperk=12.7.
c       The default jyperk=150, a typical value for the Hat Creek 6.1m
c       antennas.
c@ options
c       A number of options can be specified, separated by commas.
c         'leakfvar' Add linear variation of leakage parameters across
c                    each spectral window
c         'delay'    Add delay noise instead of phase noise, i.e., make
c                    the phases vary with frequency
c         'bandpass' Add a semi random bandpass function to the spectra
c@ out
c       This gives the name of the output Miriad data file.  There is
c       no default.  If the dataset exists, visibilities are appended to
c       the dataset, with an appropriate informational message.
c--
c  UVGEN computes model visibility data from source components file
c  and antennas file.
c
c  History:
c    jan84 mchw  with polarization and new record format.
c    feb85 mchw  record, only 1st 3 baselines are in header
c    dec85 mchw  convert visibilities to Jy
c    mar86 mchw  allow up to 27 antennas
c    mar88 mchw  calculate model visibility separately for each
c                frequency in subroutine MODINT
c    mar88 mchw  antenna based amplitude and phase noise
c    nov88 wh    converted to mirth
c    6apr89 wh    write out new miriad variables
c    10apr89 rjs   Fixed bugs to do with confusing double and real
c                     variables.  Broke some lines up so they are less
c                     than 72 chars.  Declared variables.
c    28sep89 mchw  Write wideband data option, made baseout double,
c                     Fixed output to terminal, changed name to uvgen.
c    25oct89 rjs   Fixed bug to do with putvrd(..,uvout).  Corrected
c                     alignment problem in the common block.
c    31oct90 mchw  Moved some telescope dependent parameters into CORAM.
c     7nov90 rjs   Clean up, and addition of the "site" keyword, to
c                     simplify simulation of other telescopes.  Improved
c                     documenation.
c    13nov90 rjs   More tidying.
c    28nov90 mchw  Minor patches and bugs.
c    05dec90 mchw  Added total power, and keywords harange and out.
c                  Allowed filenames as specified in doc.
c     4feb91 rjs   Allow the user to input the start observing time.
c                  This observing time is used as random number seed as
c                  well.
c    20mar91 rjs   Fixed bugs in coramoth when there is channel data.
c                  Some work on documentation.
c    22mar91 rjs   Fixed  bug dealing with point source.
c    17apr91 rjs   Used uvwwrite to write out wide data.
c    23may91 rjs   Added polarisation leakage terms, "cycle", and
c                  rise/set time warning.
c    29may91 nebk  Fix call to HANGLE
c    11jun91 rjs   Changed linear polarisation feeds sign convention.
c    17jun91 rjs   More sign convention fiddling.
c     1jul91 rjs   Leakage parameters depend on the random number
c                  generator seed now.
c     7jul91 rjs   Changes to the doc only.
c    04aug91 mjs   Replaced local maxant with maxdim.h value MAXANT and
c                  renamed local maxchan to avoid conflict with MAXCHAN
c    05aug91 rjs   Corrected various bugs introduced with MAXANT change.
c    19sep91 rjs   Changes to the doc.
c    20nov91 rjs   Added ability to have multiple pointings and primary
c                  beam.
c    16jun92 rjs   Doc change only.
c    23jun92 rjs   More doc changes.
c    26jun92 rjs   Save latitud and longitu variables.
c    03feb93 edg/pjt  Optional reading in of IF freq for Hat Creek only
c    04feb93 pjt   Merged the option to append output to out=
c    12feb93 mchw  Changed ra and dec to double precision.
c    29mar93 rjs   Fiddles with noise level.  Better documentation on
c                  it.
c    08jul93 mchw  Fix bug in start time.
c    21jul93 rjs   Fiddles with noise levels for Stokes parameters.
c    26oct93 rjs   Use keyt and correct calculations of u,v when doing
c                  mosaiced experiment.
c    03mar94 mchw  Added elevation limit.  Standard keywords dec and
c                  elev.  Generalize hybrid correlator model.
c    18aug94 rjs   Exact geometry for point sources, and better
c                  geometry for other sources.
c    29aug94 rjs   Write w axis value.
c    15sep94 mchw  Change the site keyword to be the 'telescop'
c                  uv-variable.
c    21sep94 mchw  Better value for sfreq in coramhat.
c    28sep94 rjs   Merge mchw/rjs changes.
c    19jan95 mchw  Added atmospheric phase model to pnoise input.
c    25jan95 mchw  Fix bug (lst = ha + ra)
c    27nov95 mchw  Correct sign of source position angle.
c    27nov95 rjs   (Re-)add some commas to appease g77.
c    20dec95 mchw  Added polarization switching.
c    04jun96 mchw  Doc change only.
c     5jun96 pjt   Better setting of random number seed
c    06jun96 rjs   Fiddles to make lst and longitude more honest.
c    10jun96 mchw  Atmospheric and elevation dependent systemp and
c                  tpower.
c    10jul96 mchw  No default for output uv-data file.
c    16aug96 rjs   Change phase convention for circularly polarised
c                  data.
c    25aug97 rjs   General tidy up.
c    09oct97 rjs   Fix error in generating spectral datasets (introduced
c                  7 weeks ago).
c    02nov97 rjs   Change in calling sequence to tinOpen.
c    07may98 mchw  Add circular polarization to source model.
c    17may98 mchw  Add Gaussian spectral line and Zeeman keyword.
c    27may98 mchw  Replace correlator file with keywords.
c    01jul98 mchw  Added pbfwhm parameters to simulate primary beams.
c                       Fixed some errors in rms noise calculations.
c    12jan99 rjs   Doc changes only.
c     9may00 rjs   Write primary beam type out correctly.
c    17may00 mchw  allow for saturated spectral absorption model.
c    18may00 rjs   Merge rjs/mchw changes.
c    27oct00 rjs   Call antbas to compute baseline number.
c    22may01 dpr   Marginal XY-EW support
c    08dec02 rjs   Fixed bug in determining whether source is up or not.
c    13mar05 rjs   Add antenna azimuth and elevation to output dataset.
c    01jan07 rjs   Parameterise number of windows than this can handle.
c                  Tidy up messages.
c    05apr11 mhw   Change epoch to J2000
c    01aug11 mhw   Add variation with frequency in phase and leakage,
c                  bandpass and spectral index.
c
c  Bugs/Shortcomings:
c    * Frequency and time smearing is not simulated.
c    * Primary beam is a gaussian -- which is too ideal.
c    * Primary beam is not a function of frequency.
c    * Geometry for extended sources could be improved.
c
c  The following is the documentation for the unimplemented 2-gaussian
c  beam.
c
c@ pbfwhm
c       A primary beam pattern may be specified by three values: the
c       FWHM for two concentric Gaussian beams, and the fraction of the
c       amplitude in the second beam, i.e. the primary beam pattern is
c               (1-fraction)*Gauss(FWHM1) + fraction*Gauss(FWHM2)
c       The default is an infinite primary beam (no primary beam
c       effects).  A single value specifies a single Gaussian FWHM in
c       arcsec.  The value of this will be approximately
c       66000/(diam*freq), where "diam" is the antenna diameter in
c       metres, and "freq" is the observing frequency.
c       Two more parameters can be used to simulate a primary beam with
c       an error beam, or the primary beam pattern which results from an
c       interferometer using two different antenna diameters.
c       E.g. pbfwhm=60,480,0.1 simulates a primary beam pattern with an
c       error beam with FWHM=480'' and 10% of the amplitude of the main
c       beam.  pbfwhm=76,137,-0.2 simulates a primary beam pattern
c       between 10m and 6m antennas at 100 GHz.
c-----------------------------------------------------------------------
      integer MW
      parameter(MW=4)
      character version*(*)
      parameter(version = 'Uvgen: $Revision: 1.10 $, '//
     *  '$Date: 2018/12/04 04:02:11 $')
      integer ALTAZ,EQUATOR,XYEW
      parameter(ALTAZ=0,EQUATOR=1,XYEW=3)
      integer PolRR,PolLL,PolRL,PolLR,PolXX,PolYY,PolXY,PolYX
      parameter(PolRR=-1,PolLL=-2,PolRL=-3,PolLR=-4)
      parameter(       PolXX=-5,PolYY=-6,PolXY=-7,PolYX=-8)

      include 'mirconst.h'
      include 'maxdim.h'
      include 'uvgen.h'

      real corfin(MW),corbw(MW),zeeman
      complex vis,modI,oldI,gradI,gain(2,MAXANT),leak(4,MAXANT)
      complex wcorr(maxspect,maxpol),chan(MAXCHAN,maxpol)
      real wsignal(maxspect),tpower(MAXANT),pnoise(2,MAXANT)
      logical flags(MAXCHAN)
      logical donoise,dogains,doleak,dopoint,dofleak,dodelay,doband
      real sind,cosd,sinl,cosl,sinel,flux,dra,ddec
      double precision freq,iffreq,dtemp,rfreq
      real wmaj,wmin,wpa,poln,polpa,polvv,alp,x,z,h,sinha,cosha,ha,haend
      double precision antaz,antel
      double precision bxx,byy,bzz,bxy,byx
      real pbfwhm(3),center(2,MAXPNT),evector
      integer mount
      character telescop*16
      integer n,nant,npnt,ipnt,i,jj,m,is,ic,nchan,nospect
      double precision preamble(5),timeout
      real b1(MAXANT),b2(MAXANT),b3(MAXANT),temp,psi,sinq,cosq,leakrms
      real systemp(MAXANT*maxspect),inttime
      double precision restfreq(maxspect),lst
      double precision antpos(3*MAXANT),ra,dec
      integer item, unit
      character line*132, umsg*80
      complex gatm
      real baseline,patm,pslope,pelev,xx,xxamp
      logical doatm,dopolar,doellim,ok
c
c  Parameters from the user.
c
      character sfile*64,antfile*64,outfile*64
      real hbeg, hend, hint, arms, prms, utns
      real tsys,tsky,tau,trms,tatm,cycleon,cycleoff
      double precision alat,along,sdec,sra,elev
      integer pol(maxpol),npol,ipol,npolar,ipolar
      character polar(MAXPOLAR)*27,xpolar*27
c     character polar(MAXPOLAR)*MAXANT,xpolar*MAXANT
c
c  Variables describing the source.
c
      integer ns
      real ta(maxsrc),sx(maxsrc),sy(maxsrc),smaj(maxsrc),smin(maxsrc)
      real spa(maxsrc),per(maxsrc),pa(maxsrc),polv(maxsrc),alpha(maxsrc)
      real smajd(maxsrc),smind(maxsrc),tad(maxsrc),sxd(maxsrc),
     *     syd(maxsrc),szd(maxsrc)
c
c  Model spectra and noise.
c
      real famp, fcen, fwid
      real wrms(maxspect,maxpol), rrms(MAXCHAN,MAXPOL),jyperk
c
c  Externals.
c
      complex expi
      real rang
      integer PolsP2C,len1,tinNext
      logical keyprsnt
      double precision antbas
      character itoaf*8,stcat*80
c
c  Data initialisation.
c
      data flags /MAXCHAN*.true./
c
c  Get command line arguments.
c
      call output( version )
      call keyini
      call keya('source',sfile,' ')
      if(sfile.eq.' ')call bug('f','A source table must be given')
      call keya('ant',antfile,' ')
      if(antfile.eq.' ')call bug('f','An antenna table must be given')

      call keyi('corr',nchan,0)
      call keyi('corr',nospect,1)
      if(nospect.gt.MW)call bug('f','Too many windows set in corr')
      do i=1,nospect
        call keyr('corr',corfin(i),0.)
      enddo
      do i=1,nospect
        call keyr('corr',corbw(i),1000.)
      enddo
      call keyr('spectra',famp,0.)
      call keyr('spectra',fcen,0.)
      call keyr('spectra',fwid,0.)

      call keya('telescop',telescop,'hatcreek')
      call ucase(telescop)
      if(telescop.eq.'ALTAZ')then
        mount = ALTAZ
        dtemp = 0
      else if(telescop.eq.'EQUATORIAL')then
        mount = EQUATOR
        dtemp = 0
      else if(telescop.eq.'XYEW') then
        mount = XYEW
        dtemp = 0
      else
        call obspar(telescop,'mount',dtemp,ok)
        if(.not.ok)call bug('f','No mount defined for telescope: '
     *                      //telescop)
        mount = nint(dtemp)
        call obspar(telescop,'evector',dtemp,ok)
        if(.not.ok)dtemp = 0
      endif
      call keyr('telescop',evector,real(180d0/DPI*dtemp))
      evector = PI/180*evector

      call keyr('baseunit',utns,1.0)
      call keyd('freq',freq,100.d0)
      rfreq = freq
      call keyd('freq',iffreq,0.0d0)
      call keyt('time',timeout,'atime',0.d0)
      if(timeout.le.1)call dayjul('80JAN01',timeout)
      call keyt('radec',sra,'hms',0.d0)
      call keyt('radec',sdec,'dms',30.d0*dpi/180.)
      doellim = keyprsnt('ellim')
      call keyt('ellim',elev,'dms',15.d0*pi/180.)
      sind = sin(sdec)
      cosd = cos(sdec)
      call GetPol(pol,npol,maxpol)

      call mkeya('polar',polar,MAXPOLAR,npolar)
      dopolar = npolar.gt.0
      if(dopolar)then
        npol = 1
        pol(1) = 0
      endif

      call keyt('lat',alat,'dms',40.d0*pi/180)
      sinl = sin(alat)
      cosl = cos(alat)

      call keyr('harange',hbeg,-6.)
      call keyr('harange',hend,6.)
      call keyr('harange',hint,.1)
      if(hbeg.ge.hend.or.hint.lt.0)
     *  call bug('w','Invalid harange parameter')
      call keyr('cycle',cycleon,hint)
      call keyr('cycle',cycleoff,0.)
      if(cycleon.le.0.or.cycleoff.lt.0)
     *  call bug('f','Bad cycle parameters')
c
c  Mosaicing/primary beam parameters.
c
      call keyr('pbfwhm',pbfwhm(1),0.)
      pbfwhm(1) = pi/180/3600 * pbfwhm(1)
      call keyr('pbfwhm',pbfwhm(2),-1.)
      pbfwhm(2) = pi/180/3600 * pbfwhm(2)
      call keyr('pbfwhm',pbfwhm(3),0.2)
      call mkeyr('center',center,2*MAXPNT,npnt)
      if(mod(npnt,2).ne.0) call bug('f',
     *  'There must be an even number of values for "center"')
      npnt = npnt / 2
      if(npnt.eq.0)then
        npnt = 1
        center(1,1) = 0
        center(2,1) = 0
      else
        do i=1,npnt
          center(1,i) = center(1,i) * pi/180/3600
          center(2,i) = center(2,i) * pi/180/3600
        enddo
      endif

      call keyr('gnoise',arms,0.)
      arms = arms /100.
      call keyr('pnoise',prms,0.)
      prms = prms * pi/180
      call keyr('pnoise',patm,0.)
      patm = patm * pi/180
      call keyr('pnoise',pslope,0.)
      call keyr('pnoise',pelev,0.)
      call keyr('leakage',leakrms,0.)
      leakrms = leakrms / 100.
      call keyr('zeeman',zeeman,0.)
      call keyr('systemp',tsys,0.)
      call keyr('systemp',tsky,0.)
      call keyr('systemp',tau,0.)
      call keyr('tpower',trms,0.)
      call keyr('tpower',tatm,0.)
      call keyr('jyperk',jyperk,150.)
      call getopt(dofleak,dodelay,doband)

      call keya('out',outfile,' ')
      if(outfile.eq.' ')
     *  call bug('f','Output file must be given')
      call keyfin
c
c  Determine the rise and set times of the source, at the minimum
c  elevation angle.
c
      call output(' ')
      call output('Observation information:')
      call output('------------------------')
      if(doellim)then
        sinel = sin(elev)
        if(abs(sinel - sinl*sind ).gt.abs(cosl*cosd))then
          if(sinel - sinl*sind - cosl*cosd.gt.0)then
            call bug('f','Source never rises above elevation limit.')
          else
            call output('Source never sets below elevation limit.')
          endif
        else
          temp = (sinel - sinl*sind ) / ( cosl*cosd )
          temp = acos(temp)
          temp = 12/pi * temp
          write(line,'(a,f5.1,a,f5.1,a)') 'Hour angle limit is ',temp,
     *        ' hrs at ',elev*180./pi,' degrees elevation'
          call output(line)
          if(hbeg.lt.-temp.or.hend.gt.temp)
     *      call bug('w','Source is not always up for given HA range')
          hbeg = max(hbeg,-temp)
          hend = min(hend,temp)
          write(line,'(a,f5.1,a,f5.1,a)') 'Hour angle range is ',hbeg,
     *        ' to ',hend,' hours'
          call output(line)
        endif
      endif
c
c  Check other things to simulate.
c
      donoise = tsys.gt.0
      dogains = arms.gt.0.or.prms.gt.0.or.patm.gt.0.or.doband
      doleak = leakrms.gt.0
      doatm = patm.gt.0.

      if(doleak)then
        doleak = npol.eq.4
        if(doleak)doleak = (pol(1).eq.-1.and.pol(4).eq.-4).or.
     *                     (pol(1).eq.-5.and.pol(4).eq.-8)
        if(.not.doleak)then
          call bug('w','Unable to simulate polarization leakage')
          call bug('w','See help for notes on simulating leakage')
        endif
      endif
c
c  Open the output dataset.
c
      call uvopen(unit,outfile,'new')
      call hisopen(unit,'write')
      call uvset(unit,'preamble','uvw/time/baseline',0,0.d0,0.d0,0.d0)

      call hiswrite(unit,'UVGEN: Miriad '//version)
      call hisinput(unit,'UVGEN')
      umsg = 'UVGEN: '//line
      call hiswrite(unit, umsg )
c
c  Open the source components file.
c
      call output(' ')
      call output('Source information:')
      call output('-------------------')
      call hiswrite(unit,'UVGEN: Source specifications:')
      write(line,'(a)')'     Flux     RA      DEC    Major  Minor  '//
     *  '  Axis    Pol-I  Pol-PA  Pol-V alpha'
      call output(line)
      umsg = 'UVGEN: '//line(1:75)
      call hiswrite(unit, umsg )
      write(line,'(a)')'     (Jy)     (")     (")     (")    (")   '//
     *  '  (deg)    (%)    (deg)   (%)'
      call output(line(1:80))
      umsg = 'UVGEN: '//line(1:75)
      call hiswrite(unit, umsg )
c
c  Read the source component file.
c
      ns = 0
      call tinOpen(sfile,' ')
      dowhile(tinNext().gt.0)
        call tinGetr(flux,0.0)
        call tinGetr(dra,0.0)
        call tinGetr(ddec,0.0)
        call tinGetr(wmaj,0.0)
        call tinGetr(wmin,0.0)
        if (wmaj .eq. 0.) wmaj = 0.0001
        if (wmin .eq. 0.) wmin = 0.0001
        call tinGetr(wpa,0.0)
        call tinGetr(poln,0.0)
        call tinGetr(polpa,0.0)
        call tinGetr(polvv,0.0)
        call tinGetr(alp,0.0)
        ns = ns + 1
        if(ns.gt.maxsrc)
     *    call bug('f','Max number of source components read')
        write(line,'(i2,f7.2,2f8.1,2f8.2,f8.1,f8.1,f8.2,f8.1,f6.2)')
     *        ns,flux,dra,ddec,wmaj,wmin,wpa,poln,polpa,polvv,alp
        call output(line)
        umsg = 'UVGEN: '//line
        call hiswrite(unit, umsg )
        ta(ns) = flux
        sx(ns) = dra  * pi/180/3600
        sy(ns) = ddec * pi/180/3600
        if(wmaj .eq. 0.) wmaj = 0.0001
        if(wmin .eq. 0.) wmin = 0.0001
        smaj(ns) = wmaj * pi/180/3600
        smin(ns) = wmin * pi/180/3600
        spa(ns)  =  wpa * pi/180
        per(ns) = poln / 100.
        pa(ns)  = polpa * pi/180
        polv(ns) = polvv / 100.
        alpha(ns) = alp
      enddo

      call tinClose
      line = stcat(itoaf(ns),' sources read from model')
      call output(line)
c
c  Read the antenna positions file.
c
      call output(' ')
      call output('Array information:')
      call output('------------------')
      call output('Antenna positions :')
      call hiswrite(unit,'UVGEN: Antenna positions :')
      nant = 0

      call tinOpen(antfile,' ')
      dowhile(tinNext().gt.0)
        nant = nant + 1
        if(nant.gt.MAXANT)call bug('f','Too many antennas')
        call tinGetr(b1(nant),0.0)
        call tinGetr(b2(nant),0.0)
        call tinGetr(b3(nant),0.0)
c
c  Convert to equatorial coordinates.
c
        if(utns .lt. 0.) then
          x = b1(nant)
          z = b3(nant)
          b1(nant) = -x * sinl + z * cosl
          b3(nant) =  x * cosl + z * sinl
        end if
c
c  Convert to nanosecs.
c
        if(utns .ne. 0.) then
          b1(nant) = abs(utns) * b1(nant)
          b2(nant) = abs(utns) * b2(nant)
          b3(nant) = abs(utns) * b3(nant)
        end if
        write(line,'(a,3f12.4)') 'Equatorial (ns):',
     *                        b1(nant),b2(nant),b3(nant)
        call output(line(1:53))
      enddo

      call tinClose

      if(dopolar)then
        do ipolar=1,npolar
          if(len1(polar(ipolar)).lt.nant) call bug('f',
     *          'Less than NANT characters in polarization cycle')
        enddo
      endif
c
c  correlator and spectral line parameters.
c
      call output(' ')
      call output('Correlator/Spectral information:')
      call output('--------------------------------')
      write(line,'(a,8f8.2)') 'Correlator freq:',
     *                        (corfin(i),i=1,nospect)
      call output(line)
      umsg = 'UVGEN: '//line
      call hiswrite(unit, umsg)

      write(line,'(a,8f8.2)') 'Correlator band:',
     *                        (corbw(i),i=1,nospect)
      call output(line)
      umsg = 'UVGEN: '//line
      call hiswrite(unit, umsg)

      write(line,'(3(a,f11.6),a)')
     * 'Line/continuum:',famp,' center:', fcen,', width:',fwid,' GHz'
      call output(line)
      umsg = 'UVGEN: '//line
      call hiswrite(unit, umsg)
      fwid=fwid/sqrt(2.*log(2.))
c
c  Calculate spectra frequencies from correlator setup
c
      call coramoth(nospect,nchan,corfin,corbw,freq,iffreq)
c
c  Give some messages to the user.
c
      write(line,'(a,i5,a,i5,a,i5)')'Channels:', numchan,
     *        '   Spectra:', nspect, '   Wideband:', nwide
      call output(line)
      umsg = 'UVGEN: '//line
      call hiswrite(unit, umsg)
c
c  If its a wide-only dataset, tell uvset as much.
c
      if(numchan.eq.0)then
        if(nwide.eq.0)call bug('f','No channels to be generated')
        call uvset(unit,'data','wide',0,1.d0,1.d0,1.d0)
      endif
c
c  Fill data header record.
c
      call wrhda(unit,'obstype','crosscorrelation')
      call uvputvra(unit,'source',outfile)
      call uvputvra(unit,'operator','uvgen')
      call uvputvra(unit,'version',version)

      call uvputvrd(unit,'ra',sra,1)
      call uvputvrd(unit,'obsra',sra,1)
      call uvputvrd(unit,'dec',sdec,1)
      call uvputvrd(unit,'obsdec',sdec,1)
      if(pbfwhm(1).ge.0)
     *        call uvputvrr(unit,'pbfwhm',3600*180/pi*pbfwhm(1),1)

      call uvputvrd(unit,'lo1',lo1,1)
      call uvputvrd(unit,'lo2',lo2,1)
      call uvputvrd(unit,'freq',freq,1)
      call uvputvrd(unit,'freqif',freqif,1)
      call uvputvrd(unit,'latitud',alat,1)
c
c  Compute the effective longitude of the observatory.
c
      call jullst(timeout,0.d0,along)
      along = mod(sra-along+2*DPI,2*DPI)
      if(along.gt.DPI)along = along - 2*DPI
      call uvputvrd(unit,'longitu',along,1)
c
c  Miscellaneous.
c
      call uvputvri(unit,'mount', mount, 1)
      call uvputvrr(unit,'evector',evector,1)
      call uvputvra(unit,'telescop',telescop)
c
c  Fake some header information.
c
      call uvputvrr(unit,'jyperk',jyperk,1)
      inttime = max(3600*hint,1.)
      call uvputvrr(unit,'inttime',inttime,1)
      call uvputvrr(unit,'vsource',0.,1)
      call uvputvrr(unit,'veldop',0.,1)
      call uvputvrr(unit,'epoch',2000.,1)
      call uvputvri(unit,'nants',nant,1)
      call uvputvri(unit,'ntemp',0,1)
      call uvputvri(unit,'npol',npol,1)
      call wrhdi(unit,'npol',npol)
      if(npol.eq.1.and..not.dopolar)call uvputvri(unit,'pol',pol(1),1)

      if(nspect.gt.0)then
        call uvputvri(unit,'nchan',numchan,1)
        call uvputvri(unit,'nspect',nspect,1)
        call uvputvrd(unit,'sfreq',sfreq,nspect)
        call uvputvrd(unit,'sdf',sdf,nspect)
        call uvputvri(unit,'ischan',ischan,nspect)
        call uvputvri(unit,'nschan',nschan,nspect)
        do i=1,nspect
          restfreq(i)=freq
        end do
        call uvputvrd(unit,'restfreq',restfreq,nspect)
      endif

      if(nwide.gt.0)then
        call uvputvri(unit,'nwide',nwide,1)
        call uvputvrr(unit,'wfreq',wfreq,nwide)
        call uvputvrr(unit,'wwidth',wwidth,nwide)
      endif

      do jj=1,nant
        antpos(jj) = b1(jj)
        antpos(jj+nant) = b2(jj)
        antpos(jj+nant*2) = b3(jj)
      end do
      call uvputvrd(unit,'antpos',antpos,nant*3)
c
c  Determine the rms for each polarisation using systemp at zenith.
c
      call output(' ')
      call output('Atmosphere/noise model:')
      call output('-----------------------')

      if(Tsky*tau.gt.0.)then
        systemp(1) = 2.*(Tsys + Tsky*(1-exp(-tau)))*exp(tau)
      else
        systemp(1) = Tsys
      endif
      call NoiseRms
     *  (unit,nant,npol,jyperk,systemp,pol,inttime,wrms,rrms,wsignal)
c
c  Write noise info to the history file.
c
      write(line,170) Tsys,Tsky,tau
170   format('Tsys(K): ',f6.0,'  Tsky(K): ',f6.0,
     *                                        '  tau(zenith): ',f6.2)
      call output(line)
      umsg = 'UVGEN: '//line
      call hiswrite(unit, umsg )

      if(nwide.gt.0)then
        write(line,171)  (1e3*wwidth(i), i=1,nwide)
171     format('Wide widths (MHz): ',8f8.3)
        call output(line)
        umsg = 'UVGEN: '//line
        call hiswrite(unit, umsg )

        write(line,172) (wrms(i,1),i=1,nwide)
172     format('Wide noise   (Jy): ',8f8.3)
        call output(line)
        umsg = 'UVGEN: '//line
        call hiswrite(unit, umsg )
      endif

      if(nspect.gt.0)then
        write(line,173)  (1e3*sdf(i),i=1,nspect)
173     format('Channel widths (MHz): ',8f8.3)
        call output(line)
        umsg = 'UVGEN: '//line
        call hiswrite(unit, umsg )

        write(line,174)  (rrms(ischan(i),1),i=1,nspect)
174     format('Channel noise   (Jy): ',8f8.3)
        call output(line)
        call hiswrite(unit, 'UVGEN: '//line)
      endif
c
c  Miscellaneous initialization.
c
      item = 0
c       call Randset(nint(10*timeout))
      call Randset(nint(timeout) +
     *             nint(10000000 * (timeout - int(timeout))))
c       timeout = int(timeout-0.5) + 0.5
c
c  Initialise the effective source parameters, to account for pointing
c  center and
c
      dopoint = npnt.gt.1
      if(.not.dopoint)call GetSrc(pbfwhm,sra,sdec,center(1,1),
     *    ns,ta,smaj,smin,spa,sx,sy,tad,smajd,smind,sxd,syd,szd)
c
c  Determine the polarization leakage parameters.
c

      if(doleak)then
        call output(' ')
        call output('Polarization Model:')
        call output('-------------------')
        call output('Polarization Leakage Terms')
        call hiswrite(unit,'UVGEN: Polarization Leakage Terms')
        call gaus(Leak,8*nant)
        Leak(1,1) = 0
        if (dofleak) Leak(3,1)=0
        do i=1,nant
          Leak(1,i) = leakrms * Leak(1,i)
          Leak(2,i) = leakrms * Leak(2,i)
          write(line,'(1x,a,i2,a,f6.3,a,f6.3,a,f6.3,a,f6.3,a)')
     *      'Ant',i,':Dx,Dy = (',real(Leak(1,i)),',',
     *                          aimag(Leak(1,i)),'),(',
     *                           real(Leak(2,i)),',',
     *                          aimag(Leak(2,i)),')'
          call output(line)
          call hiswrite(unit,'UVGEN: '//line)
          if (dofleak) then
            Leak(3,i) = leakrms * Leak(3,i)
            Leak(4,i) = leakrms * Leak(4,i)
            write(line,'(1x,a,i2,a,f6.3,a,f6.3,a,f6.3,a,f6.3,a)')
     *      'Ant',i,':Dx,Dy = (',real(Leak(3,i)),',',
     *                          aimag(Leak(3,i)),'),(',
     *                           real(Leak(4,i)),',',
     *                          aimag(Leak(4,i)),')'
            call output(line)
            call hiswrite(unit,'UVGEN: '//line)
          endif
         enddo
      endif
c
c  Set atmospheric gain.
c
      gatm = 1
c
c  Compute visibility for each hour angle.
c
      ha = hbeg
      ipolar = 0
      ipnt = 0
      ra = sra
      dec = sdec
      dowhile(ha.lt.hend)
        haend = min(ha + cycleon,hend)
c
c  Increment the polarization switching cycle.
c
        if(dopolar) then
          ipolar = mod(ipolar,npolar) + 1
          xpolar = polar(ipolar)
        endif
c
c  Compute effective source parameters when mosaicing.
c
        ipnt = mod(ipnt,npnt) + 1
        if(dopoint)then
          call uvputvrr(unit,'dra',center(1,ipnt),1)
          call uvputvrr(unit,'ddec',center(2,ipnt),1)
          call GetSrc(pbfwhm,sra,sdec,center(1,ipnt),
     *      ns,ta,smaj,smin,spa,sx,sy,tad,smajd,smind,sxd,syd,szd)
          dec = sdec + center(2,ipnt)
          sind = sin(dec)
          cosd = cos(dec)
          ra = sra + center(1,ipnt) / cos(sdec)
          if(ra.lt.0) ra = ra + 2*dpi
        endif
c
c  Compute new antenna gains.
c
        if(dogains)then
          do n = 1, nant
            pnoise(1,n) = rang(0.,prms)
            gain(1,n) = rang(1.,arms) * expi(pnoise(1,n))
            if (dodelay) then
              pnoise(2,n) = rang(0.,prms)
              gain(2,n) = gain(1,n) * expi(pnoise(2,n))
            endif  
          enddo
        endif

        dowhile(ha.lt.haend)
          lst = ha * pi / 12 + ra
          if (lst.lt.0.d0) lst = lst + 2*pi
          h = lst - ra
          call uvputvrd(unit,'ut',lst,1)
          call uvputvrd(unit,'lst',lst,1)
          preamble(4) = timeout + 365.25/366.25*ha/24.
          sinha = sin(h)
          cosha = cos(h)
          sinq = cosl*sinha
          cosq = sinl*cosd - cosl*sind*cosha
          sinel=sinl*sind+cosl*cosd*cosha

          antaz = atan2(-cosd*sinha,cosl*sind-sinl*cosd*cosha)
          antel = asin(sinel)
          call uvputvrd(unit,'antaz',180.d0/DPI*antaz,1)
          call uvputvrd(unit,'antel',180.d0/DPI*antel,1)
c
c  Offset the parallactic angle by evector.
c
          if(mount.eq.EQUATOR)then
            psi = evector
          else
            psi = atan2(sinq,cosq) + evector
          endif
          call uvputvrr(unit,'chi',psi,1)
c
c  Compute systemp and tpower variations for each antenna.
c
          if(Tsky*tau*sinel.gt.0.)then
            temp = exp(-tau/sinel)
            systemp(1) = 2.*(Tsys + Tsky*(1-temp)) / temp
            call NoiseRms(unit,nant,npol,jyperk,systemp,pol,
     *                        inttime,wrms,rrms,wsignal)
          endif
          if(trms.gt.0. .or. tatm.gt.0.) then
            do n = 1, nant
              tpower(n) = rang(1.,trms)*systemp(1) + tatm*pnoise(1,n)
            enddo
            call uvputvri(unit,'ntpower',nant,1)
            call uvputvrr(unit,'tpower',tpower,nant)
          endif
c
c  Compute visibility for each baseline.
c
          do n = 2, nant
            do m = 1, n-1
              preamble(5) = antbas(m,n)
              bxx = b1(n) - b1(m)
              byy = b2(n) - b2(m)
              bzz = b3(n) - b3(m)
              bxy = bxx * sinha + byy * cosha
              byx =-bxx * cosha + byy * sinha
              preamble(1) = bxy
              preamble(2) =  byx*sind + bzz*cosd
              preamble(3) = -byx*cosd + bzz*sind
              baseline = 3.e-4 * sqrt(bxx*bxx + byy*byy + bzz*bzz)
c
c  Find the polcode for the polarization switching cycle.
c
              if(dopolar)then
                pol(1) = PolsP2C(xpolar(m:m)//xpolar(n:n))
              endif
c
c  Calculate wideband correlations.
c
              if(nwide.gt.0)then
                do ipol = 1, npol
                  do is = 1,nwide
                    call modvis(preamble(1),preamble(2),preamble(3),
     *                dble(wfreq(is)),rfreq,ns,tad,sxd,syd,szd,smaj,
     *                smind,spa,per,pa,polV,alpha,pol(ipol),psi,vis,
     *                zeeman,modI)
                    wsignal(is) = wsignal(is) +
     *                                real(vis)**2 + aimag(vis)**2
                    wcorr(is,ipol) = vis
                  enddo
                enddo
                if(doatm) gatm = expi(
     *             rang(0.,patm * baseline**pslope * sinel**pelev))
                if(doleak)
     *             call PolLeak(wcorr,nwide,maxspect,npol,
     *                leak(1,m),leak(1,n),.false.)
                if(dogains)
     *             call AntGain(wcorr,nwide,maxspect,npol,
     *                gain(1,m),gain(1,n),gatm,.false.,.false.,1,1)
                if(donoise)
     *             call NoiseAdd(wcorr,nwide,maxspect,npol,wrms)
              endif
c
c  Calculate spectral data.  Compute model spectra, and add random
c  noise.
c
              if(numchan.gt.0) then
                oldI = 0
                do ipol=1,npol
                  do is = 1, nspect
                    do ic = ischan(is), ischan(is)+nschan(is)-1
                      freq = sfreq(is) + (ic-ischan(is))*sdf(is)
                      call modvis(preamble(1),preamble(2),preamble(3),
     *                  freq,rfreq,ns,tad,sxd,syd,szd,smajd,smind,spa,
     *                  per,pa,polV,alpha,pol(ipol),psi,vis,zeeman,modI)

                      if(famp.ne.0. .and. fwid.ne.0.)then
                          xx = (real(freq)-fcen)/fwid
                          if(xx.lt.10.)then
                            xxamp = max(0.,1.+ famp * exp(-xx*xx))
                            vis = vis * xxamp
                            modI = modI * xxamp
                          endif

                        if(zeeman.ne.0.)then
                          if(ic.ne.ischan(is))then
                            gradI = (modI-oldI)/sdf(is)
                          else
                            gradI = cmplx(0.,0.)
                          endif
                          if(pol(ipol).eq.PolXY) then
                            vis = vis - cmplx(0.,1.) * zeeman * gradI
                          else if(pol(ipol).eq.PolYX)then
                            vis = vis + cmplx(0.,1.) * zeeman * gradI
                          else if(pol(ipol).eq.PolRR)then
                            vis = vis + zeeman * gradI
                          else if(pol(ipol).eq.PolLL)then
                            vis = vis - zeeman * gradI
                          endif
                          oldI = modI
                        endif
                      endif
                      chan(ic,ipol) = vis
                    enddo
                  enddo
                enddo
                if(dogains)
     *             call AntGain(chan,numchan,MAXCHAN,npol,
     *                gain(1,m),gain(1,n),gatm,dodelay,doband,m,n)
                if(doleak)
     *             call PolLeak(chan,numchan,MAXCHAN,npol,
     *                leak(1,m),leak(1,n),dofleak)
                if(donoise)
     *             call NoiseAdd(chan,numchan,MAXCHAN,npol,rrms)
              endif

c
c  Write data records.
c
              do ipol=1,npol
                if(npol.gt.1.or.npolar.gt.1)
     *                call uvputvri(unit,'pol',pol(ipol),1)
                if(numchan.gt.0) then
                  if(nwide.gt.0)
     *              call uvwwrite(unit,wcorr(1,ipol),flags,nwide)
                  call uvwrite(unit,preamble,chan(1,ipol),flags,
     *                                                        numchan)
                else
                  call uvwrite(unit,preamble,wcorr(1,ipol),flags,
     *                                                        nwide)
                endif
                item = item + 1
              enddo
c
c  Finished doing two antenna number do loops, and two ha dowhile loops.
c
            enddo
          enddo
          ha = ha + hint
        enddo
        ha    = ha + cycleoff
      enddo
c
c  All done.  Summarize, tidy up and exit.
c
      call output(' ')
      line = stcat(itoaf(item),' records written to file: '//outfile)
      call output(line)
      umsg = 'UVGEN: '//line
      call hiswrite(unit, umsg )
c
c  Write out the signal to noise ratio in the wide channels.
c
      if(nwide.gt.0.and.tsys.gt.0)then
        do i=1,nwide
          wsignal(i) = sqrt(wsignal(i)/(2*item*wrms(i,1)*wrms(i,1)))
        enddo
        write(line,180) (wsignal(i),i=1,nwide)
180     format('Wide SNR: ',8f8.3)
        call output(line)
        umsg = 'UVGEN: '//line
        call hiswrite(unit, umsg )
      endif

      call hisclose(unit)
      call uvclose(unit)
      end
c********1*********2*********3*********4*********5*********6*********7*c
      subroutine GetOpt(dofleak,dodelay,doband)
c
      logical dofleak,dodelay,doband
c
c  Get the user options
c
c  Output:
c    dofleak   Add frequency variation to leakage terms
c    dodelay   Add frequency variation to phase terms
c    doband    Add a bandpass function
c-----------------------------------------------------------------------
      integer nopt
      parameter (nopt=3)
      character opts(nopt)*8
      logical present(nopt)
      data opts/'leakfvar','delay   ','bandpass'/
      call options('options',opts,present,nopt)
      dofleak = present(1)
      dodelay = present(2)
      doband = present(3)
      end
c********1*********2*********3*********4*********5*********6*********7*c
      subroutine GetSrc(pbfwhm,ra0,dec0,center,
     *    ns,ta,smaj,smin,spa,sx,sy,tad,smajd,smind,sxd,syd,szd)

      integer ns
      double precision ra0,dec0
      real pbfwhm(3),center(2)
      real ta(ns),smaj(ns),smin(ns),spa(ns),sx(ns),sy(ns)
      real tad(ns),smajd(ns),smind(ns),sxd(ns),syd(ns),szd(ns)
c
c  Calculate the effective source parameters, considering the primary
c  beam, and offset pointing.
c
c  Input:
c    unit       Handle of the output data-set.  Only used if
c
c-----------------------------------------------------------------------
      integer i
      double precision ra,dec,rap,decp,cosdec0
      real ll,mm
c
c  Get the true pointing center RA and DEC.
c
      cosdec0 = cos(dec0)
      rap  = ra0  + center(1)/cosdec0
      decp = dec0 + center(2)
c
c  Derive the true direction cosines relative to the pointing centre.
c
      do i=1,ns
        ra  = ra0  + sx(i) / cosdec0
        dec = dec0 + sy(i)
        ll = sin(ra-rap) * cos(dec)
        mm = sin(dec)*cos(decp) - cos(ra-rap) * cos(dec) * sin(decp)
        call points(pbfwhm(1),
     *   smaj(i),smin(i),spa(i),ta(i),ll,mm,smajd(i),smind(i),tad(i),
     *   sxd(i),syd(i),szd(i))
      enddo

      end
c********1*********2*********3*********4*********5*********6*********7*c
      subroutine points(fwhmpb,fwhm1, fwhm2, pa,flux, x0, y0,
     *                         fwhm1d,fwhm2d,   fluxd,x0d,y0d,z0d)

      real fwhmpb,fwhm1,fwhm2,pa,flux,x0,y0
      real fwhm1d,fwhm2d,fluxd,x0d,y0d,z0d

c  Determine the parameters of a gaussian source, attenuated by a
c  primary beam.
c
c  Input:
c    fwhmpb     FWHM of the primary beam (radians).  A negative or zero
c               value indicates an infinite primary beam.
c    fwhm1,fwhm2 Gaussian FWHM of the source (radians).
c    pa         Position angle of the source (radians).
c    flux       Source flux.
c    x0,y0      True direction cosines.
c  Output:
c    fwhm1d,fwhm2d Gaussian FWHM of the source after attenuation (rad).
c    fluxd       Source flux after attenuation.
c    x0d,y0d,z0d Direction cosines after attenuation (radians).
c-----------------------------------------------------------------------
      real x1,y1,temp

      if(fwhmpb.gt.0)then
        x1 = cos(pa)*x0 - sin(pa)*y0
        y1 = sin(pa)*x0 + cos(pa)*y0

        x1 = x1 * fwhmpb**2 / (fwhm1**2 + fwhmpb**2)
        y1 = y1 * fwhmpb**2 / (fwhm2**2 + fwhmpb**2)

        x0d =  cos(pa)*x1 + sin(pa)*y1
        y0d = -sin(pa)*x1 + cos(pa)*y1

        fwhm1d = fwhmpb*fwhm1/sqrt(fwhmpb**2 + fwhm1**2)
        fwhm2d = fwhmpb*fwhm2/sqrt(fwhmpb**2 + fwhm2**2)
        temp = 4*log(2.)*(x0*x0d + y0*y0d)/(fwhmpb**2)
        fluxd = flux * exp(-temp)
      else
        x0d = x0
        y0d = y0
        fwhm1d = fwhm1
        fwhm2d = fwhm2
        fluxd = flux
      endif

      z0d = sqrt(1 - x0d*x0d - y0d*y0d)

      end
c***********************************************************************
      subroutine PolLeak(vis,nchan,maxchan,npol,D1,D2,dofleak)

      integer nchan,maxchan,npol
      complex vis(maxchan,npol)
      complex D1(4),D2(4)
      logical dofleak

c  Allow some of the signal to leak from one polarization to another.
c  Despite the variable names, this works equally well fro circular and
c  linear feeds (the algebra is the same).
c
c  NOTE: The number of polarisations must be 4, and they must be in the
c  order XX,YY,XY,YX (or RR,LL,RL,LR).
c
c  Input:
c    D1,D2      Leakage terms of the two antennas.  Leak1(1) is the
c               leakage of Y into the X feed (or L into R) for antenna
c               1.  Leak1(2) is the leakage of X into the Y (or R into
c               L) for antenna 1.
c    dofleak    If true, use indices 3 and 4 of D1 and D2 to introduce
c               variation with frequency
c    npol       Number of polarizations.  It must be 4!
c    maxchan    Size of the "vis" array.
c    nchan      Number of used channels.
c  Input/Output:
c    vis        The visibility data.
c-----------------------------------------------------------------------
      integer X,Y,XX,YY,XY,YX
      parameter(X=1,Y=2,XX=1,YY=2,XY=3,YX=4)
      integer i,n
      complex Vxx,Vxy,Vyx,Vyy,D1X,D1Y,D2X,D2Y

      if(npol.ne.4)call bug('f','npol not 4, in PolLeak')

      n = max(1,nchan-1)
      do i=1,nchan
        Vxx = vis(i,XX)
        Vyy = vis(i,YY)
        Vxy = vis(i,XY)
        Vyx = vis(i,YX)
        D1X = D1(X)
        D1Y = D1(Y)
        D2X = D2(X)
        D2Y = D2(Y)
        if (dofleak.and.nchan.gt.1) then
          D1X = D1X*(nchan-i)/n + D1(X+2)*(i-1)/n
          D1Y = D1Y*(nchan-i)/n + D1(Y+2)*(i-1)/n
          D2X = D2X*(nchan-i)/n + D2(X+2)*(i-1)/n
          D2Y = D2Y*(nchan-i)/n + D2(Y+2)*(i-1)/n
        endif
        vis(i,XX) = Vxx + D1X*Vyx + conjg(D2X)*Vxy
     *                  + D1X*      conjg(D2X)*Vyy
        vis(i,YY) = Vyy + D1Y*Vxy + conjg(D2Y)*Vyx
     *                  + D1Y*      conjg(D2Y)*Vxx
        vis(i,XY) = Vxy + D1X*Vyy + conjg(D2Y)*Vxx
     *                  + D1X*      conjg(D2Y)*Vyx
        vis(i,YX) = Vyx + D1Y*Vxx + conjg(D2X)*Vyy
     *                  + D1Y*      conjg(D2X)*Vxy
      enddo

      end
c***********************************************************************
      subroutine AntGain(vis,nchan,maxchan,npol,G1,G2,
     *                   gAtm,dodelay,doband,ant1,ant2)

      integer nchan,maxchan,npol,ant1,ant2
      complex vis(maxchan,npol)
      complex G1(2), G2(2), gAtm
      logical dodelay,doband
c
c  Apply a gain to the data.
c
c  Input:
c    G1,G2       The gain to apply.
c    npol       Number of polarizations.
c    maxchan    Size of the "vis" array.
c    nchan      Number of used channels.
c  Input/Output:
c    vis        The visibility data.
c-----------------------------------------------------------------------
      integer i,j,n
      Complex Gain0, Gain, Gain1, Gain2,g, expi
      real mag,fac
      Gain0 = G1(1) * conjg(G2(1) * gAtm)
      n = max(1,nchan-1)
      do i=1,nchan
        Gain = 1
        if (dodelay) then
          fac = (nchan-i*1.0)/n
          g = G1(1)/G1(2)
          mag=abs(g)
          Gain1 = G1(2) * (1+(mag-1)*fac)*(g/mag)**fac
          g = G2(1)/G2(2)
          mag=abs(g)
          Gain2 = G2(2) * (1+(mag-1)*fac)*(g/mag)**fac
          Gain = Gain1 * conjg(Gain2 * gAtm)
        endif
c
c  Add a complex bandpass, different one for each antenna
c        
        if (doband) then
          Gain1 = 0.75 + 0.5*sin(3.1415*i/nchan) + 
     *      0.1*expi(3.1415*(5+ant1/5.0)*i/nchan)
          Gain2 = 0.75 + 0.5*sin(3.1415*i/nchan) +
     *      0.1*expi(3.1415*(5+ant2/5.0)*i/nchan)
          Gain = Gain * Gain1 * conjg(Gain2)
        endif
        do j=1,npol
          vis(i,j) = Gain0 * Gain * vis(i,j)
        enddo
      enddo
      end
c***********************************************************************
      subroutine NoiseAdd(vis,nchan,maxchan1,npol,rms)

      integer nchan,maxchan1,npol
      complex vis(maxchan1,npol)
      real rms(maxchan1,npol)
c
c  Apply a gain to the data.
c
c  Input:
c    rms        Rms value of the noise to add.
c    npol       Number of polarizations.
c    maxchan    Size of the "vis" array.
c    nchan      Number of used channels.
c  Input/Output:
c    vis        The visibility data.
c-----------------------------------------------------------------------
      include 'maxdim.h'
      integer i,j
      complex data(MAXCHAN)
      if(nchan.gt.MAXCHAN)call bug('f','Too many chans, in NoiseAdd')

      do j=1,npol
        call Gaus(data,2*nchan)
        do i=1,nchan
          vis(i,j) = vis(i,j) + rms(i,j) * data(i)
        enddo
      enddo

      end
c***********************************************************************
      real function rang(xmean,xsd)

      real xsd,xmean

c  Generate a gaussian random number with mean "xmean" and standard
c  deviation "xsd".
c-----------------------------------------------------------------------
      real data

      call gaus(data,1)
      rang = data*xsd + xmean
      end
c***********************************************************************
      subroutine GetPol(pol,npol,maxpol)

      integer npol,maxpol
      integer pol(maxpol)
c
c  Get the polarisations that the user wants to form.
c
c  Input:
c    maxpol     Max number of polarisations than this can handle.
c  Output:
c    npol       The number of polarisations that the user wants to form.
c    pol        The polarisations that the user wants to form.
c-----------------------------------------------------------------------
      integer i,j,t
      character user*4
c
c  Externals.
c
      integer PolsP2C
      character PolsC2P*2
      logical keyprsnt

      call keya('stokes',user,'i')
      npol = 0
      dowhile(user.ne.' '.and.npol.lt.maxpol)
        npol = npol + 1
        pol(npol) = PolsP2C(user)
        call keya('stokes',user,' ')
      enddo
      if(keyprsnt('stokes'))
     *  call bug('f','Too many stokes/polarizations for me to handle')
c
c  Sort the polarisations into descending order.  Bubble sort because
c  who cares with only 4 elements.
c
      do j=1,npol-1
        do i=1,npol-j
          if(pol(i).lt.pol(i+1))then
            t = pol(i)
            pol(i) = pol(i+1)
            pol(i+1) = t
          endif
        enddo
      enddo
c
c  Squeeze out replications (pretty paranoid eh?).
c
      j = 1
      do i=2,npol
        if(pol(i).ne.pol(j))then
          j = j + 1
          pol(j) = pol(i)
        endif
      enddo
      npol = j
c
c  Check that the max polarisation is 1.
c
      if(pol(1).gt.1)call bug('f','Unsupported polarisation '//
     *  PolsC2P(pol(1)))

      end
c***********************************************************************
      subroutine modvis (uns,vns,wns,freq,rfreq,ns,ta,sx,sy,sz,
     *        smaj,smin,spa,per,pa,polV,alpha,code,psi,cont,zeeman,modI)

      double precision uns,vns,wns,freq,rfreq
      integer ns,code
      real ta(ns),sx(ns),sy(ns),sz(ns),smaj(ns),smin(ns)
      real spa(ns),per(ns),pa(ns),polV(ns),alpha(ns)
      real psi,zeeman
      complex cont,modI
c
c  Compute the visibility of model source distribution of linearly
c  polarized Gaussian components, observed with linear or circular
c  feeds, at paralactic angle PSI.
c
c  Input:
c    uns,vns,wns The (u,v,w) coordinate of the visibility, in nanosec.
c    freq       The frequency of the visibility, in GHz.
c    rfreq      The reference frequency (for spectral index)
c    code       Polarisation code (AIPS/FITS style).
c    ns         Number of gaussians in the model.
c    psi        Parallactic angle, in radians.
c       The following give parameters of the gaussians.
c    ta         Peak flux, in Jy.
c    sx,sy,sz   l,m,n direction cosines.
c    smaj,smin  Gaussian source FWHM size in the image plane.
c    spa        Gaussian position angle, in radians.
c    per        Fractional linear polarisation (in range [0,1]).
c    pa         Position angle of the polarisation, in radians.
c    polV       Fractional circular polarisation (in range [0,1]).
c    alpha      Spectral index
c    zeeman     Zeeman coefficient.
c  Output:
c    cont       The computed visibility.
c    modI       The Stokes I model visibility.
c-----------------------------------------------------------------------
      include 'mirconst.h'
      integer PolI,PolRR,PolLL,PolRL,PolLR,PolXX,PolYY,PolXY,PolYX
      parameter(PolI=1,PolRR=-1,PolLL=-2,PolRL=-3,PolLR=-4)
      parameter(       PolXX=-5,PolYY=-6,PolXY=-7,PolYX=-8)

      real p,umaj,umin,uvmaj,uvmin,gaus,flux,sifac
      complex vis
      logical inten
      double precision u,v,w
      integer j
c
c  Externals.
c
      complex expi
      logical polspara
c
c  Convert u and v to wavelengths.
c
      u = uns * freq
      v = vns * freq
      w = wns * freq
c
c  Loop over the source components.  Avoid as much work as possible by
c  checking for situations where the component contributes nothing.
c
      inten = polspara(code)
      cont = (0.,0.)
      modI = (0.,0.)
      do j = 1,ns
        sifac = (freq/rfreq)**alpha(j)
        flux = 0
        if(polV(j).ne.0..or.per(j).ne.0.or.inten.or.zeeman.ne.0.)then
          uvmaj = 1. / ( pi * 0.6 * smaj(j) )
          uvmin = 1. / ( pi * 0.6 * smin(j) )
          umaj = (u * sin(spa(j)) + v * cos(spa(j))) / uvmaj
          umin = (u * cos(spa(j)) - v * sin(spa(j))) / uvmin
          gaus = umaj*umaj + umin*umin
          if (gaus .lt. 20) flux = ta(j) * exp(-gaus)
        endif
c
c  Determine the contribution for the various polarisations.
c
        if (flux.ne.0)then
          if((per(j).eq.0.and.inten).or.
     *        code.eq.PolI.or.code.eq.PolRR.or.code.eq.PolLL)then
            vis = 1
          else if(code.eq.PolXX)then
            vis = 1 + per(j) * cos(2.* (pa(j) - psi))
          else if(code.eq.PolYY)then
            vis = 1 - per(j) * cos(2.* (pa(j) - psi))
          else if(code.eq.PolXY.or.code.eq.PolYX)then
            vis = per(j) * sin(2.* (pa(j) - psi))
          else if(code.eq.PolRL)then
            vis = per(j) * expi(-2.* (pa(j) - psi))
          else if(code.eq.PolLR)then
            vis = per(j) * expi( 2.* (pa(j) - psi))
          else
            call bug('f','Unsupported polarization, in ModVis')
          endif

          if(polV(j).ne.0.)then
            if(code.eq.PolRR)then
              vis = vis + polV(j)
            else if(code.eq.PolLL)then
              vis = vis - polV(j)
            else if(code.eq.PolXY)then
              vis = vis - cmplx(0.,1.)*polV(j)
            else if(code.eq.PolYX)then
              vis = vis + cmplx(0.,1.)*polV(j)
            endif
          endif

          p=2*pi*(u*sx(j)+v*sy(j)+w*(sz(j)-1))
          cont = cont + vis * expi(p) * flux * sifac
          modI = modI + expi(p) * flux * sifac
        endif
      enddo
      end
c***********************************************************************
      subroutine coramoth(nospect,nchan,corfin,corbw,freq,iffreq)

      integer nospect,nchan
      real corfin(4),corbw(4)
      double precision freq,iffreq
c
c  Derives spectra parameters from correlator setup.
c
c  Inputs:
c    nospect    The number of spectra.
c    nchan      Number of channels.
c    corfin     Correlator frequencies.
c    corbw      Correlator bandwidths.
c    freq       Frequency of primary line, in upper sideband.
c
c  Outputs via the uvgencom common.
c-----------------------------------------------------------------------
      integer i
      include 'maxdim.h'
      include 'uvgen.h'
c
c  Determine down-conversion chain characteristics.
c
      freqif = iffreq
      lo1 = freq - freqif
      lo2 = 0.d0
c
c  Set up the wide correlator characteristics.
c
      nwide = nospect
      do i=1,nwide
        wfreq(i) = freq + 1e-3*corfin(i)
        wwidth(i) = 1e-3*corbw(i)
      enddo
c
c  Fill in spectral correlator details.
c
      if(nchan.eq.0)then
        nspect  = 0
        numchan = 0
      else
        nspect = nospect
        numchan = nspect*nchan
        do i=1,nspect
          sdf(i) = 1e-3 * corbw(i) / nchan
          sfreq(i) = freq + 1e-3*corfin(i) - 0.5*(nchan-1)*sdf(i)
          ischan(i) = 1 + nchan*(i-1)
          nschan(i) = nchan
        enddo
      endif
      end
c***********************************************************************
      subroutine NoiseRms
     *  (unit,nant,npol,jyperk,systemp,pol,inttime,wrms,rrms,wsignal)

c  Calculate random noise based on system temperature, integration time
c  and bandwidth.

      include 'maxdim.h'
      include 'uvgen.h'
      integer unit,nant,npol,pol(MAXPOL)
      real jyperk,inttime
      real wrms(MAXSPECT,MAXPOL),rrms(MAXCHAN,MAXPOL)
      real systemp(MAXANT*MAXSPECT),wsignal(MAXSPECT)
c-----------------------------------------------------------------------
      integer i,j,jj,ipol
      real sqrt2,temp
      parameter(sqrt2=1.414214)

      jj = 1
      do j = 2,nant*max(nwide,nspect)
        jj = jj + 1
        systemp(jj)=systemp(1)
      end do
      call uvputvrr(unit,'systemp',systemp,max(1,nant*nspect))
      call uvputvrr(unit,'wsystemp',systemp,max(1,nant*nwide))

      do i=1,nwide
        wrms(i,1) = jyperk*systemp(1) / sqrt(2*wwidth(i)*1e9*inttime)
        wsignal(i) = 0
        do ipol=1,npol
          wrms(i,ipol) = wrms(i,1)
        enddo
      enddo
      do j = 1,nspect
        temp = jyperk * systemp(1) / sqrt(2*abs(sdf(j))*1e9*inttime)
        do ipol=1,npol
          do i = ischan(j), ischan(j)+nschan(j)-1
            rrms(i,ipol) = temp
          enddo
        enddo
      enddo
c
c  Divide noise levels by sqrt(2) if its a true Stokes correlation.
c
      do ipol=1,npol
        if(pol(ipol).gt.0)then
          do i=1,nwide
            wrms(i,ipol) = wrms(i,ipol)/sqrt2
          enddo
          do i=1,numchan
            rrms(i,ipol) = rrms(i,ipol)/sqrt2
          enddo
        endif
      enddo
      end
