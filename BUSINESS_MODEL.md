# BeautyConnect — Business Model Proposal

## 1. Executive summary

BeautyConnect monetises the **booking moment**, not the service price. Every
booking carries a flat, non-refundable-in-principle **reservation fee of
500 XAF**, paid by the customer when the booking is placed. The fee is held
in escrow by the platform until the booking reaches a terminal state, then
settled according to the rules below.

This model was chosen for the Cameroonian market (XAF) because:

- A **flat fee** is easy to understand at any service price point
  (a 2,000 XAF braid touch-up and a 25,000 XAF full glam pay the same fee).
- It directly attacks the marketplace's two biggest problems:
  **customer no-shows** and **technician flakiness**.
- It generates revenue on every booking *attempt*, not only completed ones.
- It requires no price negotiation with technicians — the fee is a
  platform charge layered on top of, or carved out of, the service price.

---

## 2. The 500 XAF escrow booking fee

### 2.1 Flow

```
Customer books  →  500 XAF charged to escrow  →  technician confirms
                                                    │
              ┌─────────────────────────────────────┼──────────────┐
              │                                     │              │
        COMPLETED /                          CANCELLED /        NO-SHOW
        CONFIRMED+DELIVERED                    (by provider)   (customer)
              │                                     │              │
   Provider: 250 XAF (50%)               Provider: 0 XAF    Provider: 250 XAF
   Platform: 250 XAF (50%)               Platform: 500 XAF  Platform: 250 XAF
                                                           (see §3.2)
```

### 2.2 Settlement rules

| Terminal state          | Provider | Platform | Customer |
|-------------------------|----------|----------|----------|
| Booking completed       | 250 XAF  | 250 XAF  | —        |
| Customer cancels late   | 250 XAF* | 250 XAF  | loses fee |
| Customer no-show        | 250 XAF  | 250 XAF  | loses fee |
| Provider cancels        | 0 XAF    | 500 XAF  | fee forfeited |
| Booking rejected/expires| 0 XAF    | 0 XAF    | **full refund** |

\* see §3 — the late-cancel rule is the recommended softening of the
current "platform keeps 100%" policy.

### 2.3 Is the fee part of the service price?

Recommended framing: **the 500 XAF is included in the displayed price** —
the customer sees one number, and the fee is carved out on settlement. This
keeps price presentation clean ("Classic Braids — 5,000 XAF" means 5,000
total, of which 500 was the reservation component). The technician's
payout is then `servicePrice − 500 + theirShare(250)` for a completed
booking.

---

## 3. Honest assessment of the proposed rules

### 3.1 What works

- **Anti-no-show incentive is real.** Losing 500 XAF is enough friction to
  make customers treat bookings seriously, without being punitive.
- **Provider skin-in-the-game.** Providers earn 250 XAF even on a
  no-show — they are compensated for reserved time.
- **Simple mental model.** Flat fees are easy to market and easy to
  explain in-app.

### 3.2 Concerns and recommended adjustments

**Concern A — "Platform keeps 100% on cancel" is aggressive and asymmetric.**

If the *customer* cancels and the platform keeps the whole 500, customers
will resent the platform. If the *provider* cancels, the customer also
loses the fee — punishing the wrong party and creating a trust problem
that will suppress bookings (the thing the fee exists to protect).

Recommended split on customer-side cancellation:

| Cancellation timing        | Recommended outcome |
|----------------------------|---------------------|
| > 24 h before appointment  | Full refund to customer (builds trust, fee still deters spam) |
| < 24 h / no-show           | Provider 250 / Platform 250 (provider compensated for held slot) |
| Provider cancels / rejects | Full refund to customer + provider "reliability score" penalty |

This keeps the anti-flake incentive but removes the "platform profits
when things go wrong" optics.

**Concern B — 250 XAF to the provider is small.**

On a 5,000 XAF service, the provider's upside from the fee is 5%. That is
a meaningful no-show compensation but not a strong incentive to prefer
the platform. This is acceptable *because* the fee's real job is
commitment-signalling, not provider revenue — but it should be marketed
to providers as "you always get paid for your time", not as earnings.

**Concern C — Regulatory/compliance.**

Escrow-style fund holding in Cameroon/CEMAC typically requires either a
licensed payment-service provider or a partnership with a mobile-money
operator. **Do not hold funds directly** — route the escrow through the
payment provider's dedicated escrow/hold feature (see §5) so the money
never legally sits on BeautyConnect's balance sheet.

---

## 4. Revenue model & unit economics

### 4.1 Per-booking revenue to platform

| Outcome                       | Platform earns |
|-------------------------------|----------------|
| Completed booking             | 250 XAF        |
| Late cancel / no-show         | 250 XAF        |
| Provider cancel (recommended) | 0 XAF (refund) |
| Early cancel (recommended)    | 0 XAF (refund) |

Expected platform take per booking attempt: **~200–250 XAF**
(assuming ~85% completion, ~10% late-cancel/no-show, ~5% refunded).

### 4.2 Scale scenarios (per month)

| Monthly bookings | Platform fee revenue | Note |
|------------------|----------------------|------|
| 500              | ~125,000 XAF         | Validation phase, one city |
| 2,000            | ~500,000 XAF         | Douala + Yaoundé |
| 10,000           | ~2,500,000 XAF       | National scale |

### 4.3 Secondary revenue streams (phase 2+)

1. **Featured placement** — technicians pay for "Top Artist" slots in
   search/home (clearly labelled *Sponsored*).
2. **Premium technician subscription** (e.g. 4,900 XAF/mo): portfolio
   boosts, analytics, priority support, lower payout delay.
3. **Product margin** — recommended products, starter kits, supplies
   (affiliate or direct) attached to service categories.
4. **Cancellation-insurance upsell** — customer pays +200 XAF to make
   their reservation fee refundable anytime (price of flexibility).

---

## 5. Payments & technical implementation

### 5.1 Rail

Cameroon runs on **MTN Mobile Money** and **Orange Money**. Integrate via
an aggregator rather than integrating each operator directly:

- **Fapshi** or **CinetPay** (Cameroon-focused, escrow-capable, low fees)
- or direct operator APIs once volume justifies it.

Required capabilities: pay-in, hold/escrow, split settlement or
two-leg payout, refund, webhook notifications.

### 5.2 Data model additions (already partially scaffolded)

```text
bookings
  + bookingFeeXaf       INTEGER  DEFAULT 500
  + feeStatus           ENUM('unpaid','held','settled','refunded','forfeited')
  + feePaidAt           TIMESTAMP
  + settlementId        UUID

payments  (new table)
  + id, bookingId, provider, providerRef,
    amountXaf, kind('fee'), status, rawCallback JSON

payouts   (new table)
  + id, bookingId, technicianId, amountXaf,
    status('pending','paid','failed'), providerRef
```

### 5.3 Endpoint surface (backend, to implement)

```
POST   /api/payments/booking-fee/initiate     -> creates pending payment,
                                               returns mobile-money prompt ref
POST   /api/payments/callback               -> operator webhook,
                                               confirms fee into escrow
POST   /api/bookings/:id/confirm            -> settles escrow
                                               (250/250 split)
POST   /api/bookings/:id/cancel             -> refund or forfeit per
                                               policy table §3.2
GET    /api/technicians/me/payouts          -> technician earnings ledger
```

### 5.4 Frontend touchpoints

- Service detail / booking sheet: show **"Booking fee 500 XAF — held
  securely, refundable per policy"** line under the price.
- My Bookings: fee status chip (`Held`, `Settled`, `Refunded`).
- Technician dashboard: *Earnings* card already in the Figma design —
  wire it to `GET /api/technicians/me/payouts`.
- Cancel flow: explain the refund outcome before confirming.

### 5.5 Trust mechanics to build

- **Reliability scores** on both sides (provider cancel rate shown
  internally; customer no-show count).
- Dispute window: 24 h after appointment to contest a "completed" flag.
- Payout cadence: weekly batch to technician mobile-money wallets.

---

## 6. Go-to-market fit for this model

- Lead with **"Pay 500 to secure your slot"** — it's small enough to be
  an impulse commitment, large enough to be a real one.
- To providers: **"Get paid even when clients don't show."**
- Do not charge the fee for the first booking of new customers during
  launch (acquisition subsidy) — measure conversion lift vs. fee revenue
  cost before extending it.

---

## 7. Open questions for you

1. Should the 500 XAF be **on top of** the displayed service price
   (cleaner fee story, higher checkout sticker) or **inside** it
   (cleaner price, smaller provider payout)?
2. Provider-cancel policy: refund the customer in full and penalise the
   provider's ranking, or partial refund?
3. Minimum viable rail: **Fapshi/CinetPay aggregator** vs direct MTN
   MoMo API — do you already hold a merchant account with either?
4. Payout timing: instant split at confirmation vs weekly batch
   (weekly is far cheaper in transaction fees).
