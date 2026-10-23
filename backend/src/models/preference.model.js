module.exports = (sequelize, DataTypes) => {
  const Preference = sequelize.define('Preference', {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
    userId: { type: DataTypes.INTEGER, allowNull: false, references: { model: 'Users', key: 'id' }, unique: true },
    whatsappNumber: { type: DataTypes.STRING, allowNull: true },
    whatsappConsent: { type: DataTypes.BOOLEAN, defaultValue: false },
    whatsappUpdates: { type: DataTypes.BOOLEAN, defaultValue: true },
    whatsappReminders: { type: DataTypes.BOOLEAN, defaultValue: true },
    marketingConsent: { type: DataTypes.BOOLEAN, defaultValue: false },
  });

  Preference.associate = (models) => {
    Preference.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
  };
  return Preference;
};
