c************************************************************************
	program uvspec
	implicit none
c
c= uvspec - Plot averaged spectra of a visibility dataset.
c& rjs
c: uv analysis
c+
c	UVSPEC plots averaged spectra of a visibility dataset. Averaging can
c	be in both time and frequency
c@ vis
c	The name of the input uv data sets. Several can be given (wild
c	cards are supported). No default.
c@ select
c	The normal uv selection commands. The default is plot everything.
c@ line
c	The normal uv linetype in the form:
c	  line,nchan,start,width,step
c	The default is all channels (or all wide channels if there are no
c	spectral channels).
c@ stokes
c	The Stokes/polarization types to be plotted. The default is to
c	plot those polarizations present in the input files. Note that 
c	stokes=q,u is adopted when the X axis is RM or the Y axis is polang,
c	regardless of Stokes input given.
c@ interval
c	Time averaging interval, in minutes. The default is 0 (i.e. no
c	averaging).
c@ hann
c	Hanning smoothing width (an odd integer).  Smoothing is
c	applied after averaging. Default is 1 (no Hanning smoothing).
c@ offset
c	An offset (in arcsec) to shift the data. Positive values result in
c	the data center being shifted to the North and East. Two values
c	should be given, being the shift in the RA and DEC directions.
c	The default is 0,0 (i.e. no shift).
c@ options
c	This gives extra processing options. Several options can be given,
c	each separated by commas. They may be abbreviated to the minimum
c	needed to avoid ambiguity. Possible options are:
c	   'nocal'       Do not apply the gains file. By default, UVSPEC
c	                 applies the gains file in copying the data.
c	   'nopass'      Do not apply bandpass corrections. By default,
c	                 UVSPEC corrects for the bandpass shape if the
c	                 required information is available.
c	   'nopol'       Do not apply polarization corrections. By default
c	                 UVSPEC corrects for polarization corss-talk.
c	   'ampscalar'   When plotting amplitude, this causes it to perform
c	                 scalar averaging. By default it does vector averaging.
c	   'rms'         When plotting amplitude, this causes it to plot
c		         the rms amplitude. By default it does vector averaging.
c                        Ignored for xaxis=rm
c          'mnoise'      When plotting noise, plot the error in the mean.           
c          'sdo'         Plot the difference between bin 2 and bin 1 (these
c                        contain the CABB noise cal source on and off 
c                        autocorrelations, giving the Synchr. Detected Ouput)
c                        Ignored for xaxis=rm
c	   'nobase'      Plot all the baselines on one plot.
c	   'avall'       Average all the baselines together before plotting.
c	   'dots'        Plot phases with dots instead of filled circles.
c	   'flagged'     Plot flagged data instead of unflagged data. The
c	                 default is to plot only unflagged data.
c	   'all'         Plot both flagged and unflagged data.
c          'hdr'         Use high dynamic range scaling for amplitude plots:
c                        log(1+amp). This works well for RFI affected data.
c                        Ignored for xaxis=rm
c          'timelog'     In any log file, output the time of the spectrum before
c                        each spectrum is written out.
c@ axis
c	This gives two strings, which determine the X and Y axes of each plot.
c	The values can be abbreviated to uniqueness.
c	Possible values for the X axis are:
c	   channel       X-axis is channel number.
c	   frequency     X-axis is the sky frequency, in GHz.
c	   dfrequency    X-axis is the Doppler-corrected frequency, in GHz.
c	   velocity      X-axis is velocity in radio convention, in km/sec.
c	   felocity	 X-axis is velocity in optical convention, in km/sec.
c	   lag           X-axis is lag number.
c	   rm            X-axis is Faraday depth, in rad/m^2. When this
c		 	 is selected, the RMTF is plotted as a dashed line,
c                        and +/-1 sigma are plotted as dot-dashed lines
c	   lambda2       X-axis is (wavelength)^2, in m^2.
c	Possible values for the Y axis are:
c	   amplitude     Plot amplitude.
c	   phase         Plot phase.
c	   real          Plot real part of the data.
c	   imaginary     Plot imaginary part of the data.
c          noise         Plot the standard deviation of the data
c          polang        Plot the polarisation angle of Q and U for the data
c          
c	The default is axis=channel,amplitude. 
c	If axis=rm is selected, the value input for the Y axis is ignored and 
c	axis=rm,real is adopted.
c@ xrange
c	The min and max range along the x axis of the plot. The default 
c	is to autoscale. 
c@ yrange
c	The min and max range along the y axis of the plots. The default
c	is to autoscale.
c@ device
c	PGPLOT plot device/type. No default.
c@ nxy
c	Number of plots in the x and y directions. The default is
c	determined from the number of antennae in the data-sets.
c@ log
c	Log file into which the spectra are dumped in the order in which
c	they are plotted.  Really only useful if your plot is quite simple.
c
c$Id: uvspec.for,v 1.17 2018/06/25 21:08:49 wie017 Exp $
c--
c  History:
c    rjs  18sep92 Derived from uvaver.
c    nebk 22sep92 OPTIONS=DOTS
c    rjs  21oct92 Better title. Bug dealing with number of points in a plot.
c    nebk 28oct92 Add HAnning smoothing
c    mjs  13mar93 pgplot subr names have less than 7 chars.
c    rjs  17mar93 Different colours for different plots.
c    rjs  19mar93 I did not understand the "gap" arg to pghline!
c    rjs  18aug93 Improve labelling.
c    rjs  24aug93 Added shift option.
c    nebk 05sep93 Added log option
c    rjs  22sep93 Rms averaging option.
c    rjs  23dec93 Added 'felocity' axis (velocity using optical definition).
c    rjs   8mar94 Handle data which are not in time order.
c    nebk 22mar94 Add options=flagged
c    rjs  17aug94 Better offset handling.
c    rjs  26sep95 Discard bad spectra as soon as possible.
c    rjs  28sep95 Fix bug I introduced two days ago.
c    rjs  17oct95 Correct initialisation bug when first integration is all
c		  bad.
c    rjs  19oct95 options=all
c    rjs  16nov95 Use different colours and PGRNGE.
c    rjs  14dec95 Increase buffer in averaging (MAXAVER).
c    rjs  19aug97 Added axis=lag
c    rjs  31oct97 Use colours in the label.
c    rjs   3dec97 Replace part of label that dropped off in above change.
c    rjs  13sep99 Added Doppler corrected freq to possibilities to plot.
c    rjs  29jun05 Use 3D shift algorithm.
c    rjs  26jan07 Adjust size of title to prevent overflow on multipanel
c	          plot.
c    mhw  02feb10 Add sdo option to look at CABB autocorrelation data bins
c    mhw  21apr10 Fix axis label and plot accuracy issues for high res data
c    mhw  07sep12 Add hdr option, useful for plotting rfi
c    mhw  18nov13 Add noise, mnoise
c    mhw  03dec13 Add units to Y axis
c    mhw  06feb14 Fix bug in last change
c    bmg  27jun17 Added axis=rm
c    mhw  25jun18 Add warning when time averaging velocity plot
c  Bugs:
c------------------------------------------------------------------------
	include 'mirconst.h'
	include 'maxdim.h'
        integer maxco
        parameter (maxco=15)
c
	character version*72
	character uvflags*8,device*64,xaxis*12,yaxis*12,logf*64
	character xtitle*64,ytitle*64
	logical ampsc,rms,nobase,avall,first,buffered,doflush,dodots
	logical doshift,doflag,doall,dolag,dosdo,dohdr,domnoise,dorm
	logical dotimelog,dolam,doang
	double precision interval,T0,T1,preamble(5),shift(2),lmn(3)
	integer tIn,vupd
	integer nxy(2),nchan,nread,nplot
	real xrange(2),yrange(2),inttime
	double precision x(2*MAXCHAN-2)
	complex data(MAXCHAN)
	logical flags(MAXCHAN)
	integer hann,ibin,ncount,nncount
	real hc(maxco),hw(maxco)
	real sig2,rms2,sig
c
c  Externals.
c
	integer nextpow2
	logical uvDatOpn,uvVarUpd
        character versan*72


        version = versan('uvspec',
     *                   '$Revision: 1.17 $',
     *                   '$Date: 2018/06/25 21:08:49 $')
c
c  Get the input parameters.
c
	call keyini
	call GetOpt(uvflags,ampsc,rms,nobase,avall,dodots,
     *    doflag,doall,dosdo,dohdr,domnoise,dotimelog)
	call GetAxis(xaxis,yaxis)
	dolag = xaxis.eq.'lag'
	dorm = xaxis.eq.'rm'
	dolam = xaxis.eq.'lambda2'
	doang = yaxis.eq.'polang'
	ncount = 0
	nncount = 0
	rms2 = 0.

C	Force Stokes choices to be Q and U for Faraday depth
C	or for polarisation angle
	if (dorm.or.doang) then
          uvflags(2:2)='g'
	endif
	call uvDatInp('vis',uvflags)

	call keyd('interval',interval,0.d0)
        call keyi('hann',hann,1)
	call keya('device',device,' ')
	call keyi('nxy',nxy(1),0)
	call keyi('nxy',nxy(2),0)
	call keyd('offset',shift(1),0.d0)
	call keyd('offset',shift(2),0.d0)
	call keyr('xrange',xrange(1),0.)
	call keyr('xrange',xrange(2),xrange(1)-1.)
	call keyr('yrange',yrange(1),0.)
	call keyr('yrange',yrange(2),yrange(1)-1.)
        call keya('log',logf,' ')
	call keyfin
c
c  Check the input parameters.
c
	if(interval.lt.0)call bug('f','Illegal value for interval')
        if((ampsc.or.rms).and.yaxis.ne.'amplitude')
     *	  call bug('w','Amplitude averaging option ignored')
	if(avall.and..not.nobase)
     *	  call bug('w','Option NOBASE being used because of AVALL')
	nobase = nobase.or.avall
        if (hann.lt.1 .or. hann.gt.maxco) call bug('f',
     *    'Illegal Hanning smoothing width')
        if (domnoise.and.yaxis.ne.'noise')
     *    call bug('w','mnoise option ignored')   
c
c  Convert the shifts, and determine whether a shift is to be performed.
c
	shift(1) = pi/180/3600 * shift(1)
	shift(2) = pi/180/3600 * shift(2)
	doshift = abs(shift(1))+abs(shift(2)).gt.0

c
c  Various initialisation.
c
	ytitle = yaxis
	if (ytitle(1:6).eq.'polang') 
     +     ytitle = 'polarisation angle'
        if (dosdo) ytitle = yaxis//' SDO'
	call ucase(ytitle(1:1))
	interval = interval/(24.*60.)
	doflush = .false.
	buffered = .false.
	first = .true.
        ibin=0
	call BufIni
        if(hann.gt.1) call HCoeffs(hann,hc)
        if(logf.ne.' ') call LogOpen(logf,' ')
c
c  Open the input file(s).
c
	dowhile(uvDatOpn(tIn))
c
c No comment.
c
	  call uvVarIni(tIn,vupd)
	  call uvVarSet(vupd,'dra')
	  call uvVarSet(vupd,'ddec')
	  call uvVarSet(vupd,'source')
c
c  Loop over the data.
c
	 call uvDatRd(preamble,data,flags,maxchan,nread)
         call uvDatGtr('variance',sig2) 
	 rms2 = rms2 + sig2
         nncount = nncount + 1
	  nplot = nread
	  if(dolag)nplot = nextpow2(2*(nread-1))
	  if(doshift)then
	    call coInit(tIn)
	    call coLMN(tIn,'ow/ow',shift,lmn)
	    call coFin(tIn)
	  endif
	  nchan = nread
	  T1 = preamble(4)
	  T0 = T1
	  dowhile(nread.gt.0)
c
c  Shift the data if needed.
c
	    if(doshift)call ShiftIt(tIn,preamble,data,nchan,lmn)
c
c  Determine if we need to flush out the averaged data.
c
            if (dosdo )call uvrdvri(tIn,'bin',ibin,0)
	    doflush = uvVarUpd(vupd)
	    doflush = nread.ne.nchan
	    T0 = min(preamble(4),T0)
	    T1 = max(preamble(4),T1)
	    doflush = (doflush.or.T1-T0.gt.interval).and.buffered
c
c  Pull the chain and flush out and plot the accumulated data
c  in the case of time averaging.
c
	    if(doflush)then
	      sig = sqrt(rms2/real(nncount))/sqrt(real(ncount)/2.)
	      call BufFlush(ampsc,rms,nobase,dodots,dohdr,domnoise,hann,
     *	       hc,hw,first,device,x,nplot,xtitle,ytitle,nxy,xrange,
     *         yrange,sig,rms2,ncount,nncount,logf,dotimelog)
	      rms2 = 0.
	      ncount = 0
	      nncount = 0
	      T0 = preamble(4)
	      T1 = T0
	      buffered = .false.
	    endif
c
c  Accumulate more data, if we are time averaging.
c
	    if(.not.buffered)call GetXAxis(tIn,xaxis,xtitle,x,
     +          nplot,xrange,interval.gt.0)
	    if(avall)preamble(5) = 257
	    call uvrdvrr(tIn,'inttime',inttime,0.)
	    call BufAcc(doflag,doall,preamble,inttime,data,flags,
     *        nread,ibin,ncount)
	    buffered = .true.
	    nchan = nread
c
c  Keep on going. Read in another record.
c
	    call uvDatRd(preamble,data,flags,maxchan,nread)
         call uvDatGtr('variance',sig2) 
	 rms2 = rms2 + sig2
         nncount = nncount + 1
	  enddo
c
c  Flush out and plot anything remaining.
c
	  if(buffered)then
	    sig = sqrt(rms2/real(nncount))/sqrt(real(ncount)/2.)
	    call BufFlush(ampsc,rms,nobase,dodots,dohdr,domnoise,hann,
     *	      hc,hw,first,device,x,nplot,xtitle,ytitle,nxy,xrange,
     *        yrange,sig,rms2,ncount,nncount,logf,dotimelog)
	    rms2 = 0.
	    ncount = 0
	    nncount = 0
	    buffered = .false.
	  endif
	  call uvDatCls
	enddo
c
	if(first)call bug('f','Nothing to plot')
	if(logf.ne.' ') call LogClose
	call pgend

	end
c************************************************************************
	subroutine ShiftIt(tIn,uvw,data,nchan,lmn)
c
	implicit none
	integer tIn,nchan
	double precision uvw(3)
	double precision lmn(3)
	complex data(nchan)
c
c  Shift the data.
c
c------------------------------------------------------------------------
	include 'maxdim.h'
	include 'mirconst.h'
	double precision sfreq(MAXCHAN)
	real theta,theta0
	complex w
	integer i
c
c  Get the sky frequency.
c
	call uvinfo(tIn,'sfreq',sfreq)
c
c  Shift the data.
c
	theta0 = -2*pi * (uvw(1)*lmn(1) + uvw(2)*lmn(2) + 
     *			  uvw(3)*(lmn(3)-1))
	do i=1,nchan
	  theta = theta0 * sfreq(i)
	  w = cmplx(cos(theta),sin(theta))
	  data(i) = w * data(i)
	enddo
c	
	end
c************************************************************************
	subroutine GetXAxis(tIn,xaxis,xtitle,x,nchan,xrange,aver)
c
	implicit none
	integer tIn,nchan
	character xaxis*(*),xtitle*(*)
        logical aver
	double precision x(nchan)
c
c  Determine the X axis coordinates for each channel.
c
c  Input:
c    tIn
c    xaxis
c    nchan
c  Output:
c    x
c------------------------------------------------------------------------
	include 'mirconst.h'
	include 'maxdim.h'
	integer VELO
	parameter(VELO=3)
c
	integer i,i0, nrm
	real rmstep, rmmax, lam2ave, lam2(10*MAXCHAN), rm(10*MAXCHAN)
	real rmtffwhm
	double precision data(6),start,step
	character vel*32
	real xrange(2)
	double precision freq(10*MAXCHAN)
        logical warned/.false./
        logical veltype
	common /faraday/freq,rmmax,nrm,rmstep,lam2ave,lam2,rm,rmtffwhm

c
c  Externals.
c
	integer len1
c
        veltype=.false.
	if(xaxis.eq.'channel') then
	  call uvinfo(tIn,'line',data)
	  start = data(3)
	  if(nint(data(1)).ne.VELO)start = start + 0.5*(data(4)-1)
	  step = data(5)
	  do i=1,nchan
	    x(i) = start + (i-1)*step
	  enddo
	  if(nint(data(1)).eq.VELO)then
	    call VelSys(tIn,vel,'radio')
	    xtitle = 'Velocity Channels('//vel(1:len1(vel))//') (km/s)'
	  else
	    xtitle = 'Channels'
	  endif
	else if(xaxis.eq.'velocity')then
	  call VelSys(tIn,vel,'radio')
	  xtitle = 'Velocity('//vel(1:len1(vel))//') (km/s)'
	  call uvinfo(tIn,'velocity',x)
          veltype=.true.
	else if(xaxis.eq.'felocity')then
	  call VelSys(tIn,vel,'optical')
	  xtitle = 'Velocity('//vel(1:len1(vel))//') (km/s)'
	  call uvinfo(tIn,'felocity',x)
          veltype=.true.
	else if(xaxis.eq.'frequency')then
	  xtitle = 'Frequency (GHz)'
	  call uvinfo(tIn,'sfreq',x)
	else if(xaxis.eq.'dfrequency')then
	  xtitle = 'Doppler-Corrected Frequency (GHz)'
	  call uvinfo(tIn,'frequency',x)
          veltype=.true.
	else if(xaxis.eq.'lag')then
	  i0 = -nchan/2
	  do i=1,nchan
	    x(i) = i0
	    i0 = i0 + 1
	  enddo
	  xtitle = 'Lag Number'

        else if(xaxis.eq.'rm')then

	  call uvinfo(tIn,'line',data)
	  start = data(3)
	  if(nint(data(1)).ne.VELO)start = start + 0.5*(data(4)-1)
	  step = data(5)
	  do i=1,nchan
	    x(i) = start + (i-1)*step
	  enddo

          xtitle = 'Faraday Depth (rad m\u-2\d)'
	  call uvinfo(tIn,'sfreq',freq)

c 	  Convert from frequency to wavelength
	  lam2ave = 0.
  	  do i = 1, nchan
               lam2(i) = (DCMKS/(real(freq(i))*1e9))**2
               lam2ave = lam2ave + lam2(i)/nchan
  	  enddo

	  if (xrange(2).le.xrange(1)) then
             rmmax = sqrt(3.)/abs((lam2(1))-(lam2(2)))
	  else
	     rmmax = max(abs(xrange(1)),abs(xrange(2)))
	  endif
	  rmtffwhm = 2.*sqrt(3.)/abs((lam2(nchan))-(lam2(1)))
          rmstep = rmtffwhm/25.
          nrm = int(2.*rmmax/rmstep+1)
          do i=1,nrm 
             rm(i) = -1.*rmmax + (real(i)-1.)*rmstep
          enddo

        else if(xaxis.eq.'lambda2' )then


          xtitle = 'Wavelength squared (m\u-2\d)'
          call uvinfo(tIn,'sfreq',freq)
c         Convert from frequency to wavelength
          do i = 1, nchan
               x(i) = (DCMKS/(real(freq(i))*1e9))**2
          enddo


	else
	  call bug('f','Unrecognised xaxis')
	endif
        if (.not.warned.and.veltype.and.aver) then
	  call uvinfo(tIn,'line',data)
	  if(nint(data(1)).ne.VELO) then
            call bug('w','Warning plotted velocities may be inaccurate')
            call bug('w','Use line=velocity when averaging')
            warned=.true.
          endif
        endif
	end
c************************************************************************
	subroutine VelSys(tIn,vel,type)
c
	implicit none
	integer tIn
	character vel*(*),type*(*)
c
c------------------------------------------------------------------------
	character veltype*32
c
	call uvrdvra(tIn,'veltype',veltype,'VELO-LSR')
	if(veltype(6:8).eq.'LSR')then
	  vel = type//',LSR'
	else if(veltype(6:8).eq.'HEL')then
	  vel = type//',Barycentric'
	else if(veltype(6:8).eq.'OBS')then
	  vel = type//',Topocentric'
	else
	  vel = type//',unknown'
	endif
	end
c************************************************************************
	subroutine GetAxis(xaxis,yaxis)
c
	implicit none
	character xaxis*(*),yaxis*(*)
c
c  Determine the X and Y axis to plot.
c
c  Output:
c    xaxis
c    yaxis
c------------------------------------------------------------------------
	integer NX,NY
	parameter(NX=8,NY=6)
c
	integer n
	character xaxes(NX)*10,yaxes(NY)*9
	data xaxes/'channel   ','frequency ','velocity  ','felocity  ',
     *		   'lag       ','dfrequency','rm        ','lambda2   '/
	data yaxes/'amplitude','phase    ','real     ','imaginary',
     *             'noise    ','polang   '/
c
	call keymatch('axis',NX,xaxes,1,xaxis,n)
	if(n.eq.0)xaxis = xaxes(1)

C	If plotting RM, yaxis is always real
	if (xaxis.eq.xaxes(7)) then
	   call keymatch('axis',NY,yaxes,1,yaxis,n)
     	   if (yaxis.ne.yaxes(3)) then
              call bug('w','Y axis defaulting to real component for '//
     +          'X axis = RM')
	      yaxis = yaxes(3)
	   endif
        else
	   call keymatch('axis',NY,yaxes,1,yaxis,n)
	   if(n.eq.0)yaxis = yaxes(1)
	endif

	end
c************************************************************************
	subroutine GetOpt(uvflags,ampsc,rms,nobase,avall,dodots,
     *		doflag,doall,dosdo,dohdr,domnoise,dotimelog)
c
	implicit none
        logical ampsc,rms,nobase,avall,dodots,doflag,doall,dosdo,dohdr
        logical domnoise,dotimelog
	character uvflags*(*)
c
c  Determine the flags to pass to the uvdat routines.
c
c  Output:
c    uvflags	Flags to pass to the uvdat routines.
c    ampsc      True for amp-scalar averaging.
c    rms	True for amp-rms averaging.
c    nobase
c    avall
c    dodots
c    doflag
c    doall
c------------------------------------------------------------------------
	integer nopts
	parameter(nopts=14)
	character opts(nopts)*9
	logical present(nopts),docal,dopol,dopass
	data opts/'nocal    ','nopol    ','ampscalar','nopass   ',
     *		  'nobase   ','avall    ','dots     ','rms      ',
     *            'flagged  ','all      ','sdo      ','hdr      ',
     *            'mnoise   ','timelog  '/
c
	call options('options',opts,present,nopts)
	docal = .not.present(1)
	dopol = .not.present(2)
	dopass= .not.present(4)
        ampsc =    present(3)
	rms   =    present(8)
	if(ampsc.and.rms)call bug('f',
     *	  'Only one amplitude averaging option can be given')
	nobase =   present(5)
	avall  =   present(6)
        dodots =   present(7)
        doflag =   present(9)
	doall  =   present(10)
        dosdo  =   present(11)
        dohdr  =   present(12)
        domnoise=   present(13)
	dotimelog= present(14)
	if(doflag.and.doall)call bug('f',
     *	  'The "flagged" and "all" options are mutually exclusive')
c
	uvflags = 'dsl3'
	if(dopass)uvflags(5:5) = 'f'
	if(dopol) uvflags(6:6) = 'e'
	if(docal) uvflags(7:7) = 'c'
	end
c************************************************************************
	subroutine BufIni
	implicit none
c
c  Initialise the routines which do the buffering and averaging of
c  the visibility data.
c  All the buffering/averaging is performed in arrays stored in a
c  common block.
c
c------------------------------------------------------------------------
	include 'uvspec.h'

	free = 1
	mbase = 0
	end
c************************************************************************
	subroutine BufFlush(ampsc,rms,nobase,dodots,dohdr,domnoise,hann,
     *	        hc,hw,first,device,x,n,xtitle,ytitle,nxy,xrange,yrange,
     *          sig,rms2,ncount,nncount,logf,dotimelog)
c
	implicit none
	logical ampsc,rms,nobase,first,dodots,dohdr,domnoise,dotimelog
	character device*(*),xtitle*(*),ytitle*(*),logf*(*)
	integer n,nxy(2),hann
	real xrange(2),yrange(2),hc(*),hw(*)
	double precision x(n)
c
c  Plot the averaged data. On the first time through, also initialise the
c  plot device.
c
c------------------------------------------------------------------------
	include 'uvspec.h'
	integer PolMin,PolMax
	parameter(PolMin=-8,PolMax=4)
	integer MAXPLT,maxpnts
	parameter(maxpnts=1000000,MAXPLT=1024)
        double precision xp(maxpnts)
	real inttime,yp(maxpnts)
	integer plot(MAXPLT+1)
	double precision time
	integer i,j,ngood,ng,ntime,npnts,nplts,nprev,p
	logical doamp,doampsc,dorms,dophase,doreal,doimag,dopoint,
     +     dolag,dorm,dolam,doang
	logical dosdo,donoise,Hit(PolMin:PolMax)
	integer npol,pol(MAXPOL)
        character stcat*80
	real sig, rms2
	integer ncount, nncount
        
c
c  Determine the conversion of the data.
c
	dorm = xtitle(1:7).eq.'Faraday'
	dolam= xtitle(1:10).eq.'Wavelength'
	doamp = index(ytitle,'Amp').gt.0
        dohdr = (dohdr.and.doamp).and..not.dorm
        if (dohdr.and..not.dorm) ytitle = 'Amplitude+1'
	dolag = xtitle.eq.'Lag Number'
	doampsc = doamp.and.ampsc
	dorms   = (doamp.and.rms).and..not.dorm
	if(doampsc)doamp = .false.
	if(dorms)  doamp = .false.
	dophase = ytitle(1:5).eq.'Phase'
	dopoint = dophase
	doreal  = (ytitle(1:4).eq.'Real').or.(dorm)
	doimag  = ytitle(1:9).eq.'Imaginary'
        dosdo   = index(ytitle,'SDO').gt.0
        donoise = ytitle(1:5).eq.'Noise'
	doang = ytitle(1:12).eq.'Polarisation'
        if(domnoise.and.donoise) ytitle = 'Noise in mean'
c
c  Determine the number of good baselines.
c
	ngood = 0
	do j=1,mbase
	  if(cnt(j).gt.0)ngood = ngood + 1
	enddo
	if(ngood.le.0)return
        if (first) then
 	  if (dorm) ytitle = 'Flux'
          if (.not.dophase.and..not.doang) ytitle=stcat(ytitle,' (Jy)')
          if (dophase.or.doang) ytitle=stcat(ytitle,' (deg)')
        endif
c
c  Initialise the plot device, if this is the first time through.
c
	ng = ngood
	if(nobase) ng = 1
	if(first)call PltIni(device,ng,nxy)
	first = .false.
 
c  Autoscale the X axis if needed
	if (xrange(2).le.xrange(1).and..not.dorm) 
     +       call SetAxisD(x,n,xrange)

c
c  Now loop through the good baselines, plotting them.
c
	inttime = 0
	time = 0
	ntime = 0
	npnts = 0
	nplts = 0
	npol = 0
	do i=PolMin,PolMax
	  Hit(i) = .false.
	enddo
c
	do j=1,mbase

	  if(cnt(j).gt.0)then
	    inttime = inttime + preamble(6,j)
	    time = time + preamble(4,j)
	    ntime = ntime + cnt(j)
c
c  Average the data in each polarisation. If there is only one scan in the
c  average, not bother to average it.
c
	    do i=1,npols(j)
	      if(.not.Hit(pols(i,j)))then
		npol = npol + 1
		if(npol.gt.MAXPOL)call bug('f','Too many polarisations')
		pol(npol) = pols(i,j)
		Hit(Pols(i,j)) = .true.
	      endif
	      nprev = npnts
	      p = pnt(i,j)
	      if(cntp(i,j).ge.1)then
		if(dolag)then
		  call LagExt(x,buf(p),count(p),nchan(i,j),n,
     *		    xp,yp,maxpnts,npnts)
		else
		  call VisExt(x,buf(p),buf2(1,p),bufr(p),count(p),
     *		    nchan(i,j),
     *		    doamp,doampsc,dorms,dophase,doreal,doimag,dohdr,
     *		    donoise,domnoise,dorm,doang,xp,yp,maxpnts,npnts)
		endif
	      endif
c
c  Did we find another plot.
c
	      if(npnts.gt.nprev)then
		nplts = nplts + 1
		if(nplts.gt.MAXPLT)call bug('f',
     *		  'Buffer overflow(plots), when accumulating plots')
		plot(nplts) = nprev + 1
		plot(nplts+1) = npnts + 1
	      endif
	    enddo
	    if(.not.nobase.and.npnts.gt.0)then
	      sig = sqrt(rms2/real(nncount))/sqrt(real(ncount)/2.)
	      sig = sig*sqrt(real(ng))
	      call Plotit(npnts,xp,yp,xrange,yrange,dodots,plot,nplts,
     *		xtitle,ytitle,j,time/ntime,inttime/nplts,pol,npol,
     *		dopoint,hann,hc,hw,logf,maxpnts,dohdr,dotimelog,dorm,
     *	        doang,sig)
c
	      npol = 0
	      do i=PolMin,PolMax
		Hit(i) = .false.
	      enddo
	      npnts = 0
	      nplts = 0
	      ntime = 0
	      time = 0
	      inttime = 0
	    endif
	  endif
	enddo
c
c  Do the final plot.
c
	if(npnts.gt.0) then 
	   sig = sqrt(rms2/real(nncount))/sqrt(real(ncount)/2.)
	   sig = sig*sqrt(real(ng))
	   call Plotit(npnts,xp,yp,xrange,yrange,dodots,
     *	  plot,nplts,xtitle,ytitle,0,time/ntime,inttime/nplts,
     *	 pol,npol,dopoint,hann,hc,hw,logf,maxpnts,dohdr,dotimelog,dorm,
     *   doang,sig)
	endif
c
c  Reset the counters.
c
	free = 1
	mbase = 0
c
	end
c************************************************************************
	subroutine VisExt(x,buf,buf2,bufr,count,nchan,
     *		    doamp,doampsc,dorms,dophase,doreal,doimag,
     *		    dohdr,donoise,domnoise,dorm,doang,
     *              xp,yp,maxpnts,npnts)
c
	implicit none
	integer nchan,npnts,maxpnts,count(nchan)
	logical doamp,doampsc,dorms,dophase,doreal,doimag,dohdr
        logical donoise,domnoise,dorm,doang
	real bufr(nchan),buf2(2,nchan),yp(maxpnts)
	double precision x(nchan),xp(maxpnts)
	complex buf(nchan)
c------------------------------------------------------------------------
	include 'mirconst.h'
	integer k
	real temp
	complex ctemp
c
c  Externals
c
        character*8 itoaf
c
	do k=1,nchan
	  if(count(k).gt.0)then
	    if(doamp)then
              temp = abs(buf(k)) / count(k)
              if (dohdr) temp = log10(1+temp)
	    else if(doampsc)then
	      temp = bufr(k) / count(k)
              if (dohdr) temp = log10(1+temp)
	    else if(dorms)then
	      temp = sqrt((buf2(1,k)+buf2(2,k)) / count(k))
              if (dohdr) temp = log10(1+temp)
	    else if(dophase)then
	      ctemp = buf(k)
	      if(abs(real(ctemp))+abs(aimag(ctemp)).eq.0)then
		temp = 0
	      else
		temp=180/pi*atan2(aimag(ctemp),real(ctemp))
	      endif
	    else if(doreal.or.dorm.or.doang)then
	      temp = real(buf(k)) / count(k)
	    else if(doimag)then
	      temp = aimag(buf(k)) / count(k)
            else if (donoise) then
              temp = (buf2(1,k)+buf2(2,k))/(2*count(k))-
     *        ((real(buf(k))/count(k))**2+(aimag(buf(k))/count(k))**2)/2
              if (domnoise) temp=temp/count(k)
              temp = sqrt(abs(temp))
	    endif
	    npnts = npnts + 1
	    if(npnts.gt.maxpnts)call bug('f',
     *	      'Buffer overflow('//itoaf(npnts)//
     *        '> maxpnts), when accumulating plots')
	    xp(npnts) = x(k)
	    yp(npnts) = temp
	  endif
	enddo
c
	end
c************************************************************************
	subroutine LagExt(x,buf,count,nchan,n,
     *		    xp,yp,maxpnts,npnts)
c
	implicit none
	integer nchan,n,npnts,maxpnts,count(nchan)
	double precision x(n),xp(maxpnts)
        real yp(maxpnts)
	complex buf(nchan)
c------------------------------------------------------------------------
	include 'maxdim.h'
	real rbuf(2*(MAXCHAN-1))
	complex cbuf(MAXCHAN)
	integer k,k0
c
c  Normalise.
c
	do k=1,nchan
	  if(count(k).gt.0)then
	    cbuf(k) = buf(k) / count(k)
	  else
	    cbuf(k) = 0
	  endif
	enddo
	do k=nchan+1,n/2+1
	  cbuf(k) = 0
	enddo
c
	call fftcr(cbuf,rbuf,-1,n)
c
	k0 = n/2
	do k=1,n
	  k0 = k0 + 1
	  if(k0.gt.n)k0 = k0 - n
	  npnts = npnts + 1
	  if(npnts.gt.maxpnts)call bug('f',
     *		'Buffer overflow: Too many points to plot')
	  xp(npnts) = x(k)
	  yp(npnts) = rbuf(k0)
	enddo
c
	end
c************************************************************************
	subroutine BufAcc(doflag,doall,preambl,inttime,data,flags,nread,
     *     ibin,ncount)
c
	implicit none
	integer nread,ibin,ncount
	double precision preambl(5)
	real inttime
	complex data(nread)
	logical flags(nread),doflag,doall
c
c  This accumulates the visibility data. The accumulated data is left
c  in common.
c
c  Input
c    doflag     Plot flagged data instead of unflagged
c    ibin       Bin number of current block of data (or 0)
c  Input/Output:
c    preambl	Preamble. Destroyed on output.
c    data	The correlation data to be averaged. Destroyed on output.
c    flags	The data flags.
c    nread	The number of channels.
c    ncount	Number of good data points
c------------------------------------------------------------------------
	include 'uvspec.h'
	integer i,i1,i2,p,bl,pol
	real re,im
	logical ok
c
c  Does this spectrum contain some good data.
c
	ok = doall
	if(.not.ok)then
	  do i=1,nread
	    ok = ok.or.(flags(i).neqv.doflag)
	  enddo
	endif
	if(.not.ok)return
c
c  Determine the baseline number.
c
	call BasAnt(preambl(5),i1,i2)
	bl = (i2*(i2-1))/2 + i1
c
c  Zero up to, and including, this baseline.
c
	do i=mbase+1,bl
	  cnt(i) = 0
	enddo
	mbase = max(mbase,bl)
c
c  Add in this visibility.
c
	if(cnt(bl).eq.0)then
	  cnt(bl) = 1
	  npols(bl) = 0
	  preamble(1,bl) = preambl(1)
	  preamble(2,bl) = preambl(2)
	  preamble(3,bl) = preambl(3)
	  preamble(4,bl) = preambl(4)
	  preamble(5,bl) = preambl(5)
	  preamble(6,bl) = inttime
	else
	  cnt(bl) = cnt(bl) + 1
	  preamble(1,bl) = preamble(1,bl) + preambl(1)
	  preamble(2,bl) = preamble(2,bl) + preambl(2)
	  preamble(3,bl) = preamble(3,bl) + preambl(3)
	  preamble(4,bl) = preamble(4,bl) + preambl(4)
	  preamble(5,bl) = preamble(5,bl) + preambl(5)
	  preamble(6,bl) = preamble(6,bl) + inttime
	endif
c
c  Determine the polarisation.
c
	call uvDatGti('pol',pol)
	p = 0
	do i=1,npols(bl)
	  if(pols(i,bl).eq.pol) p = i
	enddo
c
c  A new baseline. Set up the description of it.
c
	if(p.eq.0)then
	  npols(bl) = npols(bl) + 1
	  p = npols(bl)
	  if(p.gt.MAXPOL) call bug('f',
     *	    'Too many polarizations, in BufAcc')
	  pols(p,bl) = pol
	  cntp(p,bl) = 1
	  nchan(p,bl) = nread
	  pnt(p,bl) = free
	  free = free + nread
	  if(free.gt.MAXAVER)call bug('f',
     *	    'Too much data to accumulate, in BufAcc')
c
c  Copy across the new data.
c
	  p = pnt(p,bl) - 1
	  do i=1,nread
	    if(doall.or.(doflag.neqv.flags(i)))then
	      if(ibin.eq.0.or.ibin.eq.2) buf(i+p) = data(i)
	      if (ibin.eq.1) buf(i+p) = -data(i)
              re = real(data(i))
              im = aimag(data(i))
              bufr(i+p) = abs(data(i))
	      buf2(1,i+p) = re*re
              buf2(2,i+p) = im*im
	      count(i+p) = 1
	      ncount = ncount + 1
	    else
	      buf(i+p) = (0.0,0.0)
              bufr(i+p) = 0.0
	      buf2(1,i+p) = 0.0
	      buf2(2,i+p) = 0.0
	      count(i+p) = 0
	    endif
	  enddo
c
c  Else accumulate new data for old baseline.
c
	else
	  cntp(p,bl) = cntp(p,bl) + 1
	  nread = min(nread,nchan(p,bl))
	  nchan(p,bl) = nread
	  p = pnt(p,bl) - 1
	  do i=1,nread
	    if(doall.or.(doflag.neqv.flags(i)))then
              if (ibin.eq.1) buf(i+p) = buf(i+p) - data(i)
              if (ibin.eq.0.or.ibin.eq.2) buf(i+p) = buf(i+p) + data(i)
              re = real(data(i))
              im = aimag(data(i))
              bufr(i+p) = bufr(i+p) + abs(data(i))
	      buf2(1,i+p) = buf2(1,i+p) + re*re
              buf2(2,i+p) = buf2(2,i+p) + im*im
	      count(i+p) = count(i+p) + 1
	      ncount = ncount + 1
	    endif
	  enddo
	endif
c
	end
c************************************************************************
	subroutine PltIni(device,ngood,nxy)
c
	implicit none
	character device*(*)
	integer ngood,nxy(2)
c
c  Initialise the plot device.
c
c------------------------------------------------------------------------
	integer nx,ny
	character hard*4
	integer hlen
c
c  Externals.
c
	integer pgbeg
c
c  Determine the default plots per page in X and Y
c
	nx = nxy(1)
	ny = nxy(2)
	if(nx.le.0.or.ny.le.0)then
	  nx = 2
	  if(mod(ngood,3).eq.0)nx = 3
	  ny = 2
	  if(mod(ngood,9).eq.0)ny = 2
	endif
	if(pgbeg(0,device,nx,ny).ne.1)then
	  call pgldev
	  call bug('f','Error opening graphics device')
	endif
	call pgsch(real(max(nx,ny))**0.4)
	call pgqinf('hardcopy',hard,hlen)
	if(hard.eq.'YES')call pgscf(2)
	end
c************************************************************************
	subroutine SetAxisD(data,npnts,range)
c
	implicit none
	integer npnts
	real range(2)
	double precision data(npnts)
c
c  Determine the range, for autoscaling, or the data.
c
c  Input:
c    data
c    npnts
c  Output:
c    range
c------------------------------------------------------------------------
	double precision dmax,dmin
	integer i
c
	dmax = data(1)
	dmin = dmax
	do i=2,npnts
	  dmax = max(data(i),dmax)
	  dmin = min(data(i),dmin)
	enddo
c
	call pgrnge(real(dmin),real(dmax),range(1),range(2))
c
	end
c************************************************************************
	subroutine SetAxisR(data,npnts,range)
c
	implicit none
	integer npnts
	real range(2)
	real data(npnts)
c
c  Determine the range, for autoscaling, or the data.
c
c  Input:
c    data
c    npnts
c  Output:
c    range
c------------------------------------------------------------------------
	real dmax,dmin,delta,maxv
	integer i
c
	dmax = data(1)
	dmin = dmax
	do i=2,npnts
	  dmax = max(data(i),dmax)
	  dmin = min(data(i),dmin)
	enddo
c
	delta = 0.05*(dmax - dmin)
	maxv = max(abs(dmax),abs(dmin))
	if(delta.le.1e-4*maxv) delta = 0.01*maxv
	if(delta.eq.0) delta = 1
	range(1) = dmin - delta
	range(2) = dmax + delta
	end
c************************************************************************
	subroutine Plotit(npnts,xp,yp,xrange,yrange,dodots,
     *		  plot,nplts,xtitle,ytitle,bl,time,inttime,
     *		  pol,npol,dopoint,hann,hc,hw,logf,maxpnts,dohdr,
     *            dotimelog,dorm,doang,sig)
c
	include 'mirconst.h'
	include 'maxdim.h'

	implicit none
	integer npnts,bl,nplts,plot(nplts+1),npol,pol(npol),hann,maxpnts
	double precision time,xp(npnts)
        real x(maxpnts)
	real inttime,hc(*),hw(*),xrange(2),yrange(2),yp(npnts)
	logical dopoint,dodots,dohdr,dotimelog,dorm,doang
	character xtitle*(*),ytitle*(*),logf*(*),date*18
	real lam2ave,rmmax,rmstep,rmtffwhm
	integer nchan, nrm
	real lam2(10*MAXCHAN), qq(10*MAXCHAN), uu(10*MAXCHAN)
	real polr, poli, rm(10*MAXCHAN), fdmax
	real rmpeak, polpeak, rpeak, ipeak
	complex fd(10*MAXCHAN)
	real fdamp(10*MAXCHAN), fdr(10*MAXCHAN), fdi(10*MAXCHAN)
	complex rmtfc(10*MAXCHAN)
	real rmtfamp(10*MAXCHAN), rmtfr(10*MAXCHAN), rmtfi(10*MAXCHAN)
	real sig

C	Polynomial fit to peak, for npt points around peak
	integer ierr, maxnum, npt
        parameter (npt=7)
        real xx(npt), yy(npt), ww(npt)
        real poly(3),rnorm, phi(6), phix(80)
	character*12 rmstr, ampstr, rstr, istr, angstr, lamstr, sigstr,
     *               fwhmstr, errstr


	
c
c  Draw a plot
c------------------------------------------------------------------------
	integer NCOL
	parameter(NCOL=12)
        real TOL1,TOL2
        parameter(TOL1=1.e-5,TOL2=5.e-7)
	integer hr,mins,sec,b1,b2,l,i,j,xl,yl,symbol,lp,lt
	character title*64,baseline*12,tau*16,line*80
	character pollab*32,xtitle2*80
	double precision T0
	real xranged(2),yranged(2),xoff,delta1,delta2
	real xlen,ylen,xloc,size
	integer k1,k2
	double precision freq(10*MAXCHAN)
	common /faraday/freq,rmmax,nrm,rmstep,lam2ave,lam2,rm,rmtffwhm
c
c  Externals.
c
	integer len1
	character itoaf*4,PolsC2P*2
c
c
        symbol = 17
        if (dodots) symbol = 1
c
	call pgpage
	call pgvstd
c
        xoff = 0
        delta1 = abs((xrange(2)-xrange(1))/max(xrange(1),xrange(2)))
        delta2 = delta1
        if (npnts.gt.0) delta2=delta1/npnts*nplts
c
c  Time of day.
c
	T0 = nint(time - 1.d0) + 0.5
	sec = nint(24*3600*(time - T0))
	hr = sec / 3600
	sec = sec - 3600*hr
	mins = sec / 60
	sec = sec - 60*mins
	call JulDay(time,'H',date)
c
c  Check for potential axis labeling and plot accuracy issues, use offset 
c
        if (delta1.lt.TOL1.or.delta2.lt.TOL2) then
          xoff=min(xrange(1),xrange(2))
          xoff=int(xoff*1000)/1000.0
          xranged(1)=xrange(1)-xoff
          xranged(2)=xrange(2)-xoff
        else
          xranged(1)=xrange(1)
          xranged(2)=xrange(2)
        endif
        do i=1,npnts
          x(i)=xp(i)-xoff
        enddo

C	Compute polarisation angle
	if (doang) then
	  do j = 1,plot(2)-plot(1)
            yp(plot(1)+j-1) = atan2(yp(plot(2)+j-1),yp(plot(1)+j-1))
     +        * 0.5/pi*180.
	  enddo
	  nplts = 1
	endif

C 	Perform RM synthesis if needed
  	if (dorm) then

          nplts = 1
          nchan = plot(2)-plot(1)
          do j = 1, nchan
            qq(j) = yp(plot(1)+j-1)
            uu(j) = yp(plot(2)+j-1)
          enddo

          if (xrange(2).le.xrange(1)) then
            xranged(2) = rmmax*1.1
            xranged(1) = -1.*xranged(2)
          endif
          fdmax = -1e10
          do j=1,nrm 
            fd(j) = (0.,0.)
            do i = 1,nchan
              polr = qq(i)*cos(2.*rm(j)*(lam2(i)-real(lam2ave)))
     +            + uu(i)*sin(2.*rm(j)*(lam2(i)-real(lam2ave)))
             poli = uu(i)*cos(2.*rm(j)*(lam2(i)-real(lam2ave)))
     +            - qq(i)*sin(2.*rm(j)*(lam2(i)-real(lam2ave)))
             fd(j) = fd(j) + complex(polr,poli)/nchan
            enddo
            fdamp(j) = abs(fd(j))
            fdr(j) = real(fd(j))
            fdi(j) = imag(fd(j))
            if (fdamp(j).gt.fdmax) then
              fdmax = fdamp(j)
              rmpeak = rm(j)
              maxnum = j
            endif
          enddo

C       Do npt-point quadratic fit to peak
          do i = 1,npt
             xx(i) = rm(maxnum-npt/2-1+i)
             yy(i) = fdamp(maxnum-npt/2-1+i)
             ww(i) = 1.0
          enddo
             
          call wpfit(2,npt,xx,yy,ww,poly,rnorm,phi,phix,ierr)
          if (ierr.ne.0) then
            call bug('f','RM synthesis: polynomial fit failed')
          endif
          rmpeak = -poly(2)/2./poly(3)
          polpeak = poly(1) + poly(2)*rmpeak +
     +      poly(3)*rmpeak*rmpeak

C	Determine real and imag at peak
	  rpeak = 0.
	  ipeak = 0.
	  do i = 1,nchan
            rpeak = rpeak 
     +       + qq(i)*cos(2.*rmpeak*(lam2(i)-real(lam2ave)))/nchan
     +       + uu(i)*sin(2.*rmpeak*(lam2(i)-real(lam2ave)))/nchan
	    ipeak = ipeak
     +       + uu(i)*cos(2.*rmpeak*(lam2(i)-real(lam2ave)))/nchan
     +       - qq(i)*sin(2.*rmpeak*(lam2(i)-real(lam2ave)))/nchan
	  enddo

C	Construct RMTF
          do j=1,nrm 
	    rmtfc(j) = (0.,0.)
	    do i = 1,nchan
               polr = cos(2.*(rm(j)-rmpeak)*(lam2(i)-real(lam2ave)))
               poli = -1.*qq(i)*sin(2.*(rm(j)-rmpeak)*
     +            (lam2(i)-real(lam2ave)))
	       rmtfc(j) = rmtfc(j) + complex(polr,poli)/nchan*polpeak
	    enddo
            rmtfamp(j) = abs(rmtfc(j))
	    rmtfr(j) = real(rmtfc(j))
	    rmtfi(j) = imag(rmtfc(j))
	  enddo

	  write (fwhmstr, '(f12.3)') rmtffwhm
	  write (rmstr, '(f12.3)') rmpeak
	  write (errstr, '(f12.3)') rmtffwhm/2.355/(polpeak/sig)
	  write (ampstr, '(f12.3)') polpeak*1000.
	  write (rstr, '(f12.3)') rpeak*1000.
	  write (istr, '(f12.3)') ipeak*1000.
	  write (angstr, '(f12.3)') atan2(ipeak,rpeak)/2./pi*180.
	  write (lamstr, '(f12.3)') sqrt(lam2ave)
	  write (sigstr, '(f12.3)') sig*1000.
	  call output ('')
	  call output('RMTF FWHM         = '//fwhmstr(1:12)//' rad/m/m')
	  call output('Peak RM           = '//rmstr(1:12)//' +/- '
     +                //errstr(1:12)//' rad/m/m')
	  call output('Pol at peak RM    = '//ampstr(1:12)//' mJy')
	  call output('Real component    = '//rstr(1:12)//' mJy')
	  call output('Imag component    = '//istr(1:12)//' mJy')
	  call output('Theoretical noise = '//sigstr(1:12)//' mJy')
	  call output('Pol angle         = '//angstr(1:12)//' degrees'//
     +                ' at '//lamstr(1:12)//' metres')
	  call output ('')
	
	endif

	if(yrange(2).le.yrange(1))then
          if(dorm) then
	    call SetAxisR(fdamp,nrm,yranged)
              yranged(1) = -1.1*yranged(2)
              yranged(2) = 1.1*yranged(2)
	  else if (doang) then
	    call SetAxisR(yp,npnts/2,yranged)
	  else
	    call SetAxisR(yp,npnts,yranged)
	  endif

	  call pgswin(xranged(1),xranged(2),yranged(1),yranged(2))
	else
	  call pgswin(xranged(1),xranged(2),yrange(1),yrange(2))
	endif

	if (dohdr) then
          call pgbox('BCNST',0.,0.,'BCNSTL',0.,0.)
        else
          call pgbox('BCNST',0.,0.,'BCNST',0.,0.)
        endif
	
	do i=1,nplts
	  call pgsci(mod(i-1,NCOL)+1)
	  if(dopoint)then
	    call pgpt(plot(i+1)-plot(i),x(plot(i)),yp(plot(i)),symbol)
	  else
	    if (hann.gt.1) call hannsm(hann,hc,plot(i+1)-plot(i),
     *                  yp(plot(i)),hw)
	    if (dorm) then
	      call pgsci(1)
   	      call pgline(nrm,rm,fdamp)
	      call pgsls(2)
   	      call pgline(nrm,rm,rmtfamp)
	      call pgsls(1)
	      call pgsci(2)
  	      call pgline(nrm,rm,fdr)
	      call pgsci(3)
   	      call pgline(nrm,rm,fdi)

C	      Draw 1-sigma sensitivity lines
	      call pgsci(1)
	      call pgsls(3)
	      call pgmove(-1.*rmmax,sig)
	      call pgdraw(rmmax,sig)
	      call pgmove(-1.*rmmax,-1.*sig)
	      call pgdraw(rmmax,-1.*sig)
	      call pgsls(1)
	    else
            call pghline(plot(i+1)-plot(i),x(plot(i)),yp(plot(i)),2.0)
	    endif
	  endif
          if (logf.ne.' ') then
	    if (dotimelog)then
	       if ((plot(i+1)-plot(i)).gt.1)then
c		  write(line,'(a,i2.2,a,i2.2,a,i2.2)') 'T=',hr,':',mins,
c     *                  ':',sec
		  write(line,'(a)') date
		  call logwrit(line)
	       endif
	    endif
	    if (dorm) then
  	         do j = 1, nrm
	            write(line,'(1pe13.6,2x,1pe13.6,2x,
     *                2x,1pe13.6,2x,1pe13.6)') 
     *		       rm(j), fdamp(j), fdr(j), fdi(j)
 	         call logwrit(line)
	         enddo
	    else
  	         do j = 1, plot(i+1)-plot(i)
	            write(line,'(1pe13.6,2x,1pe13.6)') 
     *		       xp(plot(i)+j-1),yp(plot(i)+j-1)
 	         call logwrit(line)
	         enddo
	    endif
       
	  
	  endif
	enddo

	call pgsci(1)
c
c  The polarisation label.
c
	pollab = ' '
 	if (dorm) then
 	  pollab = 'Amp, Re, Im,'
	  lp = 12

         else if (doang) then
 	  pollab = 'Polarisation angle,'
	  lp = 19

	else

	lp = 0
	do i=1,npol
	  pollab(lp+1:lp+2) = PolsC2P(pol(i))
	  lp = len1(pollab)
	  pollab(lp+1:lp+1) = ','
	  lp = lp + 1
	enddo

 	endif

c
c  The integration time label.
c
	write(tau,'(f16.1)')inttime/60.
	lt = 1
	dowhile(tau(lt:lt).eq.' ')
	  lt = lt + 1
	enddo
c
	if(bl.eq.0)then
	  write(title,'(a,i2.2,a,i2.2,a,i2.2)')
     *	    pollab(1:lp)//' \gt='//tau(lt:)//' min, T=',
     *	    hr,':',mins,':',sec
	else
c
c  Decode baseline number into antenna numbers.
c
	  b2 = 1
	  l = 1
	  dowhile(bl.ge.l+b2)
	    l = l + b2
	    b2 = b2 + 1
	  enddo
	  b1 = bl - l + 1
c
	  baseline = itoaf(b1)
	  l = len1(baseline)
	  baseline(l+1:) = '-'//itoaf(b2)
	  l = len1(baseline)
c	  
	  write(title,'(a,i2.2,a,i2.2,a,i2.2)')
     *	    pollab(1:lp)//' \gt='//tau(lt:)//' min, Bl='//
     *	    baseline(1:l)//', T=',hr,':',mins,':',sec
	endif
	l = len1(title)
	xl = len1(xtitle)
	yl = len1(ytitle)
c
        xtitle2=xtitle
        if (xoff.gt.0) then
          i=index(xtitle,' (')
          if (i.gt.0) then
            write(xtitle2(i+1:i+8),'(a,F7.3)') '-',xoff
            xtitle2(i+9:xl+9)=xtitle(i:xl)
            xl=xl+9
          endif
        endif
	call pglab(xtitle2(1:xl),ytitle(1:yl),' ')
	call pglen(5,title(1:l),xlen,ylen)
	xloc = 0.5 - 0.5*xlen
	call pgqch(size)
	if(xloc.lt.0)then
	  call pgsch(size/xlen)
	  xloc = 0
	endif
c
	if (dorm) then

          call pgsci(1)
	  call pgmtxt('T',2.0,xloc,0.,title(1:5))
	  call pglen(5,title(1:5),xlen,ylen)
	  xloc = xloc + xlen
          call pgsci(2)
	  call pgmtxt('T',2.0,xloc,0.,title(6:7))
	  call pglen(5,title(6:7),xlen,ylen)
	  xloc = xloc + xlen
	  call pgsci(1)
	  call pgmtxt('T',2.0,xloc,0.,title(8:9))
	  call pglen(5,title(8:9),xlen,ylen)
	  xloc = xloc + xlen
          call pgsci(3)
	  call pgmtxt('T',2.0,xloc,0.,title(10:11))
	  call pglen(5,title(10:11),xlen,ylen)
	  xloc = xloc + xlen
	  call pgsci(1)
	  call pgmtxt('T',2.0,xloc,0.,title(12:13))
	  call pglen(5,title(12:13),xlen,ylen)
	  xloc = xloc + xlen
	  k1 = 14

	else if (doang) then
	  k1 = 1
	  k2 = k1 + len1(polsc2p(pol(1))) - 1
	  if(1.ne.npol)k2 = k2 + 1
	  call pgsci(1)
	  call pgmtxt('T',2.0,xloc,0.,title(k1:k2))
	  call pglen(5,title(k1:k2),xlen,ylen)
	  xloc = xloc + xlen
	  k1 = k2 + 1

	else
	k1 = 1
	do i=1,npol
	  k2 = k1 + len1(polsc2p(pol(i))) - 1
	  if(i.ne.npol)k2 = k2 + 1
	  call pgsci(i)
	  call pgmtxt('T',2.0,xloc,0.,title(k1:k2))
	  call pglen(5,title(k1:k2),xlen,ylen)
	  xloc = xloc + xlen
	  k1 = k2 + 1
	enddo

	endif

	call pgsci(1)
	k2 = l
	call pgmtxt('T',2.0,xloc,0.,title(k1:k2))
	call pgsch(size)
	  
	end
