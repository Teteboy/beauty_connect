module.exports = (sequelize, DataTypes) => {
  const Subscription = sequelize.define('Subscription', {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
    userId: { type: DataTypes.INTEGER, allowNull: false, references: { model: 'Users', key: 'id' } },
    plan: { type: DataTypes.STRING, allowNull: false }, // basic | pro | premium
    status: { type: DataTypes.ENUM('active', 'cancelled', 'expired'), defaultValue: 'active' },
    price: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
    startedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    expiresAt: { type: DataTypes.DATE, allowNull: true },
  });

  Subscription.associate = (models) => {
    Subscription.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
  };
  return Subscription;
};
