==============================================================

run_FLTR.R

R interface to the Fortran 3-D groundwater flow &

contaminant transport subroutine FLTR

==============================================================

---------------------------------------------------------------

0.  LOAD THE SHARED LIBRARY

---------------------------------------------------------------

lib_path <- "./FLTR.so"          # adjust path as needed# Windows: "./FLTR.dll"

if (!is.loaded("fltr")) {         # avoid double-loadingdyn.load(lib_path)}cat("Library loaded:", is.loaded("fltr"), "\n")

---------------------------------------------------------------

1.  GLOBAL PARAMETER  (must match the Fortran PARAMETER :: mx)

---------------------------------------------------------------

mx <- 100L

---------------------------------------------------------------

2.  SCALAR INTEGERS

---------------------------------------------------------------

NRO <- 10L          # number of rowsNCO <- 10L          # number of columnsNTC <- 10L          # number of layers  (3-D)nt  <- 100L         # number of time steps

---------------------------------------------------------------

3.  INTEGER ARRAYS  dim = (mx, mx)

All initialised to zero; fill with real connectivity

indices before production runs.

---------------------------------------------------------------

make_int_mat <- function() matrix(0L, nrow = mx, ncol = mx)

IB   <- make_int_mat();   IE   <- make_int_mat()JBEI <- make_int_mat();   KBEI <- make_int_mat()IBB  <- make_int_mat();   IEB  <- make_int_mat()JB   <- make_int_mat();   JE   <- make_int_mat()IBEJ <- make_int_mat();   KBEJ <- make_int_mat()JBB  <- make_int_mat();   JEB  <- make_int_mat()KB   <- make_int_mat();   KE   <- make_int_mat()IBEK <- make_int_mat();   JBEK <- make_int_mat()KBB  <- make_int_mat();   KEB  <- make_int_mat()

B    <- integer(mx)       # boundary flag vector (length mx)

---------------------------------------------------------------

4.  DOUBLE PRECISION 3-D ARRAYS  dim = (mx, mx, mx)

Initialised to zero; replace with your grid / field data.

---------------------------------------------------------------

make_dbl_3d <- function() array(0.0, dim = c(mx, mx, mx))

H3D    <- make_dbl_3d()   # hydraulic head  [m]C3D    <- make_dbl_3d()   # concentration   [mg/L or mol/m³]X      <- make_dbl_3d()   # node x-coordinate [m]Y      <- make_dbl_3d()   # node y-coordinate [m]Z      <- make_dbl_3d()   # node z-coordinate [m]DELTAX <- make_dbl_3d()   # cell size in x  [m]DELTAY <- make_dbl_3d()   # cell size in y  [m]DELTAZ <- make_dbl_3d()   # cell size in z  [m]

---------------------------------------------------------------

5.  BOUNDARY CONDITION VECTORS  (length mx)

---------------------------------------------------------------

BCP <- double(mx)         # pressure / head BC valuesBCT <- double(mx)         # concentration   BC values

---------------------------------------------------------------

6.  PHYSICAL & TRANSPORT SCALARS

---------------------------------------------------------------

dt     <- 86400.0         # time step          [s]  (1 day)TEL    <- 0.0             # elapsed time       [s]

KX     <- 1.0e-4          # hydraulic conductivity – x [m/s]KY     <- 1.0e-4          # hydraulic conductivity – y [m/s]KZ     <- 1.0e-5          # hydraulic conductivity – z [m/s]SS     <- 1.0e-4          # specific storage          [1/m]POR    <- 0.30            # porosity                  [-]

Dm     <- 1.0e-9          # molecular diffusion       [m²/s]ALFAL  <- 10.0            # longitudinal dispersivity [m]ALFATV <- 1.0             # transverse (vertical) dispersivity [m]ALFATH <- 1.0             # transverse (horizontal) dispersivity [m]

GAMA   <- 0.0             # decay / production coefficient [1/s]Rd     <- 1.0             # retardation factor              [-]D3D    <- 0.0             # initial dispersion coefficient  [m²/s]TETA   <- 0.5             # time-weighting factor (0=explicit,1=implicit)

---------------------------------------------------------------

7.  EXAMPLE: populate a simple regular grid

Remove / replace with your real data loader

---------------------------------------------------------------

dx <- 10.0    # uniform cell size [m]dy <- 10.0dz <-  2.0

for (i in seq_len(NRO)) {for (j in seq_len(NCO)) {for (k in seq_len(NTC)) {X[i, j, k]      <- (i - 0.5) * dxY[i, j, k]      <- (j - 0.5) * dyZ[i, j, k]      <- (k - 0.5) * dzDELTAX[i, j, k] <- dxDELTAY[i, j, k] <- dyDELTAZ[i, j, k] <- dzH3D[i, j, k]    <- 10.0 - 0.01 * (i - 1) * dx  # linear head gradientC3D[i, j, k]    <- 0.0                           # zero initial concentration}}}

---------------------------------------------------------------

8.  CALL THE FORTRAN SUBROUTINE VIA .Fortran()

IMPORTANT RULES:

• Fortran name is lower-case in R on Linux/Mac

• Every argument must be of the EXACT type & storage mode

that the Fortran routine expects (INTEGER or DOUBLE)

• Arrays must be column-major (R default = Fortran order ✓)

---------------------------------------------------------------

cat("Calling FLTR Fortran subroutine...\n")

Result <- .Fortran("fltr",                      # lower-case on Linux/Mac# use "FLTR" on Windows if needed

--- scalar integers ---

NRO    = as.integer(NRO),NCO    = as.integer(NCO),NTC    = as.integer(NTC),

--- integer arrays (mx x mx) ---

IB     = as.integer(IB),     IE     = as.integer(IE),JBEI   = as.integer(JBEI),   KBEI   = as.integer(KBEI),IBB    = as.integer(IBB),    IEB    = as.integer(IEB),JB     = as.integer(JB),     JE     = as.integer(JE),IBEJ   = as.integer(IBEJ),   KBEJ   = as.integer(KBEJ),JBB    = as.integer(JBB),    JEB    = as.integer(JEB),KB     = as.integer(KB),     KE     = as.integer(KE),IBEK   = as.integer(IBEK),   JBEK   = as.integer(JBEK),KBB    = as.integer(KBB),    KEB    = as.integer(KEB),

--- 3-D double arrays ---

DELTAX = as.double(DELTAX),DELTAY = as.double(DELTAY),DELTAZ = as.double(DELTAZ),

--- scalars ---

dt     = as.double(dt),nt     = as.integer(nt),

--- boundary vectors ---

B      = as.integer(B),BCP    = as.double(BCP),BCT    = as.double(BCT),

--- hydraulic parameters ---

KX     = as.double(KX),KY     = as.double(KY),KZ     = as.double(KZ),SS     = as.double(SS),

--- state arrays (INOUT – returned by .Fortran) ---

H3D    = as.double(H3D),C3D    = as.double(C3D),

--- coordinate arrays ---

X      = as.double(X),Y      = as.double(Y),Z      = as.double(Z),

--- transport parameters ---

TEL    = as.double(TEL),Dm     = as.double(Dm),ALFAL  = as.double(ALFAL),ALFATV = as.double(ALFATV),ALFATH = as.double(ALFATH),GAMA   = as.double(GAMA),Rd     = as.double(Rd),POR    = as.double(POR),D3D    = as.double(D3D),TETA   = as.double(TETA),

NAOK   = TRUE   # suppress R's own NA / NaN check for speed)

cat("FLTR completed successfully.\n")

---------------------------------------------------------------

9.  EXTRACT & RESHAPE THE OUTPUT ARRAYS

---------------------------------------------------------------

.Fortran returns flat vectors – reshape back to 3-D arrays

H3D_out <- array(Result$H3D, dim = c(mx, mx, mx))C3D_out <- array(Result$C3D, dim = c(mx, mx, mx))

---------------------------------------------------------------

10. QUICK DIAGNOSTIC SUMMARY

---------------------------------------------------------------

cat("\n--- Hydraulic Head (H3D) summary ---\n")cat("  Min  :", min(H3D_out[1, 1, 1]), "\n")cat("  Max  :", max(H3D_out[1, 1, 1]), "\n")cat("  Mean :", mean(H3D_out[1, 1, 1]), "\n")

cat("\n--- Concentration (C3D) summary ---\n")cat("  Min  :", min(C3D_out[1, 1, 1]), "\n")cat("  Max  :", max(C3D_out[1, 1, 1]), "\n")cat("  Mean :", mean(C3D_out[1, 1, 1]), "\n")

---------------------------------------------------------------

11. OPTIONAL  – 2-D SLICE PLOT

---------------------------------------------------------------

if (requireNamespace("fields", quietly = TRUE)) {fields::image.plot(H3D_out[1, 1, 1],main = "Hydraulic Head – Layer 1 [m]",xlab = "Column", ylab = "Row")} else {image(H3D_out[1, 1, 1],main = "Hydraulic Head – Layer 1 [m]",xlab = "Column", ylab = "Row")}

---------------------------------------------------------------

12. UNLOAD LIBRARY WHEN DONE  (optional but clean)

---------------------------------------------------------------

dyn.unload(lib_path)
