module.exports = (sequelize, DataTypes) => {
  const Availability = sequelize.define('Availability', {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
    userId: { type: DataTypes.INTEGER, allowNull: false, references: { model: 'Users', key: 'id' } },
    dayOfWeek: { type: DataTypes.INTEGER, allowNull: false }, // 0=dimanche…6=samedi
    isEnabled: { type: DataTypes.BOOLEAN, defaultValue: true },
    slots: { type: DataTypes.JSON, defaultValue: [] }, // ex: ["09:00","10:00"]
  }, {
    indexes: [{ unique: true, fields: ['userId', 'dayOfWeek'] }]
  });

  Availability.associate = (models) => {
    Availability.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
  };
  return Availability;
};
