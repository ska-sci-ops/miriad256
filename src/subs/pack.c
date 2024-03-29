/*============================================================================
*
*  Functions to convert data between disk and machine format.  The disk format
*  in Miriad is always big-endian (most significant byte first) IEEE floating-
*  point and 16- or 32-bit integer.
*
*  This version is for machines where float == IEEE big-endian, int == 32-bit
*  integer, short int == 16-bit integer.
*
*  packx_c, unpackx_c, pack32_c and unpack32_c are implemented as macros
*  (calling bcopy) in the system dependent include file.
*
*  History:
*    rjs  Dark-ages Original version.
*    bs   ?????89   Improved efficiency using "register" declarations.
*    rjs   1nov89   Incoporated Brian's changes.
*    rjs  02jan05   Added pack64/unpack64
*
*  $Id: pack.c,v 1.2 2006/10/19 06:45:14 cal103 Exp $
*===========================================================================*/

#include <string.h>

#include "miriad.h"
#include "sysdep.h"

/************************************************************************/
void pack16_c(from,to,n)
char *to;
register int *from;
int n;
/*
  Pack integers into 16 bit integers. Its simple on machines whose short
  ints are 16 bits.

  Input:
    from	Array of int to pack.
    n		Number to pack.
  Output:
    to		Output array of 16 bit integers.
------------------------------------------------------------------------*/
{
  register short int *tto;
  register int i;
  if(sizeof(short int) != 2)bug_c('f',"Short Int not 2 bytes");
  tto = (short int *)to;
  for(i=0; i < n; i++)*tto++ = *from++;
}
/************************************************************************/
void unpack16_c(from,to,n)
char *from;
register int *to ;
int n;
/*
  Unpack an array of 16 bit integers into the host integer format.
  Its pretty simple on machines whose short int is 16 bits, and the
  byte order is most significant byte first.

  Input:
    from	Array of 16 bit integers.
    n		Number of integers to convert.
  Output:
    to		Array of host integers.
------------------------------------------------------------------------*/
{
  register short int *ffrom;
  register int i;

  if(sizeof(short int) != 2)bug_c('f',"Short Int not 2 bytes");
  ffrom = (short int *)from;
  for(i=0; i < n; i++)*to++ = *ffrom++;
}
/************************************************************************/
void pack64_c(from,to,n)
char *to;
register int8 *from;
int n;
/*
  Pack int8's into 64 bit integers.

  Input:
    from	Array of int8 to pack.
    n		Number to pack.
  Output:
    to		Output array of 64-bit integers.
------------------------------------------------------------------------*/
{
  long long int *tto;
  int i;
  if(sizeof(int8) == 8){
    memcpy((char *)to,(char *)from,sizeof(int8)*n);
  }else if(sizeof(int8) == 4){
    if(sizeof(long long int) != 8)bug_c('f',"Unsupported size of long long int variables in pack64_c");
    tto = (long long int *)to;
    for(i=0; i< n; i++)*tto++ = *from++;
  }else{
    bug_c('f',"Unsupported size of int8 variables in pack64_c");
  }
}
/************************************************************************/
void unpack64_c(from,to,n)
char *from;
int8 *to ;
int n;
/*
  Unpack an array of 64 bit integers into the host int8 format.

  Input:
    from	Array of 64 bit integers.
    n		Number of integers to convert.
  Output:
    to		Array of host int8s.
------------------------------------------------------------------------*/
{
  long long int *ffrom,temp;
  int i;
  if(sizeof(int8) == 8){
    memcpy((char *)to,(char *)from,sizeof(int8)*n);
  }else if(sizeof(int8) == 4){
    if(sizeof(long long int) != 8)bug_c('f',"Unsupported size of long long int variables in unpack64_c");
    ffrom = (long long int *)from;
    for(i=0; i< n; i++){
      temp = *ffrom++;
      if(temp > 0x7FFFFFFF)bug_c('f',"Integer overflow in unpack64_c");
      *to++ = temp;
    }
  }else{
    bug_c('f',"Unsupported size of int8 variables in unpack64_c");
  }
}

/************************************************************************/
void pack32_c(in,out,n)
int *in,n;
char *out;
/*
  Pack an array of integers into 32 bit integers.
------------------------------------------------------------------------*/
{
  int i;
  char *s;

  s = (char *)in;
  for(i = 0; i < n; i++){
    *out++ = *(s+3);
    *out++ = *(s+2);
    *out++ = *(s+1);
    *out++ = *s;
    s += 4;
  }
}
/************************************************************************/
void unpack32_c(in,out,n)
int *out,n;
char *in;
/*
  Unpack an array of 32 bit integers into integers.
------------------------------------------------------------------------*/
{
  int i;
  char *s;

  s = (char *)out;
  for(i = 0; i < n; i++){
    *s++ = *(in+3);
    *s++ = *(in+2);
    *s++ = *(in+1);
    *s++ = *in;
    in += 4;
  }
}
/************************************************************************/
void packr_c(in,out,n)
int n;
float *in;
char *out;
/*
  Pack an array of reals into IEEE reals -- just do byte reversal.
------------------------------------------------------------------------*/
{
  int i;
  char *s;

  s = (char *)in;
  for(i = 0; i < n; i++){
    *out++ = *(s+3);
    *out++ = *(s+2);
    *out++ = *(s+1);
    *out++ = *s;
    s += 4;
  }
}
/************************************************************************/
void unpackr_c(in,out,n)
char *in;
float *out;
int n;
/*
  Unpack an array of IEEE reals into reals -- just do byte reversal.
------------------------------------------------------------------------*/
{
  int i;
  char *s;

  s = (char *)out;
  for(i = 0; i < n; i++){
    *s++ = *(in+3);
    *s++ = *(in+2);
    *s++ = *(in+1);
    *s++ = *in;
    in += 4;
  }
}

/************************************************************************/
void packd_c(in,out,n)
double *in;
char *out;
int n;
/*
  Pack an array of doubles -- this involves simply performing byte
  reversal.
------------------------------------------------------------------------*/
{
  int i;
  char *s;

  s = (char *)in;
  for(i = 0; i < n; i++){
    *out++ = *(s+7);
    *out++ = *(s+6);
    *out++ = *(s+5);
    *out++ = *(s+4);
    *out++ = *(s+3);
    *out++ = *(s+2);
    *out++ = *(s+1);
    *out++ = *s;
    s += 8;
  }
}
/************************************************************************/
void unpackd_c(in,out,n)
char *in;
double *out;
int n;
/*
  Unpack an array of doubles -- this involves simply performing byte
  reversal.
------------------------------------------------------------------------*/
{
  int i;
  char *s;

  s = (char *)out;
  for(i = 0; i < n; i++){
    *s++ = *(in+7);
    *s++ = *(in+6);
    *s++ = *(in+5);
    *s++ = *(in+4);
    *s++ = *(in+3);
    *s++ = *(in+2);
    *s++ = *(in+1);
    *s++ = *in;
    in += 8;
  }
}