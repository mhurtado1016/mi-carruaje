require('dotenv').config();
const bcrypt = require('bcryptjs');
const supabase = require('./src/config/supabase');

async function setup() {
  console.log('RouteTrack Setup — connecting to Supabase...');

  const passwordHash = await bcrypt.hash('routetrack123', 10);

  // Upsert demo drivers
  const { error: driverError } = await supabase.from('drivers').upsert(
    [
      {
        id: 'EMP-00482',
        name: 'Carlos Martínez',
        email: 'carlos.martinez@efrata.com',
        password_hash: passwordHash,
        zone: 'Zona Norte',
        shift: 'day',
        status: 'active',
      },
      {
        id: 'EMP-00123',
        name: 'Ana Torres',
        email: 'ana.torres@efrata.com',
        password_hash: passwordHash,
        zone: 'Zona Sur',
        shift: 'day',
        status: 'active',
      },
    ],
    { onConflict: 'id' }
  );

  if (driverError) {
    console.error('Error upserting drivers:', driverError.message);
    process.exit(1);
  }
  console.log('Drivers ready.');

  // Build today's date at specific hours
  const todayAt = (hours, minutes = 0) => {
    const d = new Date();
    d.setHours(hours, minutes, 0, 0);
    return d.toISOString();
  };

  // Check if routes already exist for today for EMP-00482
  const startOfDay = new Date();
  startOfDay.setHours(0, 0, 0, 0);
  const endOfDay = new Date();
  endOfDay.setHours(23, 59, 59, 999);

  const { data: existingRoutes } = await supabase
    .from('routes')
    .select('id')
    .eq('driver_id', 'EMP-00482')
    .gte('scheduled_start', startOfDay.toISOString())
    .lte('scheduled_start', endOfDay.toISOString());

  if (existingRoutes && existingRoutes.length > 0) {
    console.log('Routes for today already exist — skipping route/stop creation.');
  } else {
    // Insert Route 1
    const { data: route1, error: r1Error } = await supabase
      .from('routes')
      .insert({
        name: 'Ruta Norte — A',
        driver_id: 'EMP-00482',
        scheduled_start: todayAt(9),
        status: 'pending',
        total_stops: 4,
        estimated_km: 18.0,
        estimated_duration_minutes: 90,
      })
      .select()
      .single();

    if (r1Error) {
      console.error('Error creating route 1:', r1Error.message);
      process.exit(1);
    }

    await supabase.from('stops').insert([
      { route_id: route1.id, order: 1, name: 'Supermercado Central',  address: 'Calle 80 #45-32, Bogotá',     latitude: 4.6782, longitude: -74.0530, status: 'pending' },
      { route_id: route1.id, order: 2, name: 'Panadería La Esperanza', address: 'Carrera 15 #72-18, Bogotá',   latitude: 4.6651, longitude: -74.0558, status: 'pending' },
      { route_id: route1.id, order: 3, name: 'Farmacia San Rafael',    address: 'Avenida 68 #33-21, Bogotá',  latitude: 4.6572, longitude: -74.0799, status: 'pending' },
      { route_id: route1.id, order: 4, name: 'Droguería El Progreso',  address: 'Calle 53 #24-10, Bogotá',    latitude: 4.6493, longitude: -74.0643, status: 'pending' },
    ]);

    // Insert Route 2
    const { data: route2, error: r2Error } = await supabase
      .from('routes')
      .insert({
        name: 'Ruta Centro — B',
        driver_id: 'EMP-00482',
        scheduled_start: todayAt(14),
        status: 'pending',
        total_stops: 3,
        estimated_km: 12.0,
        estimated_duration_minutes: 60,
      })
      .select()
      .single();

    if (r2Error) {
      console.error('Error creating route 2:', r2Error.message);
      process.exit(1);
    }

    await supabase.from('stops').insert([
      { route_id: route2.id, order: 1, name: 'Tienda El Vecino',      address: 'Carrera 7 #12-55, Bogotá',  latitude: 4.6011, longitude: -74.0672, status: 'pending' },
      { route_id: route2.id, order: 2, name: 'Miscelánea Don Pedro',  address: 'Calle 19 #6-40, Bogotá',    latitude: 4.6063, longitude: -74.0694, status: 'pending' },
      { route_id: route2.id, order: 3, name: 'Almacén La Rebaja',     address: 'Carrera 10 #22-18, Bogotá', latitude: 4.6117, longitude: -74.0735, status: 'pending' },
    ]);

    console.log('Routes and stops created.');
  }

  // Check if notifications already exist
  const { data: existingNotifs } = await supabase
    .from('notifications')
    .select('id')
    .eq('driver_id', 'EMP-00482');

  if (existingNotifs && existingNotifs.length > 0) {
    console.log('Notifications already exist — skipping.');
  } else {
    await supabase.from('notifications').insert([
      {
        driver_id: 'EMP-00482',
        title: 'Nueva ruta asignada',
        body: 'Se te ha asignado la ruta "Ruta Norte — A" para hoy a las 09:00.',
        type: 'route_assigned',
        read: false,
      },
      {
        driver_id: 'EMP-00482',
        title: 'Recordatorio de turno',
        body: 'Tu turno comienza en 30 minutos. Verifica el estado de tu vehículo.',
        type: 'reminder',
        read: false,
      },
      {
        driver_id: 'EMP-00482',
        title: 'Ruta completada ayer',
        body: 'Completaste la Ruta Sur — C con 5/5 paradas. ¡Buen trabajo!',
        type: 'trip_completed',
        read: true,
      },
    ]);
    console.log('Notifications created.');
  }

  console.log('\nSetup complete! Login: EMP-00482 / routetrack123');
}

setup().catch((err) => {
  console.error('Setup failed:', err.message);
  process.exit(1);
});
