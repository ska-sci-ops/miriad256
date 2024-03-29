      program clean

c= clean - Apply Hogbom, Clark or Steer CLEAN algorithm to a map
c& rjs mchw
c: deconvolution
c+
c       CLEAN is a MIRIAD task that performs a hybrid Hogbom/Clark/Steer
c       Clean algorithm, which takes a dirty map and beam, and produces
c       an output map which consists of the Clean components.  This
c       output can be input to SELFCAL to self-calibrate visibilities,
c       or input to RESTOR to produce a "clean" image.  Optionally CLEAN
c       can take as one of its inputs a model of the deconvolved image.
c       This model could be from a previous CLEAN run, or from other
c       deconvolution tasks (e.g. MAXEN).
c@ map
c       The input dirty map, which should have units of Jy/beam. No
c       default.
c@ beam
c       The input dirty beam. No default
c@ model
c       An initial model of the deconvolved image. This could be the
c       output from a previous run of CLEAN, or the output of any of the
c       deconvolution tasks (e.g. MAXEN). It must have flux units of
c       Jy/pixel. The default is no model (i.e. a zero map).
c@ out
c       The name of the output map. The units of the output will be
c       Jy/pixel.  This file will contain the contribution of the input
c       model.  It also should have a different name to the input model
c       (if any).  It can be input to RESTOR, CLEAN (as a model, to do
c       more cleaning), or SELFCAL (for self-calibrating visibility
c       data).
c@ gain
c       The minor iteration loop gain. Default is 0.1.
c@ options
c       Extra processing options. Several can be given, separated
c       by commas. Minimum match is used. Possible values are:
c         negstop   Stop when the first negative component is
c                   encounterd.  This does not apply when using Steer
c                   iterations.
c         positive  Apply a positivity constraint.  This constrains the
c                   component image to be non-negative.  A side-effect
c                   of this is that CLEAN will stop iterating if it
c                   cannot continue to ensure this.  This does not apply
c                   when using Steer iterations.
c         asym      The beam is asymmetric.  By default CLEAN assumes
c                   the beam has a 180 degree rotation symmetry, which
c                   is the norm for beams in radio-astronomy.
c         pad       Double the beam size by padding it with zeros. This
c                   will give you better stability with Clark and Steer
c                   modes if you are daring enough to CLEAN an area more
c                   than half the size (in each dimension) of the dirty
c                   beam.
c@ cutoff
c       CLEAN finishes either when the absolute maximum residual falls
c       below CUTOFF, or when the criteria described below is
c       satisfied. The default CUTOFF is 0.
c       When two values are given, do a deep clean to the second cutoff
c       limiting peak finding to the pixels that are already in the
c       model.
c@ niters
c       The maximum number of minor iterations.  The default is 250,
c       which is too small for all but the simplest of images.  CLEAN
c       will stop when either the maximum number of iterations is
c       performed, or the cutoff (see above) is reached, or if
c       options=negstop was given and a negative component was found,
c       or if options=positive was given, and no more positive
c       components could be found. An optional second
c       value will force CLEAN to report on the level reached and
c       (for mode=clark) start a new major iteration at least every
c       niters(2) iterations. This can be useful to avoid overcleaning.
c@ region
c       This specifies the region to be Cleaned.  See the help on
c       "region" for more information.  The default is the largest
c       region that can be deconvolved safely.
c@ phat
c       Cornwell's Prussian helmet parameter.  When cleaning extended
c       sources, CLEAN may produce a badly corrugated image.  This can
c       be suppressed to some extent by cleaning with a dirty beam which
c       has had a spike added at its center (i.e. a beam that looks like
c       a Prussian helmet).  PHAT gives the value of this spike, with 0
c       to 0.5 being good values.  Default is 0 (but use a non-zero
c       value for extended sources).
c@ minpatch
c       The minimum patch size when performing minor iterations, in
c       pixels.  Default is 51, but make this larger if you are having
c       problems with corrugations.  You can make it smaller when
c       cleaning images which consist of a pretty good dirty beam.
c@ speed
c       This is the same as the speed-up factor in the AIPS APCLN.
c       Negative values makes the rule used to end a major iteration
c       more conservative.  This causes fewer components to be found
c       during a major iteration, and so should improve the quality of
c       the Clean algorithm.  Usually this will not be needed unless you
c       are having problems with corrugations.  A positive value can be
c       useful when cleaning simple point-like sources.  Default is 0.
c@ mode
c       This can be either "hogbom", "clark", "steer" or "any", and
c       determines the Clean algorithm used. If the mode is "any", then
c       CLEAN determines which is the best algorithm to use. The default
c       is "any".
c@ clip
c       This sets the relative clip level in Steer mode. Values are
c       typically 0.75 to 0.9. The default is image dependent.
c
c$Id: clean.for,v 1.17 2019/02/09 06:59:27 wie017 Exp $
c--
c
c  History:
c    rjs   Nov89 - Original version.
c    rjs  9jun89 - Call sequences to GETPLANE and PUTPLANE has changed.
c                  Subroutine DIFF included in this file.  Headers
c                  improved.
c    rjs 13mar90 - Copy across linetype parameters from input to output
c                  file.  Added version thingo.
c    rjs 12mar90 - Fixed bug which caused the old history to be
c                  overwritten.
c    rjs 30apr90 - Changed call sequence to BoxInput.
c   mchw 11jul90 - Added header keywords and increased length of
c                  filenames.
c   mchw 09nov90 - Added pbfwhm to map header.
c   mjs  25feb91 - Changed references of itoa to itoaf, mitoa to mitoaf.
c   rjs  20mar91 - Trivial change to tolerate multi-plane beams (for
c                  mfs).  Rearranged declarations and data statement, in
c                  header, to standard order.  Renamed "index" to "indx"
c                  in GetComp to appease flint.
c   rjs   8apr91 - Use Mem routines. Handle images with naxis4=1 better.
c                  Some cosmetic changes.
c   nebk 12oct91 - Fix indexing bug in subroutine NewEst affecting
c                  non-rectangular clean windows and add a message about
c                  switching to Steer mode.
c   rjs  17mar92 - Give better error message when sidelobes are larger
c                  than the beams central peak.
c   rjs  17may92 - Message changes.
c   nebk 27may92 - More message changes.
c   rjs  15jun92 - Doc changes.
c   rjs  17jun92 - Message giving flux of the model.
c   nebk 25nov92 - Copy btype to model from input
c   mjs  17feb93 - minor doc mod only (RESTORE -> RESTOR).
c   rjs  26feb93 - add positive option, and get negstop parameter via
c                  an option.
c   rjs  31jan95 - Copy across mosaic table. Eliminate scratch common.
c   rjs  14feb95 - Changes to the area of the way "model" is handled.
c   rjs   2jun95 - Fix spurious warning message resulting from the above
c                  change.
c   rjs  12oct95 - Tidy up above changes.
c   rjs  27nov95 - Increase max complexity of clean region.
c   rjs  05aug96 - Better check for psf not 1.
c   rjs  29jan97 - Better default region.
c   rjs  10mar97 - Default region is all channels.
c   rjs  25mar97 - Checks when plane is constant and when a plane is not
c                  selected.
c   rjs  24jun97 - Correct call to Alignini.
c   rjs  02jul97 - cellscal change.
c   rjs  23jul97 - added pbtype.
c   rjs  22oct99 - doc change only.
c   rjs  28aug00 - Increase max complexity of region-of-interest.
c   dpr  06mar01 - Doc change only.
c   gmx  07mar04 - Changed optimum gain determination to handle
c                   negative components
c   mhw  27oct11 - Use ptrdiff type for memory allocations
c   mhw  08aug18 - Add deep clean, second niter parameter
c
c  Important Constants:
c    MaxDim     The max linear dimension of an input (or output) image.
c
c  Runs:
c    Run(3,nrun) We may want to clean several boxes (which may overlap).
c               Run is an 3 x N array, with each entry being of the
c               form:
c                 j, imin, imax
c               This gives a range of i in line j to process.  There
c               could be several entries for a given line, describing
c               disconnected ranges of i to process (there is no overlap
c               between runs).  Specifying boxes in this way is
c               reasonably concise for the programmer, and yet makes
c               vectorisable code straightforward to write.
c-----------------------------------------------------------------------
      include 'maxdim.h'
      integer MAXBEAM,MAXCMP1,MAXCMP2,MAXBOX,MAXRUN,MAXP
      parameter (MAXCMP1 = 66000, MAXCMP2 = 32000, MAXP = 257,
     *           MAXBEAM = MAXP*MAXP, MAXBOX = 3*MAXDIM,
     *           MAXRUN = 3*MAXDIM)

      real Data(MaxBuf)
      integer Boxes(MAXBOX),Run(3,MAXRUN)
      ptrdiff pBem,pMap,pEst,pRes,nPoint,MaxMap
      real RCmp(MAXCMP2),CCmp(MAXCMP2)
      real Histo(MAXP/2+1),BemPatch(MAXBEAM)
      integer ICmp(MAXCMP1),JCmp(MAXCMP1)

      character Mode*8,Moded*8,Text*7,flags*8,version*72
      real Cutoff,Gain,Phat,Speed,Clip,defClip,Limit,Cut(2)
      logical NegStop,Positive,Pad,Asym,NegFound,More,FFTIni,steermsg
      logical deep
      integer MaxNiter(2),oNiter,Niter,totNiter,minPatch,maxPatch
      integer naxis,n1,n2,icentre,jcentre,nx,ny,curMaxNiter
      integer blc(3),trc(3),xmin,xmax,ymin,ymax
      integer k,nRun,xoff,yoff,zoff,nCmp
      character MapNam*256,BeamNam*256,ModelNam*256,OutNam*256,line*72
      integer lMap,lBeam,lModel,lOut
      integer nMap(3),nBeam(3),nModel(3),nOut(4)
      real EstASum,Flux
      real ResMin,ResMax,ResAMax,ResRms

      common Data

c     Externals.
      character itoaf*8, versan*72
c-----------------------------------------------------------------------
      version = versan ('clean',
     *                  '$Revision: 1.17 $',
     *                  '$Date: 2019/02/09 06:59:27 $')
c
c  Get the input parameters.
c
      call inputs(MapNam,BeamNam,ModelNam,OutNam,MaxNiter,NegStop,
     *  positive,pad,asym,Cut,Boxes,MAXBOX,MinPatch,Gain,PHat,
     *  Speed,Clip,mode)
      deep = .false.
c
c  Open the beam, get some characteristics about it, then read in the
c  beam patch. The beam patch is not required if we are performing Steer
c  iterations only. However, some of the statistics returned by BeamChar
c  are required.
c
      call xyopen(lBeam,BeamNam,'old',3,nBeam)
      n1 = nBeam(1)
      n2 = nBeam(2)
      if (nBeam(3).ne.1) call bug('w',
     *  'Beam contains more than one plane')
      FFTIni = .false.
c
c  Fiddle the min and max patch sizes.
c
      maxPatch = min(MAXP,2*((min(n1,n2)-1)/2) + 1)
      if (maxPatch.le.0) call bug('f','Bad patch size')
      call BeamChar(lBeam,n1,n2,icentre,jcentre,Histo,maxPatch)
      maxPatch = min(maxPatch,
     *            2*min(icentre-1,n1-icentre,jcentre-1,n2-jcentre)+1)
      if (minPatch.gt.maxPatch) then
        call bug('w','Setting min patch size to '//itoaf(maxPatch))
        minPatch = maxPatch
      endif

      if (mode.eq.'steer' .or. mode.eq.'any') then
        defClip = 0.2*Histo(1) + 0.8*Histo(2)
        if (Clip.eq.0) then
          Clip = defClip
        else if (Clip.lt.defClip) then
          call bug('w','Clip level seems small')
        endif
      endif
      if (mode.ne.'steer')
     *    call GetPatch(lBeam,BemPatch,maxPatch,PHat,icentre,jcentre)
c
c  Open the map, and determine the area being cleaned.
c
      call xyopen(lMap,MapNam,'old',3,nMap)
      call rdhdi(lMap,'naxis',naxis,3)
      naxis = min(naxis,4)
      call defregio(boxes,nMap,nBeam,icentre,jcentre)
      call BoxMask(lMap,boxes,MAXBOX)
      call BoxSet(boxes,3,nMap,' ')
      call BoxInfo(boxes,3,blc,trc)
      nOut(1) = trc(1) - blc(1) + 1
      nOut(2) = trc(2) - blc(2) + 1
      nOut(3) = trc(3) - blc(3) + 1
      nOut(4) = 1
      if (nOut(1).gt.n1 .or. nOut(2).gt.n2)
     *  call bug('f','Region of map to deconvolve is too big')
      if (2*nOut(1)-1.gt.n1 .or. 2*nOut(2)-1.gt.n2)
     *  call bug('w','Size of region of map to deconvolve is unsafe')
c
c  Allocate space for the Map,Estimate and Residuals.
c
      MaxMap = nOut(1)*nOut(2)
      call MemAllox(pMap,MaxMap,'r')
      call MemAllox(pEst,MaxMap,'r')
      call MemAllox(pRes,MaxMap,'r')
c
c  Open the model if there is one.  Note that currently the model
c  must agree exactly in size with the output map (an unfortunate
c  restriction).
c
      if (ModelNam.ne.' ') then
        call xyopen(lModel,ModelNam,'old',3,nModel)
        call rdhdi(lModel,'niters',totNiter,0)
        call AlignIni(lModel,lMap,nMap(1),nMap(2),nMap(3),
     *                                      xoff,yoff,zoff)
      else
        totNiter = 0
      endif
      steermsg = .true.
c
c  Open the output.
c
      call xyopen(lOut,OutNam,'new',naxis,nOut)
c
c  Loop over all the planes of interest.
c
      do k = blc(3), trc(3)
        if (blc(3).ne.trc(3)) call output('Plane: '//itoaf(k))
c
c  Get the Map, Estimate and Residual.
c
        call BoxRuns(1,k,'r',boxes,Run,MAXRUN,nRun,
     *                                xmin,xmax,ymin,ymax)
        nx = xmax - xmin + 1
        ny = ymax - ymin + 1

        call xysetpl(lMap,1,k)
        call GetPlane(lMap,Run,nRun,xmin-1,ymin-1,nMap(1),nMap(2),
     *                        Data(pMap),MaxMap,nPoint)
c
c  Determine the CLEAN algorithm that is to be used.
c
        if (nPoint.gt.0) then
          moded = mode
          if ((mode.eq.'any' .or. mode.eq.'hogbom') .and.
     *      nPoint.le.MAXCMP1 .and.
     *      (2*nx-1).le.maxPatch .and. (2*ny-1).le.maxPatch) then
            moded = 'hogbom'
          else if (mode.eq.'hogbom') then
            call bug('w','Cannot use Hogbom algorithm -- using Clark')
            moded = 'clark'
          else
            moded = mode
          endif
c
c  Initialise the FFT of the beam if needed.
c
          if ((moded.ne.'hogbom' .or. ModelNam.ne.' ')
     *                                .and. .not.FFTIni) then
            FFTIni = .true.
            flags = 'p'
            if (.not.asym) flags(2:2) = 's'
            if (pad)       flags(3:3) = 'e'
            call CnvlIniF(pBem,lBeam,n1,n2,icentre,jcentre,PHat,flags)
          endif
c
c  Initialise the estimate, and determine the residuals if the the user
c  gave an estimate. Determine statistics about the estimate and the
c  residuals.
c
          if (ModelNam.eq.' ') then
            EstASum = 0
            call NoModel(Data(pMap),Data(pEst),Data(pRes),nPoint)
          else
            call output('Subtracting initial model ...')
            call AlignGet(lModel,Run,nRun,k,xmin+xoff-1,ymin+yoff-1,
     *        zoff,nModel(1),nModel(2),nModel(3),
     *        Data(pEst),MaxMap,nPoint)
            call Diff(pBem,Data(pEst),Data(pMap),Data(pRes),
     *        nPoint,nx,ny,Run,nRun)
            call SumAbs(EstASum,Data(pEst),nPoint)
          endif
          call Stats(Data(pRes),nPoint,ResMin,ResMax,ResAMax,ResRms,
     *      deep, Data(pEst))
          call output('Begin iterating')
        else
          ResMin = 0
          ResMax = 1
        endif
c
c  Perform the appropriate iteration until no more.
c
        deep = .false.
        Niter = 0
        oNiter = 0
        negFound = .false.
        More = nPoint.gt.0 .and. ResMin.ne.ResMax
        Limit = 0
        Cutoff = Cut(1)
        do while (More)
          oNiter = Niter
          curMaxNiter = min(Niter+MaxNiter(2), MaxNiter(1))
c
c  Give some information about steer mode clip level.
c
          if (steermsg .and. moded.eq.'steer') then
            write(line,'(a,f6.3)')'Steer Clip Level:',Clip
            call output(line)
            if (negstop) call bug('w',
     *        'Options = negstop ignored in Steer mode')
            if (positive) call bug('w',
     *        'Options = positive ignored in Steer mode')
            steermsg = .false.
          endif
          if (moded.eq.'hogbom') then
            nCmp = nPoint
            call Hogbom(MaxPatch,BemPatch,nx,ny,Data(pRes),Data(pEst),
     *        ICmp,JCmp,nCmp,Run,nRun,EstASum,
     *        Cutoff,Gain,negStop,positive,negFound,deep,
     *        curMaxNiter,Niter)
            text = ' Hogbom'
          else if (moded.eq.'steer') then
            call Steer(pBem,Data(pRes),Data(pEst),Data(pMap),
     *        nPoint,nx,ny,Clip*ResAMax,Gain,deep,Niter,Run,nRun)
            text = ' Steer'
          else
            call Clark(nx,ny,Data(pRes),Data(pEst),nPoint,Run,nRun,
     *        Histo,BemPatch,minPatch,maxPatch,Cutoff,negStop,
     *        positive,curMaxNiter,Gain,Speed,ResAMax,EstASum,Niter,
     *        Limit,deep,negFound,RCmp,CCmp,ICmp,JCmp,MAXCMP2)
            if (Niter.gt.oNiter) call Diff(pBem,Data(pEst),
     *        Data(pMap),Data(pRes),nPoint,nx,ny,Run,nRun)
            text = ' Clark'
            if (moded.eq.'any' .and. Limit/ResAMax.gt.Clip)
     *                                                moded = 'steer'
          endif
c
c  Output some messages to assure the user that the computer has not
c  crashed.
c
          call output(Text//' Iterations: '//itoaf(Niter))
          call Stats(Data(pRes),nPoint,ResMin,ResMax,ResAMax,ResRms,
     *      deep,Data(pEst))
          write(line,'(a,1p3e12.3)')' Residual min,max,rms: ',
     *                              ResMin,ResMax,ResRms
          call output(line)
          call SumFlux(Flux,Data(pEst),nPoint)
          write(line,'(a,1pe12.3)')' Total CLEANed flux: ',Flux
          call output(line)
c
c  If we are doing Steer iterations, see if the next iteration would run
c  into negative components.
c
          if (moded.eq.'steer')
     *      negFound = negFound .or. (-Clip*ResAMax.gt.ResMin)
c
c  Check for convergence.
c
          more = .not.((negFound .and. negStop) .or. (Niter.eq.oNiter)
     *           .or. (ResAMax.le.Cutoff) .or. (Niter.ge.MaxNiter(1)))
c
c  Check if we want to go into the deep cleaning phase
c
         if (.not.more.and..not.deep) then
           if (Cut(2).gt.0.and.Cut(2).lt.Cut(1).and.
     *         .not.((negFound.and.negStop).or.
     *         (Niter.ge.MaxNiter(1)))) then
              deep=.true.
              Cutoff=Cut(2)
              more=ResAMax.gt.Cutoff
              if (more) call output(' Starting deep cleaning phase')
           endif
         endif
       enddo
c
c  Give a message about what terminated the iterations.
c
        if (ResMin.eq.ResMax) then
          call bug('w','All pixels for this plane are identical')
          call bug('w','No cleaning performed')
          nPoint = 0
        else if (nPoint.eq.0) then
          call output('No region selected in this plane')
        else if (ResAMax.le.Cutoff) then
          call output(' Stopping -- Clean cutoff limit reached')
        else if (Niter.ge.MaxNiter(1)) then
          call output(' Stopping -- Maximum iterations performed')
        else if (NegStop .and. NegFound) then
          call output(' Stopping -- Negative components encountered')
        else if (oNiter.eq.Niter) then
          call output(' Stopping -- Could not find more components')
        endif
c
c  Write out this plane.
c
        totniter = totniter + Niter
        call xysetpl(lOut,1,k-blc(3)+1)
        call PutPlane(lOut,Run,nRun,xmin-blc(1),ymin-blc(2),
     *                        nOut(1),nOut(2),Data(pEst),nPoint)
      enddo
c
c  Construct a header for the output file, and give some history
c  information.
c
      call Header(lMap,lOut,blc,trc,totNiter,minpatch,clip,mode,
     *                                                version)
c
c  Close up the files. Ready to go home.
c
      call xyclose(lMap)
      call xyclose(lBeam)
      if (ModelNam.ne.' ') call xyclose(lModel)
      call xyclose(lOut)
c
c  Thats all folks.
c
      end

c***********************************************************************

      subroutine Stats(Data,n,Dmin,Dmax,DAmax,Drms,deep,Est)

      ptrdiff n
      real Data(n),Est(n)
      real Dmin,Dmax,DAmax,Drms
      logical deep
c-----------------------------------------------------------------------
c  Calculate every conceivably wanted statistic.
c
c  Input:
c    n          Number of points.
c    Data       Input data array.
c    deep       True if in deep cleaning mode
c    Est        Current estimate of sky model
c
c  Output:
c    Dmin       Data minima.
c    Dmax       Data maxima.
c    DAmax      Data absolute maxima.
c    Drms       Rms value of the data.
c-----------------------------------------------------------------------
      ptrdiff i,k

c     Externals.
      ptrdiff ismax8,ismin8
c-----------------------------------------------------------------------
c
c  Calculate the minima and maxima.
c
      if (.not.deep) then
        i = ismax8(n,Data,1)
        Dmax = Data(i)
        i = ismin8(n,Data,1)
        Dmin = Data(i)
c
c  Calculate the sums.
c
        Drms = 0
        do i = 1, n
          Drms = Drms + Data(i)*Data(i)
        enddo
        Drms = sqrt(Drms/n)
      else
        k=0
        Drms=0
        Dmax=-1e10
        Dmin=1e10
        do i = 1, n
          if (Est(i).ne.0) then
            Dmax = max(Dmax, Data(i))
            Dmin = min(Dmin, Data(i))
            Drms = Drms + Data(i)*Data(i)
            k=k+1
          endif
        enddo
        if (k.gt.0) Drms=sqrt(Drms/k)
      endif
      DAmax = max(abs(Dmax),abs(Dmin))
      end

c***********************************************************************

      subroutine GetPatch(lBeam,Patch,maxPatch,PHat,ic,jc)

      integer lBeam,maxPatch,ic,jc
      real Patch(maxPatch,maxPatch),PHat
c-----------------------------------------------------------------------
c  Read in the central portion of the beam.
c
c  Inputs:
c    lBeam      Handle of the file containing the beam.
c    maxPatch   The full width of the patch to be read in.
c    ic,jc      Location of the centre pixel of the beam.
c    PHat       Prussian hat.
c
c  Output:
c    Patch      The read in central portion of the beam.
c-----------------------------------------------------------------------
      include 'maxdim.h'
      integer imin,imax,jmin,jmax,i,j
      real Data(MAXDIM)
c-----------------------------------------------------------------------
      imin = ic - maxPatch/2
      imax = imin + maxPatch - 1
      jmin = jc - maxPatch/2
      jmax = jmin + maxPatch - 1

      do j = jmin, jmax
        call xyread(lBeam,j,Data)
        do i = imin, imax
          Patch(i-imin+1,j-jmin+1) = Data(i)
        enddo
      enddo

      Patch(ic-imin+1,jc-jmin+1) = Patch(ic-imin+1,jc-jmin+1) + PHat

      end

c***********************************************************************

      subroutine inputs(map,beam,estimate,out,Niter,negStop,positive,
     *  pad,asym,cutoff,box,maxbox,minpatch,gain,phat,speed,clip,mode)

      integer Niter(2), minpatch, maxbox
      integer box(maxbox)
      real cutoff(2),gain,phat,speed,clip
      logical negStop,positive,pad,asym
      character map*(*),beam*(*),estimate*(*),out*(*),mode*(*)
c-----------------------------------------------------------------------
c       Get user supplied inputs
c
c    Input:
c      maxbox      The maximum number of boxes.
c    Output:
c      Map         Name of the input map. No default.
c      Beam        Name of the input beam. No default.
c      Estimate    Name of the input estimate of the deconvolved image.
c                  Default is a estimate which is zero.
c      Out         Name of the output deconvolved map. No default.
c      Gain        Clean loop gain.  Default 0.5 (a bit high).
c      Cutoff      The iterations stop when either the absolute max
c                  residual remaining is less than Cutoff, or Niter
c      Niter       minor iterations have been performed (whichever comes
c                  first).  The default Cutoff is 0 (i.e. iterate
c                  forever), and the default number of minor iterations
c                  is 250.  This is the total number of iterations to
c                  do.
c      negStop     Stop on first negative component.
c      positive    Constrain the output components to be positive
c                  valued.
c      pad         Zero pad the beam to a bigger size.
c      asym        The beam is asymmetric.
c      minpatch    The minimum beam patch width.
c      phat        Prussian hat. Default is 0.
c      speed       Speedup factor. Default is 0.
c      box         The boxes specification.
c      clip        The Steer clip level.
c      mode        Either "clark" (default), "steer" or "any".
c-----------------------------------------------------------------------
      include 'maxdim.h'
c-----------------------------------------------------------------------
      call keyini
      call keya('map', map, ' ')
      call keya('beam', beam, ' ')
      call keya('model', estimate,' ')
      call keya('out', out, ' ')
      if (map.eq.' ' .or. beam.eq.' ' .or. out.eq.' ')
     *  call bug('f', 'A file name was missing from the parameters')
      call GetOpt(negstop,positive,pad,asym)
      call keyi('niters', Niter(1), 250)
      call keyi('niters', Niter(2), 1000)
      if (Niter(1).le.0) call bug('f', 'NITERS must be positive')
      call keyr('cutoff', cutoff(1),0.0)
      call keyr('cutoff', cutoff(2),0.0)
      if (cutoff(2).gt.cutoff(1)) then
        call bug('w','Second cutoff should be less than first')
        cutoff(2)=0
      endif

      call BoxInput('region',map,box,maxbox)

      call keyi('minpatch', minpatch, 51)
      call keyr('gain', gain, 0.1)
      if (gain.le.0 .or. gain.gt.1)
     *  call bug('f','Bad gain value, it must be in the range (0,1]')
      call keyr('phat', phat, 0.0)
      call keyr('speed', speed, 0.0)
      call keyr('clip', clip, 0.0)
      if (clip.lt.0 .or. clip.gt.1)
     *  call bug('f','Bad clip value, it must be in the range [0,1]')
      call keya('mode',mode,'any')
      if (mode.ne.'clark' .and.
     *    mode.ne.'steer' .and.
     *    mode.ne.'any'   .and.
     *    mode.ne.'hogbom') call bug('f','Bad value for mode')
      call keyfin

      end

c***********************************************************************

      subroutine GetOpt(negstop,positive,pad,asym)

      logical negstop,positive,pad,asym
c-----------------------------------------------------------------------
c  Get extra processing options.
c
c  Output:
c    negstop
c    positive
c-----------------------------------------------------------------------
      integer NOPTS
      parameter (NOPTS = 4)
      character opts(NOPTS)*8
      logical present(NOPTS)
      data opts/'negstop ','positive','pad     ','asym    '/
c-----------------------------------------------------------------------
      call options('options',opts,present,NOPTS)
      negstop  = present(1)
      positive = present(2)
      pad      = present(3)
      asym     = present(4)

      end

c***********************************************************************

      subroutine Header (lIn, lOut, blc, trc, niters, minpatch, clip,
     *  mode, version)

      integer   lIn, lOut, blc(3), trc(3), niters, minpatch
      real      clip
      character mode*(*), version*(*)
c-----------------------------------------------------------------------
c Copy the header to the model.
c-----------------------------------------------------------------------
      integer   lblc, ltrc
      double precision crpix1, crpix2, crpix3
      character line*72, txtblc*32, txttrc*32

      character itoaf*8
      external  itoaf
c-----------------------------------------------------------------------
c     Copy all header keywords.
      call headcp(lIn, lOut, 0, 0, 0, 0)

c     Update keywords that have changed.
      call rdhdd(lIn,  'crpix1', crpix1, 1d0)
      call rdhdd(lIn,  'crpix2', crpix2, 1d0)
      call rdhdd(lIn,  'crpix3', crpix3, 1d0)
      crpix1 = crpix1 - blc(1) + 1d0
      crpix2 = crpix2 - blc(2) + 1d0
      crpix3 = crpix3 - blc(3) + 1d0
      call wrhdd(lOut, 'crpix1', crpix1)
      call wrhdd(lOut, 'crpix2', crpix2)
      call wrhdd(lOut, 'crpix3', crpix3)
      call wrhda(lOut, 'bunit', 'JY/PIXEL')
      call wrhdi(lOut, 'niters', niters)

c     Write crap to the history file, to attempt (ha!) to appease Neil.
      call hisopen(lOut,'append')
      line = 'CLEAN: Miriad ' // version
      call hiswrite(lOut,line)
      call hisinput(lOut,'CLEAN')

      call mitoaf(blc,3,txtblc,lblc)
      call mitoaf(trc,3,txttrc,ltrc)
      line = 'CLEAN: Bounding region is Blc = (' // txtblc(1:lblc) //
     *       '), Trc = (' // txttrc(1:ltrc) // ')'
      call hiswrite(lOut,line)

      if (mode.eq.'steer' .or. mode.eq.'any') then
        write(line,'(''CLEAN: Steer Clip Level = '',f6.3)') Clip
        call hiswrite(lOut,line)
      endif
      call hiswrite(lOut,'CLEAN: Minpatch = ' // itoaf(minpatch))
      call hiswrite(lOut,'CLEAN: Total Iterations = ' // itoaf(niters))
      call hisclose(lOut)

      end

c***********************************************************************

      subroutine BeamChar(lBeam,n1,n2,ic,jc,Histo,maxPatch)

      integer lBeam,n1,n2,ic,jc,maxPatch
      real Histo(maxPatch/2+1)
c-----------------------------------------------------------------------
c  Determine the location of the max value in the beam, and an array
c  giving the max abs value of the beam outside a particular area.
c
c  Input:
c    lBeam      Handle of the file containing the beam.
c    n1,n2      Beam size.
c    maxPatch   Maximum patch size.
c
c  Output:
c    ic,jc      Pixel coordinate of the max pixel.
c    Histo      Histo(i) is the absolute maximum outside the patch
c               with width 2*i-1 around the beam maximum.
c-----------------------------------------------------------------------
      include 'maxdim.h'
      integer i,j,k,imin,imax,jmin,jmax,nHisto
      real Data(MAXDIM),bmax

c     External.
      integer isamax,ismax
c-----------------------------------------------------------------------
c
c  Initialise.
c
      nHisto = maxPatch/2 + 1
c
c  Determine the value and location of the beam maximum. Just search
c  around the centre of the beam.
c
      bmax = 0
      jmin = max(n2/2-3,1)
      jmax = min(n2/2+3,n2)
      imin = max(n1/2-3,1)
      imax = min(n1/2+3,n1)
      do j = jmin, jmax
        call xyread(lBeam,j,Data)
        i = ismax(imax-imin+1,Data(imin),1) + imin - 1
        if (j.eq.jmin .or. Data(i).gt.bmax) then
           bmax = Data(i)
           ic = i
           jc = j
        endif
      enddo

      if (abs(bmax-1.0).gt.0.001 .and. abs(bmax-1.0).le.0.01)
     *  call bug('w','Beam peak value is not 1')
      if (abs(bmax-1.0).gt.0.01)
     *  call bug('f','Beam peak value differs from 1 by more than 1%')
c
c  Initialise the "histo" array.
c
      do k = 1, nHisto
        Histo(k) = 0
      enddo
c
c  Determine some limits.
c
      jmin = max(1, jc - (nHisto-2))
      jmax = min(n2,jc + (nHisto-2))
      imin = max(1, ic - (nHisto-2))
      imax = min(n1,ic + (nHisto-2))

      do j = 1, n2
        call xyread(lBeam,j,Data)
        if (j.lt.jmin .or. j.gt.jmax) then
          i = isamax(n1,Data,1)
          Histo(nHisto) = max(abs(Data(i)),Histo(nHisto))
        else
          if (imin.gt.1) then
            i = isamax(imin-1,Data,1)
            Histo(nHisto) = max(abs(Data(i)),Histo(nHisto))
          endif
          if (imax.lt.n1) then
            i = isamax(n1-imax,Data(imax+1),1) + imax
            Histo(nHisto) = max(abs(Data(i)),Histo(nHisto))
          endif

          do i = imin, imax
            k = max(abs(i-ic),abs(j-jc)) + 1
            Histo(k) = max(Histo(k),abs(Data(i)))
          enddo
        endif
      enddo
c
c  Now Histo(k) contains the max abs value occurring at distance k.
c  Collapse this do so that Histo(k) contains the max abs value
c  occurring at a distance greater of equal to k.
c
      do k = nHisto-1, 1, -1
        Histo(k) = max(Histo(k),Histo(k+1))
      enddo
c
c  If Histo(1) is greater than bmax, then the sidelobes are greater than
c  the CLEAN peak -- and CLEAN might as well crap out.
c
      if (Histo(1)-bmax.gt.0.001) then
        call bug('w','Beam sidelobes appear bigger than beam peak?')
        call bug('f','Try imaging a larger field of view')
      endif

      end

c***********************************************************************

      subroutine SumFlux(Flux,Estimate,nPoint)

      ptrdiff nPoint
      real Estimate(nPoint),Flux
c-----------------------------------------------------------------------
c  Find the sum of the estimate.
c
c  Input:
c    nPoint
c    Estimate
c  Output:
c    Flux
c-----------------------------------------------------------------------
      ptrdiff i
c-----------------------------------------------------------------------
      Flux = 0
      do i = 1, nPoint
        Flux = Flux + Estimate(i)
      enddo

      end

c***********************************************************************

      subroutine SumAbs(EstASum,Estimate,nPoint)

      ptrdiff nPoint
      real Estimate(nPoint),EstASum
c-----------------------------------------------------------------------
c  Find the sum of the absolute value of the estimate.
c
c  Input:
c    nPoint
c    Estimate
c  Output:
c    EstASum
c-----------------------------------------------------------------------
      ptrdiff i
c-----------------------------------------------------------------------
      EstASum = 0
      do i = 1, nPoint
        EstASum = EstASum + abs(Estimate(i))
      enddo
      end

c***********************************************************************

      subroutine NoModel(Map,Estimate,Residual,nPoint)

      ptrdiff nPoint
      real Map(nPoint),Estimate(nPoint),Residual(nPoint)
c-----------------------------------------------------------------------
c  This initialises the estimate and the residuals, for the case where
c  there is no model.
c
c  Input:
c    nPoint     Number of points.
c    Map        The original dirty map.
c  Output:
c    Residual   The residuals, which are the same as the dirty map.
c    Estimate   The estimate, which are initially zero.
c-----------------------------------------------------------------------
      ptrdiff i
c-----------------------------------------------------------------------
      do i = 1, nPoint
        Estimate(i) = 0.0
        Residual(i) = Map(i)
      enddo

      end

c***********************************************************************

      subroutine Steer(pBem,Residual,Estimate,Temp,nPoint,nx,ny,
     *        Limit,Gain,deep,Niter,Run,nrun)

      integer Niter,nrun,Run(3,nrun),nx,ny
      ptrdiff pBem, nPoint
      real Gain,Limit
      real Residual(nPoint),Temp(nPoint),Estimate(nPoint)
      logical deep
c-----------------------------------------------------------------------
c  Perform an iteration of the Steer "Clean".
c
c  Input:
c    Run        The Run specifying the area of interest.
c    nrun       The number of runs. A null run follows run number nrun.
c    limit      The limit to cut at.
c    clip       Steer clip level.
c    deep       True if in deep cleaning mode
c
c  Input/Output:
c    Niter      Number of Niter iterations.
c
c-----------------------------------------------------------------------
      real MinOptGain
      parameter (MinOptGain = 0.02)
      ptrdiff i
      real SumRE,SumEE,g
c-----------------------------------------------------------------------
c
c  Form the new Steer estimate.
c
      if (deep) then
        do i = 1, nPoint
          if (Estimate(i).ne.0.and.abs(Residual(i)).gt.Limit) then
            Temp(i) = Residual(i)
            Niter = Niter + 1
          else
            Temp(i) = 0.0
          endif
        enddo
      else
        do i = 1, nPoint
          if (abs(Residual(i)).gt.Limit) then
            Temp(i) = Residual(i)
            Niter = Niter + 1
          else
            Temp(i) = 0.0
          endif
        enddo
      endif
c  Convolve it with the dirty beam.
c
      call CnvlR(pBem,Temp,nx,ny,Run,nRun,Temp,'c')
c
c  "Temp" now contains the new estimate convolved with the dirty beam.
c  Determine the optimum gain to apply to minimise the residuals.
c  However apply the users damping factor to this gain.
c
      SumRE = 0
      SumEE = 0
      do i = 1, nPoint
        SumRE = SumRE + Residual(i)*Temp(i)
        SumEE = SumEE + Temp(i)*Temp(i)
      enddo
c
c       SumRE can be negative, so it is better to take the
c       absolute value of it when determining the optimum
c       gain (gmx - 07mar04)
c
c       abs(SumRE)/SumEE may be close to zero, in which case
c       a semi-infinite loop can be the result. We apply a
c       lower limit to abs(SumRE)/SumEE. A good value for it
c       is empirically determined to be 0.02 (MinOptGain),
c       which may however not be the best choice in all cases.
c       In case of problems, you can try a lower value for the
c       task option Gain before changing MinOptGain (gmx - 07mar04).
c
      g = Gain*max(MinOptGain,abs(SumRE)/SumEE)
c
c  Now go through and update the estimate, using this gain. Also
c  determine the new residuals.
c
      do i = 1, nPoint
        if ((.not.deep.or.Estimate(i).ne.0).and.
     *        abs(Residual(i)).gt.Limit)
     *        Estimate(i) = Estimate(i) + g * Residual(i)
        Residual(i) = Residual(i) - g * Temp(i)
      enddo

      end

c***********************************************************************

      subroutine Hogbom(n,Patch,nx,ny,RCmp,CCmp,ICmp,JCmp,nCmp,
     *  Run,nRun,EstASum,Cutoff,Gain,negStop,positive,negFound,
     *  deep, MaxNiter,Niter)

      integer nx,ny,nCmp,nRun,n
      integer ICmp(nCmp),JCmp(nCmp),Run(3,nRun)
      real RCmp(nCmp),CCmp(nCmp),Patch(n,n)
      real Cutoff,Gain,EstASum
      logical negStop,negFound,positive, deep
      integer MaxNiter,Niter
c-----------------------------------------------------------------------
c  Perform a Hogbom Clean.
c
c  Inputs:
c    Patch      The beam.
c    n          Size of the beam.
c    nx,ny      Size of the input image.
c    nCmp       Number of pixels.
c    maxNiter   Maximum number of iterations to be performed.
c    negStop    Stop when a negative component is encountered.
c    positive   Contrain the total component to be positive.
c    Gain       Loop gain.
c    Cutoff     Stop when the residuals fall below the cutoff.
c    Run(3,nRun) This specifices the runs of the input image that are to
c               be processed.
c    deep       True if in deep cleaning mode
c
c  Input/Output:
c    RCmp       Residuals.
c    CCmp       The image estimate.
c    Niter      Number of iterations to be performed.
c    EstASum    Sum of the absolute value of the estimate.
c    negFound   Set true if a negative component was encountered.
c
c  Scratch:
c    ICmp       Coordinate in x of a pixel.
c    JCmp       Coordinate in y of a pixel.
c
c
c  Internal Crap:
c    Ymap       See SubComp for an explanation.
c
c-----------------------------------------------------------------------
      include 'maxdim.h'
      integer i,j,Ncmpd,x0,y0,n0,itemp
      integer YMap(MAXDIM+1)
c-----------------------------------------------------------------------
c
c  Clear out YMap.
c
      do j = 1, ny+1
        YMap(j) = 0
      enddo
c
c  Fill in the array giving the coordinates of the residuals, and
c  accumulate the number of residuals in each row into YMap.
c
      Ncmpd = 0
      do j = 1, nRun
        y0 = Run(1,j)
        x0 = Run(2,j)-1
        n0 = Run(3,j) - x0
        do i = 1, n0
          Ncmpd = Ncmpd + 1
          Icmp(Ncmpd) = x0 + i
          Jcmp(Ncmpd) = y0
        enddo
        Ymap(y0) = Ymap(y0) + n0
      enddo
      if (Ncmpd.ne.Ncmp) call bug('f','Internal bug in Hogbom - 1')
c
c  YMap currently contains the number of residuals found in a particular
c  row.  Convert this so that YMap(j) gives the total number of peak
c  residuals in rows 1 to j-1.
c
      Ncmpd = 0
      do j = 1, ny+1
        itemp = Ncmpd
        Ncmpd = Ncmpd + Ymap(j)
        YMap(j) = itemp
      enddo
      if (Ncmpd.ne.Ncmp) call bug('f','Internal bug in Hogbom - 2')
c
c  Ready to perform the subtraction step. Lets go.
c
      call SubComp(nx,ny,Ymap,Patch,n,n/2,Gain,MaxNiter,NegStop,
     *  positive,0.0,0.0,Cutoff,EstASum,Icmp,Jcmp,Rcmp,Ccmp,Ncmp,Niter,
     *  deep,negFound)
      end

c***********************************************************************

      subroutine Clark(nx,ny,Residual,Estimate,nPoint,Run,nRun,
     *        Histo,Patch,minPatch,maxPatch,Cutoff,negStop,positive,
     *        MaxNiter,Gain,Speed,ResAMax,EstASum,Niter,Limit,
     *        deep,negFound,RCmp,CCmp,ICmp,JCmp,maxCmp)

      integer nx,ny,minPatch,maxPatch,maxNiter,Niter,nRun
      ptrdiff nPoint
      integer Run(3,nrun)
      real Residual(nPoint),Estimate(nPoint)
      logical negStop,positive,negFound,deep
      real Cutoff,Gain,Speed,Limit,ResAMax,EstASum
      real Histo(maxPatch/2+1),Patch(maxPatch,maxPatch)
      integer maxCmp,ICmp(maxCmp),JCmp(maxCmp)
      real CCmp(maxCmp),RCmp(maxCmp)
c-----------------------------------------------------------------------
c  Perform the component gathering step of a major Clark Clean
c  iteration.  Determine the limiting residual, and store the components
c  greater than in the residual list. Perform the subtraction portion of
c  a minor iteration, by Cleaning this list. Then add the newly found
c  components to the estimate.
c
c  Inputs:
c    nx,ny      Image size.
c    Residual   The residuals.
c    Estimate   The estimate.
c    nPoint     The number of points in the residual and estimate.
c    Histo
c    Patch      The beam patch.
c    minPatch)  The min and max sizes that the beam patch can take.
c    maxPatch)
c    maxNiter   The maximum total number of minor iterations permitted.
c    negStop    Stop iterating on the first negative component.
c    Cutoff
c    Gain       Loop gain.
c    Speed      Clean speed-up factor.
c    Run        The Run, defining the area to be cleaned.
c    nrun       The number of runs.
c    ResAMax    Absolute maximum of the residuals.
c    EstASum    Absolute sum of the estimates.
c    deep       True if in deep cleaning mode
c
c  Input/Output:
c    Niter      The actual number of minor iterations performed.
c               Updated.
c    negFound   True if a negative component was found (if negStop is
c               true, then this will stop before the negative component
c               is added to the component list).
c
c  Output:
c    Limit      Max residual that went into the residual list.
c
c  Important or Odd Thingos:
c    Ymap       When cleaning the table of residuals, we need to
c               determine where residuals corresponding to a given range
c               of j exist.  Ymap(j) gives the index of the table entry
c               before that contains, or would have contained, line j
c               residuals.
c-----------------------------------------------------------------------
      include 'maxdim.h'
      integer Ymap(MAXDIM+1)
      integer nPatch,nCmp
c-----------------------------------------------------------------------
c
c  Find the limiting residual that we can fit into the residual list,
c  then go and fill the residual and component list.
c
      call GetLimit(Residual,deep,Estimate,nPoint,ResAMax,maxCmp,
     *              Histo,MaxPatch,nPatch,Limit)
      Limit = max(Limit, 0.5 * Cutoff)
      call GetComp(Residual,Estimate,nPoint,ny,Ymap,Limit,deep,
     *        Icmp,Jcmp,Rcmp,CCmp,maxCmp,nCmp,Run,nRun)
c
c  Determine the patch size to use, perform the minor iterations, then
c  add the new components to the new estimate.
c
      nPatch = max(MinPatch/2,nPatch)
      call SubComp(nx,ny,Ymap,Patch,MaxPatch,nPatch,Gain,MaxNiter,
     *      negStop,positive,1.0,Speed,Limit,EstASum,
     *      ICmp,JCmp,RCmp,CCmp,nCmp,Niter,deep,negFound)

      call NewEst(CCmp,ICmp,JCmp,nCmp,Estimate,nPoint,Run,nRun)
      end

c***********************************************************************

      subroutine SubComp(nx,ny,Ymap,Patch,n,PWidth,Gain,MaxNiter,
     *        NegStop,positive,g,Speed,Limit,EstASum,Icmp,Jcmp,Rcmp,
     *        Ccmp,Ncmp,Niter,deep,negFound)

      integer nx,ny,n,Ncmp,Niter,MaxNiter,PWidth
      real Limit,Gain,g,Speed,EstASum
      integer Icmp(Ncmp),Jcmp(Ncmp),Ymap(ny+1)
      real Patch(n,n),Rcmp(Ncmp),Ccmp(Ncmp)
      logical negStop, positive, negFound, deep
c-----------------------------------------------------------------------
c  Perform minor iterations. This quits performing minor iterations when
c
c   ResMax < Limit * (1+ sum(|component|/(EstAMax+sum(|component|)))
c
c  This is different to that suggested by Clark, but has the advantage
c  that it does not depend on iteration number.
c
c  Inputs:
c    Icmp,Jcmp  Coordinates of each residual peak.
c    Ncmp       Number of residual peaks.
c    Gain       Loop gain.
c    Speed      Speed up factor.  A factor of zero reverts to a Clark
c               Clean.
c    g          Yet another parameter to control the end of the minor
c               cycles.
c    negStop    Stop on the first negative peak.
c    positive   Contrain the components to be positive.
c    Limit      All residuals above LIMIT are included in the residual
c               peaks.
c    MaxNiter   Maximum number of minor iterations to be performed.
c    Patch      Beam patch.
c    n          Dimension of beam patch.  This is an odd number.  The
c               patch is square. The peak is at n/2+1
c    PWidth     Patch half width to be used.
c    ny         Number of rows in the residuals.
c    Ymap       When cleaning the table of residuals, we need to
c               determine where residuals corresponding to a given range
c               of j exist.  Ymap(j) gives the index of the table entry
c               before that contains, or would have contained, line j
c               residuals
c     deep      True if in deep cleaning phase
c
c  Input/Outputs:
c    Rcmp       Flux at each residual peak.
c    CCmp
c    Niter      Number of minor iterations completed.
c    EstASum    Absolute sum of the current model.
c
c  Outputs:
c    negFound   True if a negative component was found.
c    zerocmp    True if the iterating was stopped by a zero component.
c-----------------------------------------------------------------------
      integer MAXRUN
      parameter (MAXRUN = 4096)
      integer i,i0,j0,k,ktot,ltot,NIndx
      integer Pk,p,ipk,jpk,ipkd,jpkd
      real TermRes,ResMax,Wts,alpha
      integer Temp(MAXRUN),Indx(MAXRUN)
      logical more,ZeroCmp
c-----------------------------------------------------------------------
c
c  Initialise.
c
      call GetPk(Ncmp,Rcmp,Ccmp,Gain,positive,Pk,Wts,deep)
      ResMax = Rcmp(Pk)
      negFound = negFound .or. ResMax.lt.0
      TermRes = Limit
      alpha = g * Limit**(Speed+1)
      ZeroCmp = Wts.eq.0
c
c  Loop until no more. Start with some house keeping.
c
      more = abs(ResMax).gt.TermRes .and. Niter.lt.MaxNiter .and.
     *        .not.(negStop .and. negFound) .and. .not.ZeroCmp
      do while (more)
c
c  Add the peaks to be subtracted into the components list, and
c  do some added house keeping.
c
        EstASum = EstASum - abs(CCmp(pk))
        Ccmp(Pk) = Ccmp(Pk) + Wts
        EstASum = EstASum + abs(CCmp(pk))
        ipk = Icmp(Pk)
        jpk = Jcmp(Pk)
        ipkd = ipk - (n/2 + 1)
        jpkd = jpk - (n/2 + 1)
c
c  Find the residuals which have suitable y values.
c
        i = max(1, jpk-PWidth)
        k = Ymap(i)
        i = min(ny,jpk+PWidth)
        ktot = Ymap(i+1)
c
c  Find the residuals which have suitable x values, then subtract.  If
c  the beam does not cover the extent of the subimage, we have to go
c  through the process of determining which pixels are covered.  This
c  is done in a clunchy vectorised fashion.
c
        if (max(nx-ipk,ipk-1).gt.PWidth) then
          do while (k.lt.ktot)
            ltot = min(ktot-k,MAXRUN)
            do i = k+1, k+ltot
              Temp(i-k) = abs(Icmp(i)-ipk)
            enddo

            call whenile(ltot,Temp,1,PWidth,Indx,Nindx)
c#ivdep
            do i = 1, Nindx
              p = k + Indx(i)
              i0 = Icmp(p) - ipkd
              j0 = Jcmp(p) - jpkd
              Rcmp(p) = Rcmp(p) - Wts * Patch(i0,j0)
            enddo
            k = k + ltot
          enddo

        else
          do i = k+1, ktot
            RCmp(i) = RCmp(i) - Wts * Patch(ICmp(i)-ipkd,JCmp(i)-jpkd)
          enddo
        endif
c
c  Ready for the next loop.
c
        Niter = Niter + 1
        TermRes = TermRes +
     *   alpha * abs(Wts) / (EstASum * abs(ResMax)**Speed)
        call GetPk(Ncmp,Rcmp,Ccmp,Gain,positive,Pk,Wts,deep)
        ResMax = Rcmp(Pk)
        negFound = negFound .or. ResMax.lt.0
        zeroCmp = Wts.eq.0
        more = abs(ResMax).gt.TermRes .and. Niter.lt.MaxNiter .and.
     *        .not.(negStop .and. negFound) .and. .not.zeroCmp
      enddo
      end

c***********************************************************************

      subroutine GetPk(Ncmp,Rcmp,Ccmp,Gain,positive,Pk,Wts,deep)

      integer Ncmp,Pk
      real Rcmp(Ncmp),Ccmp(Ncmp),Gain,Wts
      logical positive,deep
c-----------------------------------------------------------------------
c  Determine the position and value of the next delta.
c
c  Input:
c    Ncmp       Number of residuals/components.
c    Rcmp       The residuals.
c    Ccmp       The current components.
c    Gain       The loop gain.
c    positive   True if the components must always be positive.
c    deep       true if in deep cleaning phase
c  Output:
c    Pk         The index of the delta.
c    Wts        Value of the delta.
c-----------------------------------------------------------------------
      integer i
      real temp,maxv

c     Externals.
      integer isamax
c-----------------------------------------------------------------------
      if (positive) then
        Pk = 1
        maxv = 0
        do i = 1, Ncmp
          if (.not.deep.or.Ccmp(i).ne.0) then
            temp = abs(max(Gain*Rcmp(i),-Ccmp(i)))
            if (temp.gt.maxv) then
              maxv = temp
              Pk = i
            endif
          endif
        enddo
        Wts = max(Gain*Rcmp(Pk),-Ccmp(Pk))
      else
        if (.not.deep) then
            Pk = isamax(Ncmp,Rcmp,1)
        else
          Pk = 1
          maxv = 0
          do i = 1, Ncmp
            if (Ccmp(i).ne.0) then
              temp = abs(Rcmp(i))
              if (temp.gt.maxv) then
                maxv = temp
                Pk = i
              endif
            endif
          enddo
        endif
        Wts = Gain * Rcmp(Pk)
      endif

      end

c***********************************************************************

      subroutine GetLimit(Residual,deep,Estimate,nPoint,ResAMax,maxCmp,
     *        Histo,MaxPatch,nPatch,Limit)

      ptrdiff nPoint
      integer maxPatch,nPatch,maxCmp
      real Residual(nPoint),Estimate(nPoint)
      real ResAMax,Histo(maxPatch/2+1),Limit
      logical deep
c-----------------------------------------------------------------------
c  Determine the limiting threshold and the patch size. The algorithm
c  used to determine the Limit and patch size are probably very
c  important to the run time of the program. Presently, however, the
c  algorithm is fairly simple.
c
c  Inputs:
c    Residual   The input residuals.
c    nPoint     Number of residuals.
c    Estimate   The current Estimate
c    ResAMax    The absolute maximum residual.
c    maxCmp     The maximum number of peak residuals that can be stored.
c    Histo      Histogram of the beam patch.
c    maxPatch   Width of beam patch.
c
c  Outputs:
c    Limit      Threshold above which residual points are to be chosen.
c    nPatch     Half width of beam patch.
c-----------------------------------------------------------------------
      integer HistSize
      parameter (HistSize = 512)
      ptrdiff i
      integer m,Acc
      real ResAMin,a,b,x
      integer ResHis(HistSize)
c-----------------------------------------------------------------------
c
c  Initialise the histogram array, as well as other stuff.
c
      ResAMin = ResAMax * Histo(maxPatch/2+1)
      if (ResAmin.eq.ResAmax)
     *  call bug('f','All pixel values are identical')
      a = (HistSize-2)/(ResAMax-ResAMin)
      b = 2 - a * ResAMin
      do i = 1, HistSize
        ResHis(i) = 0
      enddo
c
c  Now get the histogram while taking account of the boxes.
c
      if (.not.deep) then
        do i = 1, nPoint
          m = max(int(a * abs(Residual(i)) + b),1)
          ResHis(m) = ResHis(m) + 1
        enddo
      else
        do i = 1, nPoint
          if (Estimate(i).ne.0) then
            m = max(int(a * abs(Residual(i)) + b),1)
            ResHis(m) = ResHis(m) + 1
          endif
        enddo
      endif
c
c  Now work out where to set the limit.
c
      Acc = 0
      m = HistSize + 1
      do while (Acc.le.maxCmp)
        m = m - 1
        if (m.eq.0) then
          Acc = maxCmp + 1
        else
          Acc = Acc + ResHis(m)
        endif
      enddo
      m = m + 1
      Limit = (m-b)/a
c
c  Now work out what the corresponding beam patch size is.
c
      nPatch = 1
      x = Limit / ResAMax
      do while (nPatch.lt.maxPatch/2 .and. x.lt.Histo(nPatch))
        nPatch = nPatch + 1
      enddo

      end

c***********************************************************************

      subroutine GetComp(Residual,Estimate,nPoint,ny,Ymap,Limit,
     *                   deep,Icmp,Jcmp,RCmp,CCmp,maxCmp,nCmp,Run,nRun)

      ptrdiff nPoint
      integer ny,maxCmp,nCmp,nRun,Run(3,nrun)
      real Limit,Residual(nPoint),Estimate(nPoint)
      real RCmp(maxCmp),CCmp(maxCmp)
      integer Ymap(ny+1),Icmp(maxCmp),Jcmp(maxCmp)
      logical deep
c-----------------------------------------------------------------------
c  Get the residuals that are greater than a certain cutoff.
c
c  Inputs:
c    nx,ny      Size of the residual map.
c    maxCmp     Max number of components that are possible.
c    Limit      Threshold above which components are to be taken.
c    Run        Runs specifications.
c    nrun       Number of runs.
c    Residual   Contains all the residuals.
c    Estimate   Contains all the estimated pixel fluxes.
c    deep       True if in deep cleaning mode
c
c  Outputs:
c    Ncmp       Number of residual peaks returned.
c    Ymap       Ymap(j) gives the index, in Icmp,Jcmp,Residual of the
c               last residual peak such that Jcmp.lt.j. See SubComp.
c    Icmp,Jcmp  Array of the indices of the residual peaks.
c    RCmp       Array of the residuals
c    CCmp       Array of the estimated fluxes.
c
c-----------------------------------------------------------------------
      include 'maxdim.h'
      ptrdiff l
      integer i,j,k,Ncmpd,x0,y0,n0,itemp
      real Temp(MAXDIM)
      integer Indx(MAXDIM)
c-----------------------------------------------------------------------
c
c  Clear the mapping array.
c
      do j = 1, ny+1
        Ymap(j) = 0
      enddo
c
c  Loop around finding the residuals greater, in absolute value, than
c  LIMIT. Copy these to the residuals table.
c
      Ncmp = 0
      l = 0
      do k = 1, nrun
        y0 = Run(1,k)
        x0 = Run(2,k) - 1
        n0 = Run(3,k) - x0

        if (deep) then
          do i = 1, n0
            if (Estimate(l+i).ne.0) then
              Temp(i) = abs(Residual(l+i))
            else
              Temp(i) = 0
            endif
          enddo
        else
           do i = 1, n0
            Temp(i) = abs(Residual(l+i))
           enddo
        endif
        call whenfgt(n0, Temp, 1, Limit, Indx,Ncmpd)
        if (Ncmp+Ncmpd.gt.maxCmp)
     *        call bug('f','Internal bug in GetComp')

        do i = 1, Ncmpd
          RCmp(i+Ncmp) = Residual(l+Indx(i))
          CCmp(i+Ncmp) = Estimate(l+Indx(i))
          Icmp(i+Ncmp) = x0 + Indx(i)
          Jcmp(i+Ncmp) = y0
        enddo
        l = l + n0
        Ncmp = Ncmp + Ncmpd
        Ymap(y0) = Ymap(y0) + Ncmpd
      enddo
c
c  Ymap currently contains the number of residuals found in a particular
c  row. Convert this so that Ymap(j) gives the total number of peak
c  residuals in rows 1 to j-1. This loop will probably not vectorise.
c
      Ncmp = 0
      do j = 1, ny+1
        itemp = Ncmp
        Ncmp = Ncmp + Ymap(j)
        Ymap(j) = itemp
      enddo
c
c  If no components were found, stop; this means that user has
c  probably specified CLEAN boxes outside the bulk of the emission
c
      if (Ncmp.eq.0) call bug('w','No peak residuals found in GETCOMP')

      end

c***********************************************************************

      subroutine NewEst(CCmp,ICmp,JCmp,nCmp,Estimate,nPoint,Run,nRun)

      ptrdiff nPoint
      integer nCmp,nRun
      integer ICmp(nCmp),JCmp(nCmp),Run(3,nRun)
      real CCmp(nCmp),Estimate(nPoint)
c-----------------------------------------------------------------------
c  This adds the components in CCmp to the components in Estimate.
c  The components in the two arrays are, unfortunately, stored in very
c  different ways, CCmp having associated arrays containing indices,
c  while Estimate is described by run specifications.
c
c  Inputs:
c    nCmp       Number of components.
c    ICmp,JCmp  Coordinates of components in CCmp.
c    CCmp       Value of the component.
c    nPoint     Number of points in the estimate.
c    Run        Run specifications describing components in Estimate.
c    nRun       Number of run specifications.
c
c  Input/Output:
c    Estimate   All the components.
c
c-----------------------------------------------------------------------
      integer k,l
      ptrdiff i,j
c-----------------------------------------------------------------------
c     Vectorise this if you can!
      j = 1
      k = 1
      do l = 1, nCmp
        do while (JCmp(l).gt.Run(1,k) .or. ICmp(l).gt.Run(3,k))
          j = j + Run(3,k) - Run(2,k) + 1
          k = k + 1
        enddo
        i = ICmp(l) - Run(2,k) + j
        Estimate(i) = CCmp(l)
      enddo
      end

c***********************************************************************

      subroutine Diff(pBem,Estimate,Map,Residual,nPoint,nx,ny,
     *  Run,nRun)

      integer nx,ny,nRun,Run(3,nRun)
      ptrdiff pBem,nPoint
      real Estimate(nPoint),Map(nPoint),Residual(nPoint)
c-----------------------------------------------------------------------
      ptrdiff i
c-----------------------------------------------------------------------
      call CnvlR(pBem,Estimate,nx,ny,Run,nRun,Residual,'c')

      do i = 1, nPoint
        Residual(i) = Map(i) - Residual(i)
      enddo

      end

c***********************************************************************

      subroutine defregio(boxes,nMap,nBeam,icentre,jcentre)

      integer boxes(*),nMap(3),nBeam(2),icentre,jcentre
c-----------------------------------------------------------------------
c  Set the region of interest to the lastest area that can be safely
c  deconvolved.
c-----------------------------------------------------------------------
      integer blc(3),trc(3),width
c-----------------------------------------------------------------------
      width  = min(icentre-1,nBeam(1)-icentre) + 1
      blc(1) = max(1,(nMap(1)-width)/2)
      trc(1) = min(nMap(1),blc(1)+width-1)

      width  = min(jcentre-1,nBeam(2)-jcentre) + 1
      blc(2) = max(1,(nMap(2)-width)/2)
      trc(2) = min(nMap(2),blc(2)+width-1)

      blc(3) = 1
      trc(3) = nMap(3)

      call BoxDef(boxes,3,blc,trc)

      end
