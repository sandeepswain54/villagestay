# Property Approval Flow Guide

## Overview
When users upload a property, it's stored in the `pending_properties` collection with `status: "pending"`. The app then shows a pending approval screen that listens for changes in real-time.

## Collections Structure

### `pending_properties` Collection
Each document contains:
- `name` - Property name
- `location` - Property location
- `description` - Property description
- `imageUrls` - Array of image URLs
- `slots` - Pricing slots
- `amenities` - Selected amenities
- `status` - "pending", "approved", or "rejected"
- `userId` - User ID who uploaded
- `userEmail` - User email
- `submittedAt` - Submission timestamp

## How to Approve Properties

### From Firebase Console:

1. **Locate the Pending Property**
   - Go to Firestore Database
   - Navigate to `pending_properties` collection
   - Find the document you want to approve

2. **Update the Status Field**
   - Edit the document
   - Change the `status` field from `"pending"` to `"approved"`
   - Click Save

3. **What Happens Next**
   - The user's app listens to their property document in real-time
   - When status changes to "approved", the app automatically:
     - Shows a success notification "Your property has been approved! 🎉"
     - Navigates to HostHomeScreen (home page)
     - The user can now see their property in the active listings

### To Reject a Property:

1. Edit the document
2. Change `status` to `"rejected"`
3. **Optional**: Add a `rejectionReason` field with a string value explaining why (e.g., "Images are low quality" or "Duplicate property")
4. Save

When rejected:
- User sees a dialog showing the rejection reason
- User is taken back to the upload screen to resubmit

## Optional: Move Approved to Hotels Collection

After approving, you can also move the property to the `hotels` collection:

```
1. Copy all fields from pending_properties document
2. Create a new document in `hotels` collection
3. Delete from pending_properties (optional)
```

Or update the code to automatically move it by modifying the approval trigger.

## Real-Time Listeners

The app uses:
```dart
FirebaseFirestore.instance
    .collection('pending_properties')
    .doc(widget.propertyId)
    .snapshots()
```

This means approvals are instant - no need to restart the app!

## Firebase Rules (Recommended)

Add security rules to prevent users from modifying their own approval status:

```
match /pending_properties/{document=**} {
  allow read: if request.auth.uid == resource.data.userId;
  allow create: if request.auth.uid != null;
  allow update: if request.auth == null; // Only admin (no auth) can update
  allow delete: if request.auth == null;
}
```

This ensures only backend/admin can change the status field.
