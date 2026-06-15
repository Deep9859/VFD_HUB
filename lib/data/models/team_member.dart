import '../../core/enterprise/app_permission.dart';

class TeamMember {
  final String email;
  final String displayName;
  final EnterpriseRole role;
  final DateTime joinedAt;

  const TeamMember({
    required this.email,
    required this.displayName,
    required this.role,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'displayName': displayName,
        'role': role.name,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        role: EnterpriseRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => EnterpriseRole.viewer,
        ),
        joinedAt: DateTime.parse(json['joinedAt'] as String),
      );
}

class SharedTeamProject {
  final String id;
  final String teamId;
  final String sharedBy;
  final String projectName;
  final Map<String, dynamic> configuration;
  final DateTime sharedAt;

  const SharedTeamProject({
    required this.id,
    required this.teamId,
    required this.sharedBy,
    required this.projectName,
    required this.configuration,
    required this.sharedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamId': teamId,
        'sharedBy': sharedBy,
        'projectName': projectName,
        'configuration': configuration,
        'sharedAt': sharedAt.toIso8601String(),
      };

  factory SharedTeamProject.fromJson(Map<String, dynamic> json) =>
      SharedTeamProject(
        id: json['id'] as String,
        teamId: json['teamId'] as String,
        sharedBy: json['sharedBy'] as String,
        projectName: json['projectName'] as String,
        configuration:
            Map<String, dynamic>.from(json['configuration'] as Map),
        sharedAt: DateTime.parse(json['sharedAt'] as String),
      );
}
