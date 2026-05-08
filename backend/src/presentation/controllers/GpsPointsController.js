class GpsPointsController {
  constructor(batchUploadGpsPointsUseCase) {
    this.batchUploadGpsPointsUseCase = batchUploadGpsPointsUseCase;
  }

  async batch(req, res, next) {
    try {
      const { trip_id, points } = req.body;
      const result = await this.batchUploadGpsPointsUseCase.execute(trip_id, points);
      return res.status(201).json(result);
    } catch (err) {
      if (err.message.includes('required')) {
        return res.status(400).json({ error: err.message });
      }
      next(err);
    }
  }
}

module.exports = GpsPointsController;
