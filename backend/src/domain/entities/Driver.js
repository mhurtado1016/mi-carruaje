class Driver {
  constructor({ id, name, email, zone, shift, status, avatar_url }) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.zone = zone;
    this.shift = shift;
    this.status = status;
    this.avatar_url = avatar_url;
  }
}

module.exports = Driver;
