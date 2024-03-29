c************************************************************************
	program uvfstats
	implicit none
c
c= uvfstats -- Print flagging statistics.
c& rjs
c: calibration
c+
c	UVFSTATS prints statistics about flagged visibilities.
c
c@ vis
c	Input visibility file. Several can be given. Wildcards are
c	supported. No default.
c@ line
c	Normal line parameter. The default is all channels.
c@ select
c	Normal visibility selection parameter. The default is to select
c	all visibilities.
c@ mode
c	This determines what the flagging statitics are determined as
c	a function of. Possible values are:
c	  stokes    Determine statistics by Stokes/pol'n parameter.
c	            This is the default.
c	  overall   Give a single overall statistic.
c	  baseline  Determine statistics by baseline number.
c	  antenna   Determine statistics by antenna number.
c	  channel   Determine statistics by channel number.
c@ options
c	Task enrichment parameters. Possible values are
c	  absolute  Give flagged correlations as an absolute number
c	            rather than a percentage.
c	  unflagged Give statistics about the unflagged (rather than
c	            flagged) correlations.
c--
c@ device
c	PGPLOT device on which the flagging statistics are plotted.
c	The default is not to make a plot, but rather just to give
c	messages about the flagging statistics.
c  History:
c    rjs  26sep95 Original version.
c    rjs   1may96 Added mode=overall.
c    rjs  05dec96 Added options=unflagged.
c------------------------------------------------------------------------
	include 'maxdim.h'
	character version*(*)
	integer MAXSELS,MAXPARM,POLMIN,MAXIN
	parameter(version='Uvfstats: version 1.0 05-Dec-96')
	parameter(MAXSELS=256,MAXPARM=MAXCHAN,POLMIN=-8,MAXIN=64)
c
	double precision lstart,lwidth,lstep
        real sels(MAXSELS)
	integer tno,nchan,npnt,nout
	integer pol,i1,i2,i,j,offset,nIn
	double precision preamble(4),ngood(MAXPARM),nbad(MAXPARM),nval
	real x(MAXPARM),y(MAXPARM)
	complex data(MAXCHAN)
	character line*32,vis(MAXIN)*80,device*64,val1*8,val2*12
	logical dogood,doabs,flags(MAXCHAN)
c
	integer NMODES,NOPTS
	parameter(NMODES=5,NOPTS=2)
	logical present(NOPTS)
	character modes(NMODES)*8,mode*8,opts(NOPTS)*10
c
c  Externals.
c
	character PolsC2P*2,BlFmt*5
c
	data modes/'stokes  ','baseline','channel ','antenna ',
     *		   'overall '/
	data opts /'absolute  ','unflagged '/
c
c  Get input parameters.
c
	call output(version)
	call keyini
	call mkeyf('vis',vis,MAXIN,nIn)
	if(nIn.eq.0)call bug('f','Input dataset must be given')
	call keya('device',device,' ')
	call keyline(line,nchan,lstart,lwidth,lstep)
	call SelInput('select',sels,MAXSELS)
	call keymatch('mode',NMODES,modes,1,mode,nout)
	if(nout.eq.0) mode = modes(1)
	call options('options',opts,present,NOPTS)
	doabs  = present(1)
	dogood = present(2)
	call keyfin
c
c  Zero the statistics arrays.
c
	do i=1,MAXPARM
	  ngood(i) = 0
	  nbad(i)  = 0
	enddo
c
c  Open the input.
c
	do j=1,nIn
	  call uvopen(tno,vis(j),'old')
	  if(line.ne.' ')call uvset(tno,'data',line,nchan,
     *					lstart,lwidth,lstep)
	  call SelApply(tno,sels,.true.)
c
c  Accumulate the statistics.
c
	  call uvread(tno,preamble,data,flags,MAXCHAN,nchan)
	  dowhile(nchan.gt.0)
	    if(mode.eq.'stokes')then
	      call uvrdvri(tno,'pol',pol,1)
	      call SetPar(pol-PolMin+1,flags,nchan,ngood,nbad,MAXPARM)
	    else if(mode.eq.'overall')then
	      call SetPar(1,flags,nchan,ngood,nbad,MAXPARM)
	    else if(mode.eq.'channel')then
	      do i=1,nchan
	        if(flags(i))then
		  ngood(i) = ngood(i) + 1
	        else
		  nbad(i)  = nbad(i) + 1
	        endif
	      enddo
	    else if(mode.eq.'antenna')then
	      call basant(preamble(4),i1,i2)
	      call SetPar(i1,flags,nchan,ngood,nbad,MAXPARM)
	      call SetPar(i2,flags,nchan,ngood,nbad,MAXPARM)
	    else if(mode.eq.'baseline')then
	      call basant(preamble(4),i1,i2)
	      call SetPar((i2*(i2-1))/2+i1,flags,nchan,
     *					ngood,nbad,MAXPARM)
	    else
	      call bug('f','Im confused')
	    endif
	    call uvread(tno,preamble,data,flags,MAXCHAN,nchan)
	  enddo
	  call uvclose(tno)
	enddo
c
	if(mode.eq.'stokes')then
	  offset = PolMin - 1
	else
	  offset = 0
	endif
c
	npnt = 0
	do i=1,MAXPARM
	  if(ngood(i)+nbad(i).gt.0)then
	    npnt = npnt + 1
	    x(npnt) = i + offset
	    if(dogood)then
	      nval = ngood(i)
	    else
	      nval = nbad(i)
	    endif
	    if(doabs)then
	      y(npnt) = nval
	    else
	      y(npnt) = 100.0*nval/(ngood(i)+nbad(i))
	    endif
	  endif
	enddo
	if(npnt.eq.0)call bug('f','No data was read!')
c
c  List if if desired.
c
	
	if(device.eq.' ')then
	  call output(' ')
	  if(mode.eq.'stokes')then
	    call output('Flagging statistics by polarisation.')
	    call TitOut('Pol. Type',dogood)
	  else if(mode.eq.'baseline')then
	    call output('Flagging statistics by baseline.')
	    call TitOut('Baseline',dogood)
	  else if(mode.eq.'antenna')then
	    call output('Flagging statistics by antenna.')
	    call TitOut('Antenna',dogood)
	  else if(mode.eq.'channel')then
	    call output('Flagging statistics by channel number.')
	    call TitOut('Channel',dogood)
	  endif
c
	  do i=1,npnt
	    if(mode.eq.'stokes')then
	      val1 = ' '//PolsC2P(nint(x(i)))
	    else if(mode.eq.'overall')then
	      val1 = 'Overall'
	    else if(mode.eq.'baseline')then
	      val1 = BlFmt(nint(x(i)))
	    else if(mode.eq.'channel'.or.mode.eq.'antenna')then
	      write(val1,'(i4)')nint(x(i))
	    endif
	    if(doabs)then
	      write(val2,'(i12)')nint(y(i))
	    else
	      write(val2,'(1x,f7.1,a)')y(i),'%'
	    endif
	    call output('     '//val1//'  '//val2)
	  enddo
	endif
c
	end
c************************************************************************
	subroutine TitOut(title,dogood)
c
	implicit none
	character title*(*)
	logical dogood
c------------------------------------------------------------------------
	character line1*64,line2*64
	integer l
c
c  Externals.
c
	integer len1
c
	line1 = '   '//title
	l = len1(line1)
	line2 = ' '
	line2(4:l) = '--------------'
c
	if(dogood)then
	  line1(18:) = 'Unflagged'
	  line2(18:) = '----------'
	else
	  line1(18:) = ' Flagged '
	  line2(18:) = '----------'
	endif
	call output(line1)
	call output(line2)
c
	end
c************************************************************************
	character*(*) function BlFmt(bl)
c
	implicit none
	integer bl
c
c  Convert a baseline number into characters.
c
c------------------------------------------------------------------------
	integer n(2),length,i
	character line*16
c
	n(2) = nint(0.5*sqrt(real(1+8*bl))-1e-5)
	n(1) = bl - (n(2)*(n(2)-1))/2
	call mitoaf(n,2,line,length)
	i = index(line(1:length),',')
	line(i:i) = '-'
	blfmt = line(1:length)
	end
c************************************************************************
	subroutine SetPar(indx,flags,nchan,ngood,nbad,nparm)
c
	implicit none
	integer indx,nchan,nparm
	double precision ngood(nparm),nbad(nparm)
	logical flags(nchan)
c------------------------------------------------------------------------
	integer i
c
	if(indx.lt.1.or.indx.gt.nparm)call bug('f','Buffer too small')
c
	do i=1,nchan
	  if(flags(i))then
	    ngood(indx) = ngood(indx) + 1
	  else
	    nbad(indx)  = nbad(indx)  + 1
	  endif
	enddo
c
	end
