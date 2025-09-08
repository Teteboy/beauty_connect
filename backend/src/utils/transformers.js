// Example of a service transformer function
exports.transformService = (service) => {
  return {
    id: service.id,
    name: service.name,
    description: service.description,
    price: parseFloat(service.price),
    durationMinutes: service.durationMinutes,  // Updated field name
    category: service.category,
    imageUrl: service.imageUrl,  // Updated field name
    isAvailable: service.isAvailable,
    technicianId: service.technicianId,
    technician: service.technician ? {
      id: service.technician.id,
      firstName: service.technician.firstName,
      lastName: service.technician.lastName,
      profileImage: service.technician.profileImage
    } : null,
    createdAt: service.createdAt,
    updatedAt: service.updatedAt
  };
};

// Example of a booking transformer function
exports.transformBooking = (booking) => {
  return {
    id: booking.id,
    customerId: booking.customerId,
    customerName: booking.customer ? `${booking.customer.firstName} ${booking.customer.lastName}` : null,
    technicianId: booking.technicianId,
    technicianName: booking.technician ? `${booking.technician.firstName} ${booking.technician.lastName}` : null,
    serviceId: booking.serviceId,
    serviceName: booking.service ? booking.service.name : null,
    dateTime: booking.dateTime,  // Updated field name
    status: booking.status,
    notes: booking.notes,
    price: booking.price ? parseFloat(booking.price) : null,
    createdAt: booking.createdAt,
    updatedAt: booking.updatedAt
  };
};

// Example of a message transformer function
exports.transformMessage = (message) => {
  return {
    id: message.id,
    senderId: message.senderId,
    receiverId: message.receiverId,  // Updated field name
    content: message.content,
    timestamp: message.timestamp,  // Added field
    isRead: message.isRead,
    sender: message.sender ? {
      id: message.sender.id,
      firstName: message.sender.firstName,
      lastName: message.sender.lastName,
      profileImage: message.sender.profileImage
    } : null,
    recipient: message.recipient ? {
      id: message.recipient.id,
      firstName: message.recipient.firstName,
      lastName: message.recipient.lastName,
      profileImage: message.recipient.profileImage
    } : null,
    createdAt: message.createdAt
  };
};