C***********************************************************************
c*CPPSL -- Solve complex hermitian positive definite system
c:LINPACK
c+
      SUBROUTINE CPPSL(AP,N,B)
      INTEGER N
      COMPLEX AP(1),B(1)
C
C     CPPSL SOLVES THE COMPLEX HERMITIAN POSITIVE DEFINITE SYSTEM
C     A * X = B
C     USING THE FACTORS COMPUTED BY CPPCO OR CPPFA.
C
C     ON ENTRY
C
C	 AP	 COMPLEX (N*(N+1)/2)
C		 THE OUTPUT FROM CPPCO OR CPPFA.
C
C	 N	 INTEGER
C		 THE ORDER OF THE MATRIX  A .
C
C	 B	 COMPLEX(N)
C		 THE RIGHT HAND SIDE VECTOR.
C
C     ON RETURN
C
C	 B	 THE SOLUTION VECTOR  X .
C
C     ERROR CONDITION
C
C	 A DIVISION BY ZERO WILL OCCUR IF THE INPUT FACTOR CONTAINS
C	 A ZERO ON THE DIAGONAL.  TECHNICALLY THIS INDICATES
C	 SINGULARITY BUT IT IS USUALLY CAUSED BY IMPROPER SUBROUTINE
C	 ARGUMENTS.  IT WILL NOT OCCUR IF THE SUBROUTINES ARE CALLED
C	 CORRECTLY AND	INFO .EQ. 0 .
C
C     TO COMPUTE  INVERSE(A) * C  WHERE	 C  IS A MATRIX
C     WITH  P  COLUMNS
C	    CALL CPPCO(AP,N,RCOND,Z,INFO)
C	    IF (RCOND IS TOO SMALL .OR. INFO .NE. 0) GO TO ...
C	    DO 10 J = 1, P
C	       CALL CPPSL(AP,N,C(1,J))
C	 10 CONTINUE
C
C--
C     LINPACK.	THIS VERSION DATED 08/14/78 .
C     CLEVE MOLER, UNIVERSITY OF NEW MEXICO, ARGONNE NATIONAL LAB.
C
C     SUBROUTINES AND FUNCTIONS
C
C     BLAS CAXPY,CDOTC
C
C     INTERNAL VARIABLES
C
      COMPLEX CDOTC,T
      INTEGER K,KB,KK
C
      KK = 0
      DO 10 K = 1, N
	 T = CDOTC(K-1,AP(KK+1),1,B(1),1)
	 KK = KK + K
	 B(K) = (B(K) - T)/AP(KK)
   10 CONTINUE
      DO 20 KB = 1, N
	 K = N + 1 - KB
	 B(K) = B(K)/AP(KK)
	 KK = KK - K
	 T = -B(K)
	 CALL CAXPY(K-1,T,AP(KK+1),1,B(1),1)
   20 CONTINUE
      RETURN
      END
