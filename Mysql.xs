/* -*-C-*- */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "mysql.h"

typedef int SysRet;
typedef MYSQL_RES *Mysql__Result;
typedef HV *Mysql__Statement;
typedef HV *Mysql;

#define dBSV				\
  HV *          hv;				\
  HV *          stash;				\
  SV *          rv;				\
  SV *          sv;				\
  SV *          svsock;				\
  SV *          svdb;				\
  SV *          svhost;				\
  char * 	name = "Mysql::db_errstr"

#define dQUERY      \
  HV *          hv;                          \
  HV *          stash;               \
  SV *          rv;              \
  SV *          sv;              \
  char *        name = "Mysql::db_errstr";    \
  Mysql__Result  result = NULL;           \
  SV **         svp;                 \
  char *        package = "Mysql::Statement"; \
  MYSQL           *sock;                \
  int           tmp = -1

#define dRESULT					\
  dBSV;					\
  Mysql__Result	result = NULL;			\
  SV **		svp;				\
  char *	package = "Mysql::Statement";	\
  MYSQL		*sock

#define dFETCH		\
  dRESULT;			\
  int		off;		\
  MYSQL_FIELD *	curField;	\
  MYSQL_ROW	cur


#define dSTATE		\
  dRESULT;			\
  AV *		avkey;		\
  AV *		avnam;		\
  AV *		avnnl;		\
  AV *		avtab;		\
  AV *		avtyp;		\
  AV *		avlen;		\
  int		off = 0;	\
  MYSQL_FIELD *	curField

#define ERRMSG(sock)			\
    sv = perl_get_sv(name,TRUE);	\
    sv_setpv(sv,sock ? mysql_error(sock) : "");		\
    if (dowarn && ! SvTRUE(perl_get_sv("Mysql::QUIET",TRUE))) \
      warn("MYSQL's message: %s",sock ? mysql_error(sock) : "");	\
    XST_mUNDEF(0); \
    XSRETURN(1);


#define readSOCKET				\
  if (svp = hv_fetch(handle,"SOCK",4,FALSE)){	\
    sock = (MYSQL*) SvIV(*svp);			\
    svsock = (SV*)newSVsv(*svp);		\
  } else {					\
    svsock = &sv_undef;		\
  }						\
  if (svp = hv_fetch(handle,"DATABASE",8,FALSE)){	\
    svdb = (SV*)newSVsv(*svp);	\
  } else {					\
    svdb = &sv_undef;		\
  }						\
  if (svp = hv_fetch(handle,"HOST",4,FALSE)){	\
    svhost = (SV*)newSVsv(*svp);	\
  } else {					\
    svhost = &sv_undef;		\
  }

#define readRESULT				\
  if (svp = hv_fetch(handle,"RESULT",6,FALSE)){	\
    sv = *svp;					\
    result = (Mysql__Result)SvIV(sv);		\
  } else {					\
    sv =  &sv_undef;		\
  }

#define retMYSQLSOCK				\
    rv = newRV((SV*)hv);			\
    stash = gv_stashpv(package, TRUE);		\
    ST(0) = sv_2mortal(sv_bless(rv, stash))

#define iniHV 	hv = (HV*)sv_2mortal((SV*)newHV())

#define iniAV 	av = (AV*)sv_2mortal((SV*)newAV())

#define MYSQLPERL_FETCH_INTERNAL(a)  \
      iniAV;                \
      mysql_field_seek(result,0);      \
      numfields = mysql_num_fields(result);\
      while (off< numfields){       \
    curField = mysql_fetch_field(result);  \
    a               \
    off++;              \
      }                 \
      RETVAL = newRV((SV*)av)

static int
not_here(s)
char *s;
{
    croak("Mysql::%s not implemented on this architecture", s);
    return -1;
}

static double
constant(name, arg)
char *name;
int arg;
{
    errno = 0;
    switch (*name) {
    case 'A':
	break;
    case 'B':
	if (strEQ(name, "BLOB_FLAG"))
	  return BLOB_FLAG;
	break;
    case 'C':
	if (strEQ(name, "CHAR_TYPE"))
	    return FIELD_TYPE_STRING;
	break;
    case 'D':
	break;
    case 'E':
	break;
    case 'F':
	if (strEQ(name, "FIELD_TYPE_CHAR"))
	  return FIELD_TYPE_CHAR;
	if (strEQ(name,"FIELD_TYPE_SHORT"))
	  return FIELD_TYPE_SHORT;
	if (strEQ(name,"FIELD_TYPE_LONG"))
	  return FIELD_TYPE_LONG;
	if (strEQ(name,"FIELD_TYPE_FLOAT"))
	  return FIELD_TYPE_FLOAT;
	if (strEQ(name,"FIELD_TYPE_DOUBLE"))
	  return FIELD_TYPE_DOUBLE;
	if (strEQ(name,"FIELD_TYPE_TIMESTAMP"))
	  return FIELD_TYPE_TIMESTAMP;
	if (strEQ(name,"FIELD_TYPE_LONGLONG"))
	  return FIELD_TYPE_LONGLONG;
	if (strEQ(name,"FIELD_TYPE_STRING"))
	  return FIELD_TYPE_STRING;
	if (strEQ(name,"FIELD_TYPE_VAR_STRING"))
	  return FIELD_TYPE_VAR_STRING;
	if (strEQ(name,"FIELD_TYPE_DATE"))
	  return FIELD_TYPE_DATE;
	if (strEQ(name,"FIELD_TYPE_TIME"))
	  return FIELD_TYPE_TIME;
	if (strEQ(name,"FIELD_TYPE_BLOB"))
	  return FIELD_TYPE_BLOB;
	break;
    case 'G':
	break;
    case 'H':
	break;
    case 'I':
	if (strEQ(name, "INT_TYPE"))
	    return FIELD_TYPE_LONG;
	break;
    case 'J':
	break;
    case 'K':
	break;
    case 'L':
	break;
    case 'M':
	break;
    case 'N':
	if (strEQ(name, "NOT_NULL_FLAG"))
	    return NOT_NULL_FLAG;
	break;
    case 'O':
	break;
    case 'P':
	if (strEQ(name, "PRI_KEY_FLAG"))
	    return PRI_KEY_FLAG;
	break;
    case 'Q':
	break;
    case 'R':
	if (strEQ(name, "REAL_TYPE"))
	    return FIELD_TYPE_DOUBLE;
	break;
    case 'S':
	break;
    case 'T':
	break;
    case 'U':
	break;
    case 'V':
	if (strEQ(name, "VARCHAR_TYPE"))
	    return FIELD_TYPE_VAR_STRING;
	break;
    case 'W':
	break;
    case 'X':
	break;
    case 'Y':
	break;
    case 'Z':
	break;
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

MODULE = Statement	PACKAGE = Mysql::Statement	PREFIX = mysql_
SV *
fetchinternal(handle, key)
     Mysql::Statement		handle
     char *	key
   CODE:
{
  /* fetchinternal */
  dRESULT;
  AV*	av;
  int	off = 0;
  int	numfields;
  MYSQL_FIELD *	curField;

  readRESULT;
  RETVAL=0;
  switch (*key){
  case 'D':
    if (strEQ(key, "DATABASE"))
    {
      RETVAL = newSVpv("NOIDEA",6);
    }
    break;
  case 'H':
    if (strEQ(key, "HOST"))
      RETVAL = newSVpv("NOIDEA",6);
    break;
  case 'I':
    if (strEQ(key, "ISNOTNULL") && result){
    MYSQLPERL_FETCH_INTERNAL(av_push(av,(SV*)newSViv(IS_NOT_NULL(curField->flags))););
    }
    else if (strEQ(key, "ISPRIKEY") && result) {
    MYSQLPERL_FETCH_INTERNAL(av_push(av,(SV*)newSViv(IS_PRI_KEY(curField->flags))););
    }
    else if (strEQ(key, "ISBLOB") && result) {
    MYSQLPERL_FETCH_INTERNAL(av_push(av,(SV*)newSViv(IS_BLOB(curField->flags))););
    }
    break;
  case 'L':
    if (strEQ(key, "LENGTH") && result) {
    MYSQLPERL_FETCH_INTERNAL(av_push(av,(SV*)newSViv(curField->length)););
    }
    break;
  case 'N':
    if (strEQ(key, "NAME") && result) {
    MYSQLPERL_FETCH_INTERNAL(av_push(av,(SV*)newSVpv(curField->name,strlen(curField->name))););
    }
    if (strEQ(key, "NUMFIELDS") && result)
      RETVAL = newSViv((IV)mysql_num_fields(result));
    if (strEQ(key, "NUMROWS") && result)
      RETVAL = newSViv((IV)mysql_num_rows(result));
    break;
  case 'R':
    if (strEQ(key, "RESULT") && result)
      RETVAL = newSViv((IV)result);
    break;
  case 'S':
    if (strEQ(key, "SOCK") && result)
    {
      if (svp == hv_fetch(handle,"SOCK",4,FALSE))
	RETVAL = newSViv(SvIV(*svp));
      else
	RETVAL = newSVpv("NOIDEA",6);
    }
    break;
  case 'T':
    if (strEQ(key, "TABLE") && result) {
    MYSQLPERL_FETCH_INTERNAL(av_push(av,(SV*)newSVpv(curField->table,strlen(curField->table))););
    }
    if (strEQ(key, "TYPE") && result) {
    MYSQLPERL_FETCH_INTERNAL(av_push(av,(SV*)newSViv(curField->type)););
    }
    break;
  }
  if (!RETVAL)
    XSRETURN_UNDEF;
}
   OUTPUT:
     RETVAL


SV * 
mysql_fetchrow(handle)
   Mysql::Statement	handle
   PROTOTYPE: $
   PPCODE:
{
/* This one is very simple, it just returns us an array of the fields
   of a row. If we want to know more about the fields, we look into
   $sth->{XXX}, where XXX may be one of NAME, TABLE, TYPE, IS_PRI_KEY,
   and IS_NOT_NULL */

  dFETCH;

  /* mysql_fetch_row */
  readRESULT;
  if (result && (cur = mysql_fetch_row(result)))
  {
    int count;
    if ((count=mysql_num_fields(result)) > 0)
    {
      unsigned int *lengths=mysql_fetch_lengths(result);
      for (off=0 ; off < count ; off++)
      {
	EXTEND(sp,1);
	if (cur[off])
	{
	  PUSHs(sv_2mortal((SV*)newSVpv(cur[off], lengths[off])));
	}
	else
	{
	  PUSHs(&sv_undef);
	}
      }
    }
  }
}

SV *
mysql_fetchhash(handle)
   Mysql::Statement  handle
   PPCODE:
{

  dFETCH;
  int       placeholder = 1;

  /* mysqlfetchhash */
  readRESULT;
  if (result && (cur = mysql_fetch_row(result))) {
    off = 0;
    mysql_field_seek(result,0);
    if ( mysql_num_fields(result) > 0 )
      placeholder = mysql_num_fields(result);
    EXTEND(sp,placeholder*2);
    while(off < placeholder){
      curField = mysql_fetch_field(result);
      PUSHs(sv_2mortal((SV*)newSVpv(curField->name,strlen(curField->name))));
      if (cur[off]){
    PUSHs(sv_2mortal((SV*)newSVpv(cur[off], strlen(cur[off]))));
      }else{
    PUSHs(&sv_undef);
      }

      off++;
    }
  }
}

SV * 
mysql_dataseek(handle,pos)
   Mysql::Statement	handle
   int			pos
   CODE:
{
/* In my eyes, we don't need that, but as it's there we implement it,
   of course: set the position of the cursor to a specified record
   number. */

  Mysql__Result	result = NULL;
  SV *		sv;
  SV **		svp;

  /* mysql_data_seek */
  readRESULT;
  if (result)
    mysql_data_seek(result,pos);
  else
    croak("Could not DataSeek, no result handle found");
}

SV *
mysql_destroy(handle)
   Mysql::Statement	handle
   CODE:
{
/* We have to free memory, when a handle is not used anymore */

  Mysql__Result	result = NULL;
  SV *		sv;
  SV **		svp;

  /* mysqlDESTROY */
  readRESULT;
  if (result){
#ifdef DBUG
    printf("Mysql::Statement -- Going to free result: %lx\n", result);
#endif
    mysql_free_result(result);
#ifdef DBUG
    printf("Mysql::Statement -- Result freed: %lx\n", result);
#endif
  } else {
#ifdef DBUG
    printf("Mysql.xs: Could not free some result, handle: %lx\n",handle);
#endif
  }
}



MODULE = Mysql		PACKAGE = Mysql		PREFIX = mysql_

double
constant(name,arg)
	char *		name
	int		arg

char *
mysql_errmsg(package = "Mysql",handle=NULL)
     Mysql		handle
   CODE:
   {
      dRESULT;
      if (handle) {
         readSOCKET;
         RETVAL=mysql_error(sock);
      } else {
         RETVAL="need database handle to retrieve error string";
      }
   }
   OUTPUT:
   RETVAL

char *
mysql_getserverinfo(package = "Mysql",handle=NULL)
     Mysql		handle
   CODE:
   {
      dRESULT;
      if (handle) {
         readSOCKET;
         RETVAL=mysql_get_server_info(sock);
      } else {
         RETVAL="need database handle to retrieve error string";
      }
   }
   OUTPUT:
   RETVAL

SV *
mysql_connect(package = "Mysql",host=NULL,db=NULL,password=NULL,user=NULL)
     char *		package
     char *		host
     char *		db
     char *		password
     char *		user
   CODE:
{
/* As we may have multiple simultaneous sessions with more than one
   connect, we bless an object, as soon as a connection is established
   by Mysql->Connect(host, db). The object is a hash, where we put the
   socket returned by mysql_connect under the key "SOCK".  An extra
   argument may be given to select the database we are going to access
   with this handle. As soon as a database is selected, we add it to
   the hash table in the key DATABASE. */

  dBSV;
  MYSQL           *sock,*mysql;

  mysql=malloc(sizeof(*mysql));
  sock = mysql_connect(mysql,host && host[0] ? host : NULL,user,password);

  if ((!sock) || (db && (mysql_select_db(sock,db) < 0)))
  {
    ERRMSG(mysql);
    free((char*) mysql);
  } else {
    iniHV;
    svsock = (SV*)newSViv((IV) sock);
    if (db)
      svdb = (SV*)newSVpv(db,0);
    else
      svdb = &sv_undef;
    if (host)
      svhost = (SV*)newSVpv(host,0);
    else
      svhost = &sv_undef;
    hv_store(hv,"SOCK",4,svsock,0);
    hv_store(hv,"HOST",4,svhost,0);
    hv_store(hv,"DATABASE",8,svdb,0);
    retMYSQLSOCK;
  }
}

SysRet
mysql_selectdb(handle, db)
     Mysql		handle
     char *		db
   CODE:
{
/* This routine does not return an object, it just sets a database
   within the connection. */

  /* mysql_select_db */
  dRESULT;

  readSOCKET;
  if (sock && db)
    RETVAL = mysql_select_db(sock,db);
  else
    RETVAL = -1;
  if (RETVAL == -1){
    ERRMSG(sock);
  } else {
    hv_store(handle,"DATABASE",8,(SV*)newSVpv(db,0),0);
  }
}
 OUTPUT:
RETVAL


SV * 
mysql_query(handle, query)
   Mysql		handle
     char *	query
   PROTOTYPE: $$
   CODE:
{
/* A successful query returns a statement handle in the
   Mysql::Statement class. In that class we have a FetchRow() method,
   that returns us one row after the other. We may repeat the fetching
   of rows beginning with an arbitrary row number after we reset the
   position-pointer with DataSeek().
   */

  dQUERY;

  if (svp = hv_fetch(handle,"SOCK",4,FALSE))
    sock = SvIV(*svp);

  if (sock)
    tmp = mysql_query(sock,query);
  if (tmp < 0 ) {
    ERRMSG(sock);
  } else {
    hv = (HV*)sv_2mortal((SV*)newHV());
    if (result = mysql_store_result(sock)){
      hv_store(hv,"RESULT",6,(SV *)newSViv((IV)result),0);
      rv = newRV((SV*)hv);
      stash = gv_stashpv(package, TRUE);
      ST(0) = sv_2mortal(sv_bless(rv, stash));
    } else {
      ST(0) = sv_newmortal();
      if (tmp > 0){
    sv_setnv( ST(0), tmp);
      } else {
    sv_setpv( ST(0), "0e0");
      }
    }
  }
}

SV * 
mysql_listdbs(handle)
   Mysql		handle
   PPCODE:
{
/* We return an array, of course. */

  dFETCH;

  readSOCKET;
  if (sock)
    result = mysql_list_dbs(sock,(char*) NULL);
  if (result == NULL ) {
    ERRMSG(sock);
  } else {
    while ( cur = mysql_fetch_row(result) ){
      EXTEND(sp,1);
      curField = mysql_fetch_field(result);
      PUSHs(sv_2mortal((SV*)newSVpv(cur[0], strlen(cur[0]))));
    }
    mysql_free_result(result);
  }
}

SV * 
mysql_listtables(handle)
   Mysql		handle
   PROTOTYPE: $$
   PPCODE:
{
/* We return an array, of course. */

  dFETCH;

  readSOCKET;
  if (sock)
    result = mysql_list_tables(sock,(char*) NULL);
  if (result == NULL ) {
    ERRMSG(sock);
  } else {
    while ( cur = mysql_fetch_row(result) ){
      EXTEND(sp,1);
     curField = mysql_fetch_field(result);
      PUSHs(sv_2mortal((SV*)newSVpv(cur[0], strlen(cur[0]))));
    }
    mysql_free_result(result);
  }
}

SV * 
mysql_listfields(handle, table)
   Mysql			handle
   char *		table
   PROTOTYPE: $$
   CODE:
{
/* This is similar to a query with 0 rows in the result. Unlike with
   the query we are guaranteed by the API to have field information
   where we also have it after a successful query. That means, we find
   no result with FetchRow, but we have a ref to a filled Hash with
   NAME, TABLE, TYPE, IS_PRI_KEY, and IS_NOT_NULL. We do less into
   mysqlStatement, so DESTROY will free the query. */

  HV *          hv;
  HV *          stash;
  SV *          rv;
  SV *          sv;
  char *        name = "Mysql::db_errstr";
  Mysql__Result  result = NULL;
  SV **         svp;
  char *        package = "Mysql::Statement";
  MYSQL         *sock;
  int           tmp = -1;

  /* mysqlFastListFields */
  if (svp = hv_fetch(handle,"SOCK",4,FALSE)){
    sock = (MYSQL*) SvIV(*svp);
  } else {
    croak("Could not read svp");
  }
  if (sock && table)
    result = mysql_list_fields(sock,table,(char*) NULL);
  if (result == NULL ) {
    ERRMSG(sock);
  } else {
    hv = (HV*)sv_2mortal((SV*)newHV());
    hv_store(hv,"RESULT",6,(SV *)newSViv((IV)result),0);
    rv = newRV((SV*)hv);
    stash = gv_stashpv(package, TRUE);
    ST(0) = sv_2mortal(sv_bless(rv, stash));
  }
}

SV * 
mysql_destroy(handle)
   Mysql			handle
   PROTOTYPE: $
   CODE:
{
/* Somebody has freed the object that keeps us connected with the
   database, so we have to tell the server, that we are done. */

  SV **	svp;
  MYSQL *sock=0;

  if (svp = hv_fetch(handle,"SOCK",4,FALSE))
    sock = (MYSQL*) SvIV(*svp);
#ifdef DBUG
  printf("Mysql::destroy -- Going to free result: %lx\n", sock);
#endif
  if (sock)
  {
    mysql_close(sock);
    free(sock);
  }
}
