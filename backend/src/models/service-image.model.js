'use strict';

module.exports = (sequelize, DataTypes) => {
  const ServiceImage = sequelize.define('ServiceImage', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
      allowNull: false
    },
    serviceId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'Services',
        key: 'id'
      }
    },
    imageUrl: {
      type: DataTypes.STRING,
      allowNull: false
    },
    caption: {
      type: DataTypes.STRING,
      allowNull: true
    }
  }, {
    tableName: 'ServiceImages',
    timestamps: true
  });

  ServiceImage.associate = (models) => {
    ServiceImage.belongsTo(models.Service, {
      foreignKey: 'serviceId',
      as: 'service'
    });
  };

  return ServiceImage;
};



