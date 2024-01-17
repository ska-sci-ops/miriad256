C***********************************************************************
c*CPPFA -- Factor complex hermitian postive definite packed matrix.
c:LINPACK
c+
      SUBROUTINE CPPFA(AP,N,INFO)
      INTEGER N,INFO
      COMPLEX AP(1)
C
C     CPPFA FACTORS A COMPLEX HERMITIAN POSITIVE DEFINITE MATRIX
C     STORED IN PACKED FORM.
C
C     CPPFA IS USUALLY CALLED BY CPPCO, BUT IT CAN BE CALLED
C     DIRECTLY WITH A SAVING IN TIME IF	 RCOND	IS NOT NEEDED.
C     (TIME FOR CPPCO) = (1 + 18/N)*(TIME FOR CPPFA) .
C
C     ON ENTRY
C
C	 AP	 COMPLEX (N*(N+1)/2)
C		 THE PACKED FORM OF A HERMITIAN MATRIX	A .  THE
C		 COLUMNS OF THE UPPER TRIANGLE ARE STORED SEQUENTIALLY
C		 IN A ONE-DIMENSIONAL ARRAY OF LENGTH  N*(N+1)/2 .
C		 SEE COMMENTS BELOW FOR DETAILS.
C
C	 N	 INTEGER
C		 THE ORDER OF THE MATRIX  A .
C
C     ON RETURN
C
C	 AP	 AN UPPER TRIANGULAR MATRIX  R , STORED IN PACKED
C		 FORM, SO THAT	A = CTRANS(R)*R .
C
C	 INFO	 INTEGER
C		 = 0  FOR NORMAL RETURN.
C		 = K  IF THE LEADING MINOR OF ORDER  K	IS NOT
C		      POSITIVE DEFINITE.
C
C
C     PACKED STORAGE
C
C	   THE FOLLOWING PROGRAM SEGMENT WILL PACK THE UPPER
C	   TRIANGLE OF A HERMITIAN MATRIX.
C
C		 K = 0
C		 DO 20 J = 1, N
C		    DO 10 I = 1, J
C		       K = K + 1
C		       AP(K) = A(I,J)
C	      10    CONTINUE
C	      20 CONTINUE
C
C--
C     LINPACK.	THIS VERSION DATED 08/14/78 .
C     CLEVE MOLER, UNIVERSITY OF NEW MEXICO, ARGONNE NATIONAL LAB.
C
C     SUBROUTINES AND FUNCTIONS
C
C     BLAS CDOTC
C     FORTRAN AIMAG,CMPLX,CONJG,REAL,SQRT
C
C     INTERNAL VARIABLES
C
      COMPLEX CDOTC,T
      REAL S
      INTEGER J,JJ,JM1,K,KJ,KK
C     BEGIN BLOCK WITH ...EXITS TO 40
C
C
	 JJ = 0
	 DO 30 J = 1, N
	    INFO = J
	    S = 0.0E0
	    JM1 = J - 1
	    KJ = JJ
	    KK = 0
	    IF (JM1 .LT. 1) GO TO 20
	    DO 10 K = 1, JM1
	       KJ = KJ + 1
	       T = AP(KJ) - CDOTC(K-1,AP(KK+1),1,AP(JJ+1),1)
	       KK = KK + K
	       T = T/AP(KK)
	       AP(KJ) = T
	       S = S + REAL(T*CONJG(T))
   10	    CONTINUE
   20	    CONTINUE
	    JJ = JJ + J
	    S = REAL(AP(JJ)) - S
C     ......EXIT
	    IF (S .LE. 0.0E0 .OR. AIMAG(AP(JJ)) .NE. 0.0E0) GO TO 40
	    AP(JJ) = CMPLX(SQRT(S),0.0E0)
   30	 CONTINUE
	 INFO = 0
   40 CONTINUE
      RETURN
      END