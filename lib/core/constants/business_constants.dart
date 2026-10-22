/// Business-model constants for BeautyConnect.
///
/// See BUSINESS_MODEL.md for the full fee and settlement policy.
library;

/// Flat reservation fee (in XAF) charged per booking and held in escrow
/// until the booking reaches a terminal state.
const int kBookingFeeXaf = 500;

/// Provider's share of the booking fee on a completed booking (50%).
const double kProviderFeeShare = 0.5;

/// Platform's share of the booking fee on a completed booking (50%).
const double kPlatformFeeShare = 0.5;
