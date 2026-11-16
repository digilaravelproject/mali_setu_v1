# Mali Setu - Push Notification & Deep Navigation Specification for Backend / API Developer

> **Document Version:** 1.0.0  
> **Target Audience:** Backend / Laravel API Developers & Mobile App Developers  
> **App:** Mali Setu (Flutter App with GetX Router)  
> **Base Domain:** `https://malisetu.com`

---

## 1. Executive Summary & Architecture Overview

Whenever a notification is triggered from the backend, the mobile user can interact with it through two channels:
1. **FCM Push Notification (System Tray)**: Arrives when the app is in the background, terminated, or foreground. Clicking on the notification in the Android/iOS status bar must immediately open the specific screen related to that event.
2. **In-App Notification Center (`GET /api/notifications`)**: The user opens the notification bell icon inside the app. Clicking any notification card must open the exact same destination screen.

### Critical Requirement for FCM:
- FCM payload consists of `notification` (title, body) and `data` (custom key-value pairs).
- **All values inside the FCM `data` object MUST BE STRINGS** (Firebase restriction: numbers or booleans directly in `data` will cause delivery or parsing failure on certain Android/iOS devices). For example: `"business_id": "42"` (not `42`).
- A standard field `"type"` (or `"notification_type"`) must ALWAYS be included in `data` so the mobile app can determine which screen to open.

---

## 2. Standard FCM Push Notification Payload Format

### FCM HTTP v1 JSON Structure:
```json
{
  "message": {
    "token": "DEVICE_FCM_REGISTRATION_TOKEN",
    "notification": {
      "title": "Title to show in phone tray",
      "body": "Body message text to show in phone tray"
    },
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "type": "EXACT_NOTIFICATION_TYPE_KEY",
      "title": "Title text (string)",
      "message": "Detailed message text (string)",
      "entity_id": "123",
      "extra_param_1": "value",
      "extra_param_2": "value"
    },
    "android": {
      "priority": "high",
      "notification": {
        "channel_id": "high_importance_channel",
        "sound": "default",
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      }
    },
    "apns": {
      "payload": {
        "aps": {
          "sound": "default",
          "badge": 1
        }
      }
    }
  }
}
```

---

## 3. In-App Notification API Schema (`GET /api/notifications`)

When the mobile app calls `GET /api/notifications`, the API response format should adhere to:

```json
{
  "success": true,
  "message": "Notifications fetched successfully",
  "data": {
    "unread_count": 3,
    "pagination": {
      "current_page": 1,
      "last_page": 5,
      "per_page": 20,
      "total": 95
    },
    "notifications": [
      {
        "id": "1001",
        "user_id": "45",
        "type": "job_application_received",
        "title": "New Job Application Received",
        "message": "Rahul Mali has applied for Senior Accountant.",
        "related_type": "job",
        "related_id": 55,
        "action_url": null,
        "is_read": false,
        "created_at": "2026-10-28T14:30:00Z",
        "data": {
          "job_id": "55",
          "application_id": "201"
        }
      }
    ]
  }
}
```

---

## 4. Master Notification Routing Table (All 21 Types)

Here is the complete mapping of every notification type to its exact `type` string, Flutter route, required arguments/keys, and intended recipient:

| # | Notification Event | Backend `type` Key | Flutter Target Route | Required Keys in `data` Payload | Target Audience | Destination Screen Description |
|---|--------------------|--------------------|----------------------|----------------------------------|-----------------|--------------------------------|
| 1 | **Admin announcement** | `admin_announcement` | `/notificationDetails` | `title`, `message`, `action_url` (optional) | All / Target Users | Opens Notification Detail page with announcement or opens URL if `action_url` is present. |
| 2 | **Business verified** | `business_verified` | `/businessDetails` | `business_id` | Business Owner | Opens the verified Business Detail page directly. |
| 3 | **Business rejected** | `business_rejected` | `/myBusiness` | `business_id`, `rejection_reason` | Business Owner | Opens "My Businesses" screen showing rejected status and re-submission option. |
| 4 | **Connection request** | `connection_request` | `/matrimonyRequests` | `request_id`, `profile_id` | Matrimony User | Opens Matrimony Requests screen (Received tab) to Accept/Reject. |
| 5 | **Connection accepted** | `connection_accepted` | `/matrimonyMembers` | `profile_id`, `conversation_id`, `other_user_id`, `user_name` | Matrimony User | Opens Connected Members list or direct chat with the member. |
| 6 | **Connection rejected** | `connection_rejected` | `/matrimonyRequests` | `request_id` | Matrimony User | Opens Matrimony Requests screen (Sent tab). |
| 7 | **Donation received** | `donation_received` | `/transactionHistory` | `transaction_id`, `cause_id` | Donor / Organizer | Opens Transaction History page displaying payment receipt & status. |
| 8 | **Job application received** | `job_application_received` | `/jobAppliers` | `job_id`, `application_id` | Employer / Business Owner | Opens Job Applications screen listing candidates who applied for this job. |
| 9 | **Job application status** | `job_application_status` | `/appliedJobList` | `application_id`, `job_id`, `status` | Job Applicant | Opens Candidate's "Applied Jobs" screen showing updated status (Accepted/Rejected/Reviewed). |
| 10 | **Matrimony profile approved** | `matrimony_profile_approved` | `/matrimonyProfileScreen` | `id` (or `profile_id`) | Matrimony User | Opens user's live approved Matrimony Profile. |
| 11 | **Matrimony profile pending** | `matrimony_profile_pending` | `/regMatrimony` | `profile_id` | Matrimony User | Opens Matrimony Registration screen showing "Pending Verification" badge. |
| 12 | **Matrimony profile rejected** | `matrimony_profile_rejected` | `/regMatrimony` | `profile_id`, `rejection_reason` | Matrimony User | Opens Matrimony Edit screen with rejection feedback for user to correct and re-submit. |
| 13 | **New chat message** | `new_chat_message` | `/matrimonyChat` | `conversation_id`, `other_user_id`, `user_name` | Chat Recipient | Directly opens 1-on-1 Chat Screen with the sender. |
| 14 | **New matrimony profile** | `new_matrimony_profile` | `/matrimonyProfileScreen` | `id` (or `profile_id`) | Active Matrimony Users | Opens the newly created Matrimony Profile (match recommendation). |
| 15 | **Payment successful** | `payment_successful` | `/transactionHistory` | `transaction_id`, `amount`, `module` | Payer | Opens Transaction History screen displaying success receipt. |
| 16 | **Payment failed** | `payment_failed` | `/transactionHistory` | `transaction_id`, `failure_reason` | Payer | Opens Transaction History screen showing failed attempt with retry option. |
| 17 | **Payment Pending Reminder** | `payment_pending_reminder` | `/transactionHistory` | `order_id`, `amount`, `module` | Payer | Opens Pending Payment / Transactions screen to complete checkout. |
| 18 | **Profile update** | `profile_update` | `/profileScreen` | `user_id` | User | Opens personal My Profile screen. |
| 19 | **Registration approved** | `registration_approved` | `/profileScreen` | `user_id` | User | Opens User Profile / Dashboard showing verified community membership. |
| 20 | **Registration rejected** | `registration_rejected` | `/update_Profile` | `user_id`, `rejection_reason` | User | Opens Update Profile screen with reason so user can upload valid ID/caste certificate. |
| 21 | **Subscription expiry reminder** | `subscription_expiry_reminder` | `/myBusiness` or `/transactionHistory` | `business_id` (if business) or `module`, `days_left` | Business / Matrimony User | Opens My Business or Plan screen with renewal CTA. |

---

## 5. Detailed Examples for Each Notification Payload

### 1. Admin Announcement
```json
{
  "notification": {
    "title": "Samaj Sammelan 2026",
    "body": "Annual Mali Samaj Sammelan scheduled for 15th Nov in Jaipur."
  },
  "data": {
    "type": "admin_announcement",
    "title": "Samaj Sammelan 2026",
    "message": "Annual Mali Samaj Sammelan scheduled for 15th Nov in Jaipur. Register now!",
    "action_url": "https://malisetu.com/events/annual-meet-2026"
  }
}
```

### 2. Business Verified
```json
{
  "notification": {
    "title": "Business Approved! 🎉",
    "body": "Your business 'Mali Agro Seeds' has been verified."
  },
  "data": {
    "type": "business_verified",
    "business_id": "42"
  }
}
```

### 3. Business Rejected
```json
{
  "notification": {
    "title": "Business Verification Rejected",
    "body": "Your business 'Mali Agro Seeds' was not verified. Click to check reason."
  },
  "data": {
    "type": "business_rejected",
    "business_id": "42",
    "rejection_reason": "Invalid GST certificate uploaded."
  }
}
```

### 4. Connection Request (Matrimony)
```json
{
  "notification": {
    "title": "New Connection Request",
    "body": "Pooja Mali has sent you a connection request."
  },
  "data": {
    "type": "connection_request",
    "request_id": "108",
    "profile_id": "350"
  }
}
```

### 5. Connection Accepted
```json
{
  "notification": {
    "title": "Request Accepted! 💖",
    "body": "Pooja Mali accepted your connection request. Start chatting now!"
  },
  "data": {
    "type": "connection_accepted",
    "profile_id": "350",
    "conversation_id": "78",
    "other_user_id": "22",
    "user_name": "Pooja Mali"
  }
}
```

### 6. Connection Rejected
```json
{
  "notification": {
    "title": "Connection Request Update",
    "body": "Your connection request was declined."
  },
  "data": {
    "type": "connection_rejected",
    "request_id": "108"
  }
}
```

### 7. Donation Received
```json
{
  "notification": {
    "title": "Donation Successful 🙏",
    "body": "Thank you! Your donation of ₹2,100 has been received."
  },
  "data": {
    "type": "donation_received",
    "transaction_id": "TXN_DON_987654",
    "cause_id": "5"
  }
}
```

### 8. Job Application Received (For Employer)
```json
{
  "notification": {
    "title": "New Applicant for Accountant Post",
    "body": "Suresh Mali has applied for your job post."
  },
  "data": {
    "type": "job_application_received",
    "job_id": "19",
    "application_id": "503"
  }
}
```

### 9. Job Application Status (For Applicant) [FCM BACKGROUND NOTIFICATION RECEIVED]
I/flutter (18016):    Message ID: 0:1793192975898659%1e541a641e541a64
I/flutter (18016):    Title:      Business Rejected
I/flutter (18016):    Body:       Your business verification was rejected. 
I/flutter (18016):    Data:       {action_key: business_rejected, action_url: /business/manage, action: details, notification_id: 24767, id: 24767, type: business_rejected, click_action: FLUTTER_NOTIFICATION_CLICK, message: {"data":{"type":"business_rejected","business_id":"337"},"token":"fQ8sGE_oTESrtLN4QY52Bs:APA91bF0IC4N4hhFk-vswcoA94a3Vw_IKMIPSZAcynnssVTuUC58QpBabCPN_bOmyk48yQceXGF3y2aNBarICftn0PPi8oNHBenM9lawAsY0y2j0JSmFVCw","notification":{"body":"Your business has been rejected.","title":"Business Verification Rejected"}}}
```json
{
  "notification": {
    "title": "Job Application Shortlisted! 🌟",
    "body": "Your application for Senior Accountant was shortlisted."
  },
  "data": {
    "type": "job_application_status",
    "job_id": "19",
    "application_id": "503",
    "status": "shortlisted"
  }
}
```

### 10. Matrimony Profile Approved
```json
{
  "notification": {
    "title": "Matrimony Profile Live 💍",
    "body": "Your matrimony profile has been approved and is now visible to members."
  },
  "data": {
    "type": "matrimony_profile_approved",
    "id": "350"
  }
}
```

### 11. Matrimony Profile Pending
```json
{
  "notification": {
    "title": "Profile Verification In Progress",
    "body": "Our community team is currently reviewing your matrimony profile."
  },
  "data": {
    "type": "matrimony_profile_pending",
    "profile_id": "350"
  }
}
```

### 12. Matrimony Profile Rejected
```json
{
  "notification": {
    "title": "Matrimony Profile Needs Correction",
    "body": "Please re-upload a clear passport size photograph."
  },
  "data": {
    "type": "matrimony_profile_rejected",
    "profile_id": "350",
    "rejection_reason": "Profile photo is blurry and does not show face clearly."
  }
}
```

### 13. New Chat Message
```json
{
  "notification": {
    "title": "Pooja Mali",
    "body": "Namaste! Are you available for a phone call today?"
  },
  "data": {
    "type": "new_chat_message",
    "conversation_id": "78",
    "other_user_id": "22",
    "user_name": "Pooja Mali"
  }
}
```

### 14. New Matrimony Profile (Match Recommendation)
```json
{
  "notification": {
    "title": "New Match Found ✨",
    "body": "A new profile matching your preferences was registered."
  },
  "data": {
    "type": "new_matrimony_profile",
    "id": "412"
  }
}
```

### 15. Payment Successful
```json
{
  "notification": {
    "title": "Payment Successful ✅",
    "body": "Payment of ₹1,499 for Annual Business Plan received."
  },
  "data": {
    "type": "payment_successful",
    "transaction_id": "TXN_PAY_112233",
    "amount": "1499",
    "module": "business"
  }
}
```

### 16. Payment Failed
```json
{
  "notification": {
    "title": "Payment Failed ⚠️",
    "body": "Your payment of ₹1,499 could not be completed."
  },
  "data": {
    "type": "payment_failed",
    "transaction_id": "TXN_PAY_FAIL_4455",
    "failure_reason": "Card declined by issuing bank."
  }
}
```

### 17. Payment Pending Reminder
```json
{
  "notification": {
    "title": "Complete Your Subscription ⏳",
    "body": "Your business plan payment is pending. Complete now to activate features."
  },
  "data": {
    "type": "payment_pending_reminder",
    "order_id": "ORD_78901",
    "amount": "1499",
    "module": "business"
  }
}
```

### 18. Profile Update
```json
{
  "notification": {
    "title": "Profile Updated",
    "body": "Your profile information has been successfully updated."
  },
  "data": {
    "type": "profile_update",
    "user_id": "45"
  }
}
```

### 19. Registration Approved (Account / Caste)
```json
{
  "notification": {
    "title": "Account Approved! 🎊",
    "body": "Your community verification is approved. You have full access to Mali Setu."
  },
  "data": {
    "type": "registration_approved",
    "user_id": "45"
  }
}
```

### 20. Registration Rejected
```json
{
  "notification": {
    "title": "Registration Incomplete",
    "body": "Your caste certificate could not be verified. Please update your document."
  },
  "data": {
    "type": "registration_rejected",
    "user_id": "45",
    "rejection_reason": "Caste certificate is expired or unreadable."
  }
}
```

### 21. Subscription Expiry Reminder
```json
{
  "notification": {
    "title": "Subscription Expiring Soon! ⏰",
    "body": "Your business subscription will expire in 3 days. Renew now to avoid interruption."
  },
  "data": {
    "type": "subscription_expiry_reminder",
    "module": "business",
    "business_id": "42",
    "days_left": "3"
  }
}
```

---

## 6. Backend Implementation Checklist (Laravel / PHP Example)

When sending push notifications from your Laravel backend (e.g. using `kreait/laravel-firebase` or raw HTTP v1 client):

```php
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

public function sendPushNotification($fcmToken, $type, $title, $body, array $extraData = [])
{
    // 1. Build notification block (tray display)
    $notification = Notification::create($title, $body);

    // 2. Ensure all data fields are Strings
    $stringData = array_map(function ($value) {
        return (string) $value;
    }, array_merge([
        'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
        'type' => $type,
        'title' => $title,
        'message' => $body,
    ], $extraData));

    // 3. Assemble CloudMessage
    $message = CloudMessage::withTarget('token', $fcmToken)
        ->withNotification($notification)
        ->withData($stringData)
        ->withHighestPossiblePriority();

    // 4. Send via Firebase Messaging
    $messaging = app('firebase.messaging');
    $messaging->send($message);

    // 5. Save to notifications database table for in-app list
    \App\Models\Notification::create([
        'user_id' => $userId,
        'type' => $type,
        'title' => $title,
        'message' => $body,
        'data' => $extraData,
        'is_read' => false,
    ]);
}
```

### Essential Rules for Backend:
1. **Sync FCM Token on Login & Refresh**: Always update the user's `fcm_token` when the app calls `PUT /api/auth/fcm-token`.
2. **Never send nested objects in FCM `data` directly**: FCM `data` must only be flat key-value strings. If you must send a complex structure, `json_encode()` it into a string key: e.g. `"meta": json_encode($array)`.
3. **Database & Push Synchronization**: Whenever creating a notification record in the database, dispatch the push notification with matching `type` and `data` keys.
4. **Send both `type` AND `action_key`**: Ensure maximum compatibility by providing both keys (e.g. `"type": "business_verified"`, `"action_key": "business_verified"`).

---

## 7. Zero-Failure Delivery & Click Guarantee Across All 3 App States

To guarantee that clicking a notification ALWAYS opens the correct screen in **every possible condition** (App Closed/Killed, App in Background, App Open/Foreground), the backend MUST strictly follow these rules:

### State 1: App is CLOSED / TERMINATED (Killed by user or system)
- **Problem:** If a backend sends *Data-only* messages without a `notification` block, Android and iOS battery optimizers silently discard the message when the app is killed.
- **Backend Solution:**
  1. ALWAYS include the root `notification: { "title": "...", "body": "..." }` block. When this is present, the Android OS and Apple APNs directly render the notification in the phone's system tray **even if the app process is 100% dead**.
  2. Set Android Priority to `"priority": "high"`.
  3. Include `"click_action": "FLUTTER_NOTIFICATION_CLICK"`.
  4. On iOS, include `apns: { "payload": { "aps": { "sound": "default", "badge": 1, "content-available": 1 } } }`.
- **Result:** When the user clicks the notification in the phone tray, the OS boots up the app, loads the splash screen, and Flutter reads the `data` payload to immediately route to the destination screen.

### State 2: App is in BACKGROUND (Minimized)
- **Behavior:** The phone OS displays the notification in the status bar/tray.
- **Backend Solution:** Same payload as above.
- **Result:** When tapped, the OS brings the app to the foreground and fires Flutter's `FirebaseMessaging.onMessageOpenedApp`, which parses the `type` and Entity ID to push the target screen immediately without reloading the app from scratch.

### State 3: App is in FOREGROUND (User is actively using the app)
- **Behavior:** By default, Firebase Cloud Messaging does not show a system tray banner when the app is actively on screen. Instead, it delivers the payload directly to Flutter's `FirebaseMessaging.onMessage` listener.
- **Result:** The mobile app displays an in-app banner/dialog or plays a sound. When tapped, it navigates to the target screen.

### State 4: In-App Notification Center (`GET /api/notifications` list)
- **Behavior:** User taps the notification bell icon inside the app and clicks on any list item.
- **Backend Requirement:** The notification object returned from `GET /api/notifications` must contain the exact same `type` and `data` JSON object (or `related_id` / `related_type`) so the in-app click handler routes to the same destination screen.

