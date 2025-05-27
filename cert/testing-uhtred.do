clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all
do ./build/buildmlib.do
mata mata clear
adopath ++ "~/Stata-dev/uhtred"
clear all
adopath ++ "~/Stata-dev/uhtred/uhtred"
clear all

// seed, for reproducibility
set seed 1993480

//
clear all
webuse catheter
range tv 0 500 6
// mestreg c.age i.female || patient:, distribution(weibull)
// estimates store m_mestreg
// predict b*, reffects reses(bse*)
// predict xb, xb 
// list b1 bse1 if _n == 1 
// stdmest Sm, reat(.7613212) reatse(.6750813) reatref(0.0) reatrefse(0.0) contrast timevar(tv)
// list tv Sm* if tv != ., compress clean
//         tv          Sm      Sm_ref   Sm_contr~t  
//   1.     0           1           1            0  
//   2.   100   .20076556   .41147107   -.21070551  
//   3.   200   .03425659   .17359759   -.13934101  
//   4.   300   .00479274     .067517   -.06272426  
//   5.   400   .00059574   .02446382   -.02386808  
//   6.   500   .00006872   .00841253   -.00834381  

uhtred (_t c.age i.female M1[patient]@1, family(rp, df(1) failure(_d)))
stdmest Su, reat(.7613212) reatse(.6750813) reatref(0.0) reatrefse(0.0) contrast timevar(tv)

// TEMPLATE:
// for ()
// 	b
// 	gml.myb = b
//
// 	xb = uhtred_util_p_xb(gml)
// 	tb = uhtred_util_p_tb(gml,t)
//
// 	zb = zb0 + zb1
//
// 	S = exp(-exp( xb + tb + zb))
