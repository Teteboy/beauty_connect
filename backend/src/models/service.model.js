module.exports = (sequelize, DataTypes) => {
  const Service = sequelize.define('Service', {
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
    durationMinutes: {  // Changed from 'duration' to match frontend
      type: DataTypes.INTEGER,
      allowNull: false
    },
    category: {
      type: DataTypes.STRING,
      allowNull: false
    },
    imageUrl: {  // Changed from 'image' to match frontend
      type: DataTypes.STRING
    },
    isAvailable: {  // Added to match frontend
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    technicianId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      }
    }
  });

  Service.associate = (models) => {
    Service.belongsTo(models.User, {
      foreignKey: 'technicianId',
      as: 'technician'
    });
    
    Service.hasMany(models.Booking, {
      foreignKey: 'serviceId',
      as: 'bookings'
    });
    
    Service.hasMany(models.ServiceImage, {
      foreignKey: 'serviceId',
      as: 'images'
    });
  };

  return Service;
};









