TITLE slo2 current for C. elegans neuron model (suppose to interact with egl19)


COMMENT
channel type: calcium-related potassium channel

slo2-egl19 1:1 stoichiometry

model and parameters from:
Nicoletti, M., et al. (2019). "Biophysical modeling of C. elegans neurons: Single ion currents and whole-cell dynamics of AWCon and RMD." PLoS One 14(7): e0218738.
ENDCOMMENT


UNITS {
    (nS) = (nanosiemens)
    (mV) = (millivolt)
    (pA) = (picoamp)
    (um) = (micron)
    (molar) = (1/liter)  : moles do not appear in units
    (uM) = (micromolar)
}


NEURON {
    SUFFIX slo2_egl19
    USEION k READ ek WRITE ik
    USEION ca READ cai
    RANGE gbslo2, minf, tm, mcavinf, tmcav, hcavinf, thcav, m, hcav, mcav
}


PARAMETER {
    : slo2
    gbslo2 = 1 (nS/um2)
    wyx = 0.019 (1/mV)
    wxy = -0.024 (1/mV)
    wom = 0.90 (1/ms)
    wop = 0.027 (1/ms)
    kxy = 93.45 (uM/um2)
    nxy = 1.84
    kyx = 3294.55 (uM/um2)
    nyx = 0.00001
    canci = 0.05 (uM/um2) : calcium concentration When the calcium channel is closed

    : egl19
    vhm = 5.6 (mV)
    ka = 7.5 (mV)
    vhh = 24.9 (mV)
    ki = 12.0 (mV)
    vhhb = -20.5 (mV)
    kib = 8.1 (mV)
    ahinf = 1.43
    bhinf = 0.14
    chinf = 5.96
    dhinf = 0.60
    atm = 2.9 (ms)
    btm = 5.2 (mV)
    ctm = 6.0 (mV)
    dtm = 1.9 (ms)
    etm = 1.4 (mV)
    ftm = 30.0 (mV)
    gtm = 2.3 (ms)
    ath = 0.4
    bth = 44.6 (ms)
    cth = -23.0 (mV)
    dth = 5.0 (mV)
    eth = 36.4 (ms)
    fth = 28.7 (mV)
    gth = 3.7 (mV)
    hth = 43.1 (ms)
}


ASSIGNED {
    v (mV)
    ek (mV)
    ik (pA/um2)
    cai (uM/um2)
    minf
    tm (ms)
    mcavinf
    tmcav (ms)
    hcavinf
    thcav (ms)
}


STATE {
    m
    hcav
    mcav
}


BREAKPOINT {
    SOLVE states METHOD cnexp
    ik = gbslo2 * m * hcav * (v + 80) : ek=-80
}


INITIAL {
    setparames(v)
    hcav = hcavinf
    mcav = mcavinf
    m = minf
}


DERIVATIVE states {
    setparames(v)
    mcav' = (mcavinf - mcav) / tmcav
    hcav' = (hcavinf - hcav) / thcav
    m' = (minf - m) / tm    
}


PROCEDURE setparames(v (mV)) {
    LOCAL alpha, beta, wm, wp, fm, fp, kom, kop, kcm
    : egl19 model
    mcavinf = 1 / (1 + exp(-(v - vhm) / ka))
    hcavinf = (ahinf / (1 + exp(-(v - vhh) / ki)) + bhinf) * (chinf / (1 + exp((v - vhhb) / kib)) + dhinf)
    tmcav = atm * exp(-((v - btm) / ctm) ^ 2) + dtm * exp(-((v - etm) / ftm) ^ 2) + gtm
    thcav = ath * ((bth / (1 + exp((v - cth) / dth))) + (eth / (1 + exp((v - fth) / gth))) + hth)
    : slo2-egl19 model
    alpha = mcavinf / tmcav
    beta = 1 / tmcav - alpha
    wm = wom * exp(-wyx * v)
    wp = wop * exp(-wxy * v)
    fm = 1 / (1 + (cai / kyx) ^ nyx)
    fp = 1 / (1 + (kxy / cai) ^ nxy)
    kom = wm * fm
    kop = wp * fp
    kcm = wm * 1 / (1 + (canci / kyx) ^ nyx)
    minf = mcav * kop * (alpha + beta + kcm) / ((kop + kom) * (kcm + alpha) + beta * kcm)
    tm = (alpha + beta + kcm) / ((kop + kom) * (kcm + alpha) + beta * kcm)
}