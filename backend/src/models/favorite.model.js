module.exports = (sequelize, DataTypes) => {
  const Favorite = sequelize.define('Favorite', {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
    userId: { type: DataTypes.INTEGER, allowNull: false, references: { model: 'Users', key: 'id' } },
    technicianId: { type: DataTypes.INTEGER, allowNull: false, references: { model: 'Users', key: 'id' } },
  }, {
    indexes: [{ unique: true, fields: ['userId', 'technicianId'] }]
  });

  Favorite.associate = (models) => {
    Favorite.belongsTo(models.User, { foreignKey: 'technicianId', as: 'technician' });
    Favorite.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
  };
  return Favorite;
};
