// Agency-specific data models

class AgencyUser {
  final int id;
  final String name;
  final String email;
  final String agencyName;
  final String role; // 'owner' | 'agent'
  final bool isVerified;
  final String? phone;
  final String? location;
  final int? agencyId;
  final bool isAgency;

  AgencyUser({
    required this.id,
    required this.name,
    required this.email,
    required this.agencyName,
    required this.role,
    required this.isVerified,
    this.phone,
    this.location,
    this.agencyId,
    this.isAgency = true,
  });

  bool get isOwner => role == 'owner';

  factory AgencyUser.fromJson(Map<String, dynamic> json) {
    return AgencyUser(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      agencyName: json['business_name'] as String? ?? json['agency_name'] as String? ?? '',
      role: json['role'] as String? ?? 'owner',
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      phone: json['phone'] as String?,
      location: json['business_address'] as String? ?? json['location'] as String?,
      agencyId: json['agencyId'] as int?,
      isAgency: json['is_agency'] == true || json['is_agency'] == 1,
    );
  }
}

class AgencyProfile {
  final int id;
  final String name;
  final String email;
  final String agencyName;
  final String? phone;
  final String? location;
  final bool isVerified;
  final String? govtIdNumber;
  final String? govtIdImageUrl;
  final String? trademarkLicenseUrl;
  final String? logoUrl;

  AgencyProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.agencyName,
    this.phone,
    this.location,
    required this.isVerified,
    this.govtIdNumber,
    this.govtIdImageUrl,
    this.trademarkLicenseUrl,
    this.logoUrl,
  });

  factory AgencyProfile.fromJson(Map<String, dynamic> json) {
    return AgencyProfile(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      agencyName: json['agency_name'] as String? ?? '',
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      govtIdNumber: json['govt_id_number'] as String?,
      govtIdImageUrl: json['govt_id_image_url'] as String?,
      trademarkLicenseUrl: json['trademark_license_url'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }
}

class AgencyDashboardStats {
  final int activeAds;
  final int totalViews;
  final int pipelineLeads;
  final int teamAgents;
  final List<AgencyLead> recentLeads;
  final List<AgencyChartData> chartData;

  AgencyDashboardStats({
    required this.activeAds,
    required this.totalViews,
    required this.pipelineLeads,
    required this.teamAgents,
    required this.recentLeads,
    required this.chartData,
  });

  factory AgencyDashboardStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final leads = json['recentLeads'] as List<dynamic>? ?? [];
    final chart = json['chartData'] as List<dynamic>? ?? [];

    return AgencyDashboardStats(
      activeAds: stats['activeAds'] as int? ?? 0,
      totalViews: stats['totalViews'] as int? ?? 0,
      pipelineLeads: stats['pipelineLeads'] as int? ?? 0,
      teamAgents: stats['teamAgents'] as int? ?? 0,
      recentLeads: leads.map((e) => AgencyLead.fromJson(e as Map<String, dynamic>)).toList(),
      chartData: chart.map((e) => AgencyChartData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class AgencyChartData {
  final String name;
  final int leads;
  final int views;

  AgencyChartData({required this.name, required this.leads, required this.views});

  factory AgencyChartData.fromJson(Map<String, dynamic> json) {
    return AgencyChartData(
      name: json['name'] as String? ?? '',
      leads: json['leads'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
    );
  }
}

class AgencyLead {
  final int id;
  final String name;
  final String property;
  final String time;
  final String status;

  AgencyLead({
    required this.id,
    required this.name,
    required this.property,
    required this.time,
    required this.status,
  });

  factory AgencyLead.fromJson(Map<String, dynamic> json) {
    return AgencyLead(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      property: json['property'] as String? ?? '',
      time: json['time'] as String? ?? '',
      status: json['status'] as String? ?? 'New',
    );
  }
}

class AgencyAgent {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final int activeListings;
  final String createdAt;

  AgencyAgent({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.activeListings,
    required this.createdAt,
  });

  factory AgencyAgent.fromJson(Map<String, dynamic> json) {
    return AgencyAgent(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'Agent',
      status: json['status'] as String? ?? 'Active',
      activeListings: json['active_listings'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class AgencyAd {
  final int id;
  final String title;
  final String? price;
  final String status;
  final int views;
  final String? imageUrl;
  final String createdAt;
  final String? description;
  final String? phone;
  final int? categoryId;
  final String? categoryName;
  final String? condition;
  final Map<String, dynamic>? productAttributes;
  final List<String>? images;

  AgencyAd({
    required this.id,
    required this.title,
    this.price,
    required this.status,
    required this.views,
    this.imageUrl,
    required this.createdAt,
    this.description,
    this.phone,
    this.categoryId,
    this.categoryName,
    this.condition,
    this.productAttributes,
    this.images,
  });

  factory AgencyAd.fromJson(Map<String, dynamic> json) {
    return AgencyAd(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      price: json['price']?.toString(),
      status: json['status'] as String? ?? 'active',
      views: json['views'] as int? ?? 0,
      imageUrl: json['thumbnail'] as String? ?? json['image_url'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String?,
      condition: json['condition'] as String?,
      productAttributes: json['product_attributes'] is Map ? Map<String, dynamic>.from(json['product_attributes'] as Map) : null,
      images: json['images'] is List 
          ? (json['images'] as List).map((e) => (e is Map ? e['image'] : e).toString()).toList()
          : null,
    );
  }
}

class AgencySupportTicket {
  final int id;
  final String title;
  final String description;
  final String status;
  final String createdAt;

  AgencySupportTicket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory AgencySupportTicket.fromJson(Map<String, dynamic> json) {
    return AgencySupportTicket(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'Open',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
