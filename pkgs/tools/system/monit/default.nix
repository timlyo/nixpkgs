{stdenv, fetchurl, openssl, bison, flex, pam, zlib, usePAM ? stdenv.isLinux
 , buildPlatform, hostPlatform }:
let useSSL = (openssl != null);
    isCross = ( buildPlatform != hostPlatform ) ; in
stdenv.mkDerivation rec {
  name = "monit-5.25.2";

  src = fetchurl {
    url = "${meta.homepage}dist/${name}.tar.gz";
    sha256 = "0jn6mdsh50zd3jc61hr1y8sd80r01gqcyvd860zf8m8i3lvfc35a";
  };

  nativeBuildInputs = [ bison flex ];
  buildInputs = [ zlib.dev ] ++
    stdenv.lib.optionals useSSL [ openssl ] ++
    stdenv.lib.optionals usePAM [ pam ];

  configureFlags =
    if useSSL then [
      "--with-ssl-incl-dir=${openssl.dev}/include"
      "--with-ssl-lib-dir=${openssl.out}/lib"
    ] else [ "--without-ssl" ] ++
    stdenv.lib.optionals (! usePAM) [ "--without-pam" ] ++
    # will need to check both these are true for musl
    stdenv.lib.optionals isCross [ "libmonit_cv_setjmp_available=yes"
                                   "libmonit_cv_vsnprintf_c99_conformant=yes"];

  meta = {
    homepage = http://mmonit.com/monit/;
    description = "Monitoring system";
    license = stdenv.lib.licenses.agpl3;
    maintainers = with stdenv.lib.maintainers; [ raskin wmertens ];
    platforms = with stdenv.lib.platforms; linux;
  };
}
