---

# 🛠 Bug Fixes Documentation – Scheduling App (v1.3.0)

## Overview

This document outlines the major bugs that were discovered and resolved in the Scheduling App.

---

## Critical Fixes Implemented

### 1. Timezone Display Errors in Appointments

**File**:
`src/utils/dateFormatter.ts`
**Severity**: Critical
**Status**: ✅ Fixed

#### Problem

Appointment times displayed inconsistently across users in different timezones. A booking at 4:00 PM EST appeared as 1:00 PM PST, leading to:

* Missed meetings
* Confusion in customer support
* Frustration and loss of trust

#### Root Cause

Timestamps were rendered using `new Date().toLocaleString()` without setting a consistent server-side timezone.

#### Fix

Replaced local formatting with a UTC-standardized formatter:

```typescript
import { format, utcToZonedTime } from 'date-fns-tz';

const zonedTime = utcToZonedTime(appointmentTimeUTC, userTimeZone);
const displayTime = format(zonedTime, 'hh:mm a zzz');
```

#### Impact

* ✅ Accurate appointment display in all user timezones
* ✅ Fewer missed appointments
* ✅ Time consistency across platforms

---

### 2. Duplicate Bookings on Retry

**File**:
`src/hooks/useBookAppointment.ts`
**Severity**: High
**Status**: ✅ Fixed

#### Problem

Users experiencing network issues and retrying caused **duplicate bookings**, which cluttered the database and overbooked slots.

#### Root Cause

No idempotency token was implemented to recognize retries of the same booking.

#### Fix

Introduced a unique `x-request-id` header for each booking attempt and handled deduplication server-side.

**Frontend:**

```typescript
import { v4 as uuidv4 } from 'uuid';

axios.post('/api/book', payload, {
  headers: { 'x-request-id': uuidv4() }
});
```

**Backend:**

```typescript
if (hasAlreadyProcessed(requestId)) return;
```

---

Let me know if this doc will be converted to PDF, HTML, or internal wiki format – there are optimizations depending on the end destination.
