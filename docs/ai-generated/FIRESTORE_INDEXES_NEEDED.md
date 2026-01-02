# Firestore Indexes Required

## Overview

The app is running successfully, but some queries require Firestore indexes to be created. These indexes improve query performance and enable complex queries.

## Required Indexes

### 1. Provider Requests Index
**Purpose:** Allow providers to query requests by userId and sort by updatedAt

**Create Index:**
Click this link to create automatically:
```
https://console.firebase.google.com/v1/r/project/fuelmate-73aaf/firestore/indexes?create_composite=ClVwcm9qZWN0cy9mdWVsbWF0ZS03M2FhZi9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvcGV0cm9sUmVxdWVzdHMvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDQoJdXBkYXRlZEF0EAIaDAoIX19uYW1lX18QAg
```

**Manual Creation:**
- Collection: `petrolRequests`
- Fields:
  - `userId` (Ascending)
  - `updatedAt` (Descending)
  - `__name__` (Descending)

### 2. Unread Messages Index
**Purpose:** Track unread messages for notification badges

**Create Index:**
Click this link to create automatically:
```
https://console.firebase.google.com/v1/r/project/fuelmate-73aaf/firestore/indexes?create_composite=Ck9wcm9qZWN0cy9mdWVsbWF0ZS03M2FhZi9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvbWVzc2FnZXMvaW5kZXhlcy9fEAEaCAoEcmVhZBABGgwKCHNlbmRlcklkEAEaDAoIX19uYW1lX18QAQ
```

**Manual Creation:**
- Collection Group: `messages`
- Fields:
  - `isRead` (Ascending) - Note: The error says "read" but the field is "isRead"
  - `senderId` (Ascending)
  - `__name__` (Ascending)

## How to Create Indexes

### Option 1: Click the Links (Easiest)
1. Click on the URL provided in the error message or above
2. Sign in to Firebase Console
3. Click "Create Index"
4. Wait 2-5 minutes for index to build

### Option 2: Manual Creation
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `fuelmate-73aaf`
3. Navigate to **Firestore Database** → **Indexes**
4. Click **Create Index** or **Create Composite Index**
5. Enter the collection and fields as specified above
6. Click **Create**

## Impact

**Without these indexes:**
- ⚠️ Provider location queries may fail
- ⚠️ Unread message count won't display
- ⚠️ Message read status tracking won't work

**With these indexes:**
- ✅ All queries work efficiently
- ✅ Unread message badges display correctly
- ✅ Provider can see nearby requests
- ✅ Better app performance

## Verification

After creating indexes:
1. Wait 2-5 minutes for indexes to build
2. Restart the app
3. Check that warnings disappear from logs
4. Verify unread message counts appear

## Current Status

**Working Features:**
- ✅ Notification service initialized
- ✅ Sound/bell notifications
- ✅ Real-time request updates
- ✅ Quote notifications
- ✅ Chat messaging
- ✅ Request creation

**Needs Index to Work:**
- ⚠️ Provider nearby requests query
- ⚠️ Unread message count badges
- ⚠️ Mark messages as read functionality

## Quick Links

**Firestore Console:**
https://console.firebase.google.com/project/fuelmate-73aaf/firestore

**Create Provider Requests Index:**
https://console.firebase.google.com/v1/r/project/fuelmate-73aaf/firestore/indexes?create_composite=ClVwcm9qZWN0cy9mdWVsbWF0ZS03M2FhZi9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvcGV0cm9sUmVxdWVzdHMvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDQoJdXBkYXRlZEF0EAIaDAoIX19uYW1lX18QAg

**Create Unread Messages Index:**
https://console.firebase.google.com/v1/r/project/fuelmate-73aaf/firestore/indexes?create_composite=Ck9wcm9qZWN0cy9mdWVsbWF0ZS03M2FhZi9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvbWVzc2FnZXMvaW5kZXhlcy9fEAEaCAoEcmVhZBABGgwKCHNlbmRlcklkEAEaDAoIX19uYW1lX18QAQ

---

**Note:** These indexes are automatically suggested by Firestore when you run queries that require them. The links above will take you directly to the index creation page with the correct configuration pre-filled.

