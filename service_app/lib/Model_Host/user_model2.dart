enum UserType { tourist, host, admin }
enum ApprovalStatus { pending, approved, rejected }

class AppUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final UserType type;
  final ApprovalStatus approvalStatus;
  final String? serviceType;
  final String? govtId;
  final String? govtIdImageUrl;
  final DateTime registeredOn;
  final String? rejectionReason;

  AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.type,
    this.approvalStatus = ApprovalStatus.pending,
    this.serviceType,
    this.govtId,
    this.govtIdImageUrl,
    required this.registeredOn,
    this.rejectionReason,
  });

  // Add fromMap/toMap methods
}