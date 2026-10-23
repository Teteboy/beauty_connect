module.exports = (sequelize, DataTypes) => {
  const Verification = sequelize.define('Verification', {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
    userId: { type: DataTypes.INTEGER, allowNull: false, references: { model: 'Users', key: 'id' }, unique: true },
    documents: { type: DataTypes.JSON, defaultValue: [] }, // urls de justificatifs
    status: { type: DataTypes.ENUM('none', 'pending', 'approved', 'rejected'), defaultValue: 'pending' },
    notes: { type: DataTypes.TEXT, allowNull: true },
    reviewedById: { type: DataTypes.INTEGER, allowNull: true },
    reviewedAt: { type: DataTypes.DATE, allowNull: true },
  });

  Verification.associate = (models) => {
    Verification.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
  };
  return Verification;
};
