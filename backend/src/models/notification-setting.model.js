module.exports = (sequelize, DataTypes) => {
  const NotificationSetting = sequelize.define('NotificationSetting', {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      },
      unique: true
    },
    bookingNotifications: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    messageNotifications: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    reminderNotifications: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    marketingNotifications: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    }
  });

  NotificationSetting.associate = function(models) {
    NotificationSetting.belongsTo(models.User, {
      foreignKey: 'userId'
    });
  };

  return NotificationSetting;
};