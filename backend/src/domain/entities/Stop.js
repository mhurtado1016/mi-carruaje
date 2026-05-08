class Stop {
  constructor({ id, route_id, order, address, latitude, longitude, status }) {
    this.id = id;
    this.route_id = route_id;
    this.order = order;
    this.address = address;
    this.latitude = latitude;
    this.longitude = longitude;
    this.status = status;
  }
}

module.exports = Stop;
