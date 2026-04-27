class JobApplicationModel {
  final int id;
  final int jobId;
  final String jobTitle;
  final String status; // pending, reviewed, shortlisted, rejected
  final String createdAt;
  
  // Applicant details (for seller view)
  final int? applicantUserId;
  final String? applicantName;
  final String? applicantEmail;
  final String? applicantPhone;
  final String? applicantAvatar;
  final String? applicantLocation;
  final String? coverLetter;
  final String? resumeUrl;

  // Company details (for buyer view)
  final String? companyName;
  final String? jobType;
  final String? city;
  final String? state;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.status,
    required this.createdAt,
    this.applicantUserId,
    this.applicantName,
    this.applicantEmail,
    this.applicantPhone,
    this.applicantAvatar,
    this.applicantLocation,
    this.coverLetter,
    this.resumeUrl,
    this.companyName,
    this.jobType,
    this.city,
    this.state,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      jobId: json['job_id'] is String ? int.parse(json['job_id']) : json['job_id'],
      jobTitle: json['job_title'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      applicantUserId: json['applicant_user_id'],
      applicantName: json['applicant_name'] ?? json['full_name'],
      applicantEmail: json['applicant_email'] ?? json['email'],
      applicantPhone: json['applicant_phone'] ?? json['phone'],
      applicantAvatar: json['applicant_avatar'],
      applicantLocation: json['applicant_location'],
      coverLetter: json['cover_letter'],
      resumeUrl: json['resume_url'],
      companyName: json['company_name'],
      jobType: json['job_type'],
      city: json['city_name'],
      state: json['state_name'],
    );
  }
}

class SellerJobPostModel {
  final int id;
  final String title;
  final int applicantCount;

  SellerJobPostModel({
    required this.id,
    required this.title,
    this.applicantCount = 0,
  });

  factory SellerJobPostModel.fromJson(Map<String, dynamic> json) {
    return SellerJobPostModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      title: json['title'] ?? '',
    );
  }
}
