# BeautyConnect Backend API

This is the backend API for the BeautyConnect application, a platform that connects beauty professionals with customers.

## Technologies Used

- Node.js
- Express.js
- PostgreSQL
- Sequelize ORM
- JWT Authentication

## Getting Started

### Prerequisites

- Node.js (v14 or higher)
- PostgreSQL (v12 or higher)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/beautyconnect.git
cd beautyconnect/backend
```

2. Install dependencies
```bash
npm install
```

3. Create a `.env` file in the root directory and add the following environment variables:
```
PORT=5000
NODE_ENV=development

# Database configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=beautyconnect
DB_USER=postgres
DB_PASSWORD=your_password

# JWT configuration
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=1d
```

4. Create the database
```bash
createdb beautyconnect
```

5. Start the server
```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

The API will be available at `http://localhost:5000`

## API Documentation

### Authentication

- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login a user
- `GET /api/auth/profile` - Get current user profile
- `PUT /api/auth/profile` - Update user profile

### Services

- `GET /api/services` - Get all services
- `GET /api/services/:id` - Get service by ID
- `POST /api/services` - Create a new service (technicians only)
- `PUT /api/services/:id` - Update a service (owner or admin only)
- `DELETE /api/services/:id` - Delete a service (owner or admin only)

### Bookings

- `GET /api/bookings` - Get all bookings (filtered by user role)
- `GET /api/bookings/:id` - Get booking by ID
- `POST /api/bookings` - Create a new booking (customers only)
- `PUT /api/bookings/:id/status` - Update booking status
- `PUT /api/bookings/:id` - Update booking details
- `DELETE /api/bookings/:id` - Delete a booking (pending only)
- `GET /api/bookings/customer/:customerId` - Get customer bookings
- `GET /api/bookings/technician/:technicianId` - Get technician bookings

### Reviews

- `GET /api/reviews` - Get all reviews
- `GET /api/reviews/:id` - Get review by ID
- `POST /api/reviews` - Create a new review (customers only, for completed bookings)
- `PUT /api/reviews/:id` - Update a review (owner only)
- `DELETE /api/reviews/:id` - Delete a review (owner or admin only)
- `GET /api/reviews/technician/:technicianId` - Get technician reviews

## License

This project is licensed under the MIT License.