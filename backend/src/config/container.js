const supabase = require('./supabase');

// ─── To switch from Supabase to an external HTTP API ──────────────────────────
// 1. Uncomment the MyApi block below and comment out the Supabase lines.
// 2. Add MYAPI_BASE_URL and MYAPI_KEY to .env.
//
// const HttpClient = require('../infrastructure/myapi/HttpClient');
// const MyApiAuthRepository          = require('../infrastructure/myapi/MyApiAuthRepository');
// const MyApiRoutesRepository        = require('../infrastructure/myapi/MyApiRoutesRepository');
// const MyApiTripsRepository         = require('../infrastructure/myapi/MyApiTripsRepository');
// const MyApiGpsPointsRepository     = require('../infrastructure/myapi/MyApiGpsPointsRepository');
// const MyApiNotificationsRepository = require('../infrastructure/myapi/MyApiNotificationsRepository');
// const MyApiStatsRepository         = require('../infrastructure/myapi/MyApiStatsRepository');
//
// const http = new HttpClient(process.env.MYAPI_BASE_URL, process.env.MYAPI_KEY);
// const authRepository          = new MyApiAuthRepository(http);
// const routesRepository        = new MyApiRoutesRepository(http);
// const tripsRepository         = new MyApiTripsRepository(http);
// const gpsPointsRepository     = new MyApiGpsPointsRepository(http);
// const notificationsRepository = new MyApiNotificationsRepository(http);
// const statsRepository         = new MyApiStatsRepository(http);
// ──────────────────────────────────────────────────────────────────────────────

// Infrastructure
const SupabaseAuthRepository = require('../infrastructure/supabase/SupabaseAuthRepository');
const SupabaseRoutesRepository = require('../infrastructure/supabase/SupabaseRoutesRepository');
const SupabaseTripsRepository = require('../infrastructure/supabase/SupabaseTripsRepository');
const SupabaseGpsPointsRepository = require('../infrastructure/supabase/SupabaseGpsPointsRepository');
const SupabaseNotificationsRepository = require('../infrastructure/supabase/SupabaseNotificationsRepository');
const SupabaseStatsRepository = require('../infrastructure/supabase/SupabaseStatsRepository');

// Use cases — auth
const LoginUseCase = require('../domain/usecases/auth/LoginUseCase');
const LogoutUseCase = require('../domain/usecases/auth/LogoutUseCase');
const RefreshTokenUseCase = require('../domain/usecases/auth/RefreshTokenUseCase');

// Use cases — routes
const GetTodayRoutesUseCase = require('../domain/usecases/routes/GetTodayRoutesUseCase');
const GetRouteByIdUseCase = require('../domain/usecases/routes/GetRouteByIdUseCase');
const UpdateRouteStatusUseCase = require('../domain/usecases/routes/UpdateRouteStatusUseCase');

// Use cases — trips
const StartTripUseCase = require('../domain/usecases/trips/StartTripUseCase');
const EndTripUseCase = require('../domain/usecases/trips/EndTripUseCase');
const GetTripHistoryUseCase = require('../domain/usecases/trips/GetTripHistoryUseCase');
const GetTripByIdUseCase = require('../domain/usecases/trips/GetTripByIdUseCase');
const PauseTripUseCase = require('../domain/usecases/trips/PauseTripUseCase');
const ResumeTripUseCase = require('../domain/usecases/trips/ResumeTripUseCase');

// Use cases — gps points
const BatchUploadGpsPointsUseCase = require('../domain/usecases/gpsPoints/BatchUploadGpsPointsUseCase');

// Use cases — notifications
const GetNotificationsUseCase = require('../domain/usecases/notifications/GetNotificationsUseCase');
const MarkAllNotificationsReadUseCase = require('../domain/usecases/notifications/MarkAllNotificationsReadUseCase');

// Use cases — stats
const GetDriverStatsUseCase = require('../domain/usecases/stats/GetDriverStatsUseCase');

// Controllers
const AuthController = require('../presentation/controllers/AuthController');
const RoutesController = require('../presentation/controllers/RoutesController');
const TripsController = require('../presentation/controllers/TripsController');
const GpsPointsController = require('../presentation/controllers/GpsPointsController');
const NotificationsController = require('../presentation/controllers/NotificationsController');
const StatsController = require('../presentation/controllers/StatsController');

// --- Repositories ---
const authRepository = new SupabaseAuthRepository(supabase);
const routesRepository = new SupabaseRoutesRepository(supabase);
const tripsRepository = new SupabaseTripsRepository(supabase);
const gpsPointsRepository = new SupabaseGpsPointsRepository(supabase);
const notificationsRepository = new SupabaseNotificationsRepository(supabase);
const statsRepository = new SupabaseStatsRepository(supabase);

// --- Use cases ---
const loginUseCase = new LoginUseCase(authRepository);
const logoutUseCase = new LogoutUseCase(authRepository);
const refreshTokenUseCase = new RefreshTokenUseCase(authRepository);

const getTodayRoutesUseCase = new GetTodayRoutesUseCase(routesRepository);
const getRouteByIdUseCase = new GetRouteByIdUseCase(routesRepository);
const updateRouteStatusUseCase = new UpdateRouteStatusUseCase(routesRepository);

const startTripUseCase = new StartTripUseCase(tripsRepository, routesRepository);
const endTripUseCase = new EndTripUseCase(tripsRepository, routesRepository);
const getTripHistoryUseCase = new GetTripHistoryUseCase(tripsRepository);
const getTripByIdUseCase = new GetTripByIdUseCase(tripsRepository);
const pauseTripUseCase = new PauseTripUseCase(tripsRepository);
const resumeTripUseCase = new ResumeTripUseCase(tripsRepository);

const batchUploadGpsPointsUseCase = new BatchUploadGpsPointsUseCase(gpsPointsRepository);

const getNotificationsUseCase = new GetNotificationsUseCase(notificationsRepository);
const markAllNotificationsReadUseCase = new MarkAllNotificationsReadUseCase(notificationsRepository);

const getDriverStatsUseCase = new GetDriverStatsUseCase(statsRepository);

// --- Controllers ---
const authController = new AuthController(loginUseCase, logoutUseCase, refreshTokenUseCase);

const routesController = new RoutesController(
  getTodayRoutesUseCase,
  getRouteByIdUseCase,
  updateRouteStatusUseCase
);

const tripsController = new TripsController(
  startTripUseCase,
  endTripUseCase,
  getTripHistoryUseCase,
  getTripByIdUseCase,
  pauseTripUseCase,
  resumeTripUseCase
);

const gpsPointsController = new GpsPointsController(batchUploadGpsPointsUseCase);

const notificationsController = new NotificationsController(
  getNotificationsUseCase,
  markAllNotificationsReadUseCase
);

const statsController = new StatsController(getDriverStatsUseCase);

module.exports = {
  authController,
  routesController,
  tripsController,
  gpsPointsController,
  notificationsController,
  statsController,
};
