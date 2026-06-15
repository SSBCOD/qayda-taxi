/// Shared ride core: the RideStatus state machine + repository wiring that
/// drives BOTH passenger and driver ride screens reactively.
///
///   data/        -> ride_repository impl + sources (Firestore/mock)
///   application/ -> ride_controller, ride_state, providers
library;
