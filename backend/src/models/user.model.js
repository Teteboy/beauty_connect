const bcrypt = require('bcryptjs');

module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    firstName: {
      type: DataTypes.STRING,
      allowNull: false
    },
    lastName: {
      type: DataTypes.STRING,
      allowNull: false
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    phone: {
      type: DataTypes.STRING,
      allowNull: true
    },
    role: {
      type: DataTypes.ENUM('customer', 'technician', 'admin'),
      defaultValue: 'customer'
    },
    location: {
      type: DataTypes.STRING,
      allowNull: true
    },
    bio: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    profileImage: {
      type: DataTypes.STRING,
      allowNull: true
    },
    specialty: {
      type: DataTypes.STRING,
      allowNull: true
    },
    isVerified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    resetToken: {
      type: DataTypes.STRING,
      allowNull: true
    },
    resetTokenExpiry: {
      type: DataTypes.DATE,
      allowNull: true
    }
  }, {
    timestamps: true,
    hooks: {
      beforeCreate: async (user) => {
        if (user.password) {
          const salt = await bcrypt.genSalt(10);
          user.password = await bcrypt.hash(user.password, salt);
        }
      },
      beforeUpdate: async (user) => {
        if (user.changed('password')) {
          const salt = await bcrypt.genSalt(10);
          user.password = await bcrypt.hash(user.password, salt);
        }
      }
    }
  });

  User.prototype.comparePassword = async function(password) {
    return await bcrypt.compare(password, this.password);
  };

  User.associate = function(models) {
    // User has many Services (if they're a technician)
    User.hasMany(models.Service, {
      foreignKey: 'technicianId',
      as: 'services'
    });
    
    // User has many Bookings as a customer
    User.hasMany(models.Booking, {
      as: 'customerBookings',
      foreignKey: 'customerId'
    });
    
    // User has many Bookings as a technician
    User.hasMany(models.Booking, {
      as: 'technicianBookings',
      foreignKey: 'technicianId'
    });
    
    // User has many sent messages
    User.hasMany(models.Message, {
      as: 'sentMessages',
      foreignKey: 'senderId'
    });
    
    // User has many received messages
    User.hasMany(models.Message, {
      as: 'receivedMessages',
      foreignKey: 'receiverId'
    });
    
    // User has many notifications
    User.hasMany(models.Notification, {
      foreignKey: 'userId'
    });

    // User has many reviews as customer
    User.hasMany(models.Review, {
      as: 'givenReviews',
      foreignKey: 'customerId'
    });

    // User has many reviews as technician
    User.hasMany(models.Review, {
      as: 'receivedReviews',
      foreignKey: 'technicianId'
    });

    // User has one notification setting
    User.hasOne(models.NotificationSetting, {
      foreignKey: 'userId'
    });

    // User has many device tokens
    User.hasMany(models.DeviceToken, {
      foreignKey: 'userId'
    });
  };

  return User;
};











