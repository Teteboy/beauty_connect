module.exports = (sequelize, DataTypes) => {
  const Booking = sequelize.define('Booking', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    customerId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    technicianId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    serviceId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'Services',
        key: 'id'
      }
    },
    dateTime: {
      type: DataTypes.DATE,
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM('pending', 'confirmed', 'completed', 'cancelled'),
      defaultValue: 'pending'
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    }
  }, {
    timestamps: true
  });

  Booking.associate = function(models) {
    // Booking belongs to a User (customer)
    Booking.belongsTo(models.User, {
      as: 'customer',
      foreignKey: 'customerId'
    });
    
    // Booking belongs to a User (technician)
    Booking.belongsTo(models.User, {
      as: 'technician',
      foreignKey: 'technicianId'
    });
    
    // Booking belongs to a Service
    Booking.belongsTo(models.Service, {
      as: 'service',
      foreignKey: 'serviceId'
    });

    // Booking has one Review
    Booking.hasOne(models.Review, {
      foreignKey: 'bookingId',
      as: 'review'
    });
  };

  return Booking;
};



