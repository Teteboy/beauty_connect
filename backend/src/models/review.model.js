module.exports = (sequelize, DataTypes) => {
  const Review = sequelize.define('Review', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    bookingId: {
      type: DataTypes.UUID,  // Changed from INTEGER to UUID to match Booking's id
      allowNull: false,
      unique: true,
      references: {
        model: 'Bookings',
        key: 'id'
      }
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
    rating: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 5
      }
    },
    comment: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    timestamps: true
  });

  Review.associate = (models) => {
    Review.belongsTo(models.Booking, {
      foreignKey: 'bookingId',
      as: 'booking'
    });
    
    Review.belongsTo(models.User, {
      foreignKey: 'customerId',
      as: 'customer'
    });
    
    Review.belongsTo(models.User, {
      foreignKey: 'technicianId',
      as: 'technician'
    });
  };

  return Review;
};

