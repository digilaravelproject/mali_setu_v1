import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';



class AppliedJobsScreen extends StatefulWidget {
  @override
  _AppliedJobsScreenState createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  List<JobApplication> applications = [
    // JobApplication(
    //   id: '1',
    //   jobTitle: 'Senior Flutter Developer',
    //   companyName: 'Tech Innovations Inc.',
    //   jobType: 'Full-time',
    //   location: 'San Francisco, CA',
    //   salary: '\$120,000 - \$150,000',
    //   workMode: 'Hybrid',
    //   appliedDate: DateTime.now().subtract(Duration(days: 3)),
    //   skillsRequired: ['Flutter', 'Dart', 'Firebase', 'REST API', 'BLoC'],
    //   description: 'We are looking for an experienced Flutter developer...',
    //   status: 'Under Review',
    // ),
    // JobApplication(
    //   id: '2',
    //   jobTitle: 'Mobile App Developer',
    //   companyName: 'StartUp Ventures',
    //   jobType: 'Contract',
    //   location: 'Remote',
    //   salary: '\$80 - \$100/hour',
    //   workMode: 'Remote',
    //   appliedDate: DateTime.now().subtract(Duration(days: 7)),
    //   skillsRequired: ['Flutter', 'iOS', 'Android', 'Git', 'Agile'],
    //   description: 'Join our fast-growing startup as a mobile developer...',
    //   status: 'Interview Scheduled',
    // ),
    // JobApplication(
    //   id: '3',
    //   jobTitle: 'Frontend Developer',
    //   companyName: 'Digital Solutions Ltd.',
    //   jobType: 'Full-time',
    //   location: 'New York, NY',
    //   salary: '\$95,000 - \$115,000',
    //   workMode: 'On-site',
    //   appliedDate: DateTime.now().subtract(Duration(days: 1)),
    //   skillsRequired: ['React', 'JavaScript', 'HTML/CSS', 'TypeScript'],
    //   description: 'Frontend developer needed for web applications...',
    //   status: 'Applied',
    // ),
  JobApplication(
  id: '1',
  jobTitle: 'Senior Flutter Developer',
  companyName: 'Tech Innovations Inc.',
  jobType: 'Full-time',
  location: 'San Francisco, CA (Hybrid)',
  salary: '\$120,000 - \$150,000 per year',
  workMode: 'Hybrid (3 days office)',
  appliedDate: DateTime.now().subtract(Duration(days: 3)),
  skillsRequired: ['Flutter', 'Dart', 'Firebase', 'REST API', 'BLoC', 'Git', 'Agile'],
  description: 'We are seeking an experienced Flutter Developer to join our mobile team. You will be responsible for building and maintaining our flagship mobile applications used by millions of users worldwide. The ideal candidate has 3+ years of experience in mobile development and a strong portfolio of published apps.',
  status: 'Under Review',
  experienceLevel: '3-5 years',
  applicationDeadline: 'December 15, 2024',
  requirements: [
  'Bachelor\'s degree in Computer Science or related field',
  '3+ years of professional mobile development experience',
  'Strong understanding of Flutter framework and Dart language',
  'Experience with state management (BLoC, Provider, Riverpod)',
  'Knowledge of RESTful APIs and third-party libraries',
  'Familiarity with version control (Git)',
  'Experience with automated testing',
  ],
  benefits: [
  'Health Insurance',
  'Stock Options',
  'Flexible Hours',
  'Remote Work Options',
  'Learning Budget',
  'Quarterly Bonuses',
  'Gym Membership',
  ],
  coverLetter: 'cover_letter_john_doe.pdf',
  additionalDocuments: ['portfolio.pdf', 'certifications.pdf'],
  applicationNotes: 'Referred by John Smith from LinkedIn. Scheduled follow-up call for next week.',
  companyEmail: 'careers@techinnovations.com',
  companyPhone: '+1 (555) 123-4567',
  companyWebsite: 'www.techinnovations.com',
  companyAddress: '123 Tech Street, San Francisco, CA 94107',
  companyDescription: 'Tech Innovations Inc. is a leading technology company specializing in mobile solutions for enterprise clients. Founded in 2015, we have grown to serve over 500 clients worldwide with our innovative software solutions. Our team of 200+ professionals is dedicated to creating cutting-edge mobile experiences.',
  ),
    JobApplication(
      id: '1',
      jobTitle: 'Senior Flutter Developer',
      companyName: 'Tech Innovations Inc.',
      jobType: 'Full-time',
      location: 'San Francisco, CA (Hybrid)',
      salary: '\$120,000 - \$150,000 per year',
      workMode: 'Hybrid (3 days office)',
      appliedDate: DateTime.now().subtract(Duration(days: 3)),
      skillsRequired: ['Flutter', 'Dart', 'Firebase', 'REST API', 'BLoC', 'Git', 'Agile'],
      description: 'We are seeking an experienced Flutter Developer to join our mobile team. You will be responsible for building and maintaining our flagship mobile applications used by millions of users worldwide. The ideal candidate has 3+ years of experience in mobile development and a strong portfolio of published apps.',
      status: 'Under Review',
      experienceLevel: '3-5 years',
      applicationDeadline: 'December 15, 2024',
      requirements: [
        'Bachelor\'s degree in Computer Science or related field',
        '3+ years of professional mobile development experience',
        'Strong understanding of Flutter framework and Dart language',
        'Experience with state management (BLoC, Provider, Riverpod)',
        'Knowledge of RESTful APIs and third-party libraries',
        'Familiarity with version control (Git)',
        'Experience with automated testing',
      ],
      benefits: [
        'Health Insurance',
        'Stock Options',
        'Flexible Hours',
        'Remote Work Options',
        'Learning Budget',
        'Quarterly Bonuses',
        'Gym Membership',
      ],
      coverLetter: 'cover_letter_john_doe.pdf',
      additionalDocuments: ['portfolio.pdf', 'certifications.pdf'],
      applicationNotes: 'Referred by John Smith from LinkedIn. Scheduled follow-up call for next week.',
      companyEmail: 'careers@techinnovations.com',
      companyPhone: '+1 (555) 123-4567',
      companyWebsite: 'www.techinnovations.com',
      companyAddress: '123 Tech Street, San Francisco, CA 94107',
      companyDescription: 'Tech Innovations Inc. is a leading technology company specializing in mobile solutions for enterprise clients. Founded in 2015, we have grown to serve over 500 clients worldwide with our innovative software solutions. Our team of 200+ professionals is dedicated to creating cutting-edge mobile experiences.',
    ),
    JobApplication(
      id: '1',
      jobTitle: 'Senior Flutter Developer',
      companyName: 'Tech Innovations Inc.',
      jobType: 'Full-time',
      location: 'San Francisco, CA (Hybrid)',
      salary: '\$120,000 - \$150,000 per year',
      workMode: 'Hybrid (3 days office)',
      appliedDate: DateTime.now().subtract(Duration(days: 3)),
      skillsRequired: ['Flutter', 'Dart', 'Firebase', 'REST API', 'BLoC', 'Git', 'Agile'],
      description: 'We are seeking an experienced Flutter Developer to join our mobile team. You will be responsible for building and maintaining our flagship mobile applications used by millions of users worldwide. The ideal candidate has 3+ years of experience in mobile development and a strong portfolio of published apps.',
      status: 'Under Review',
      experienceLevel: '3-5 years',
      applicationDeadline: 'December 15, 2024',
      requirements: [
        'Bachelor\'s degree in Computer Science or related field',
        '3+ years of professional mobile development experience',
        'Strong understanding of Flutter framework and Dart language',
        'Experience with state management (BLoC, Provider, Riverpod)',
        'Knowledge of RESTful APIs and third-party libraries',
        'Familiarity with version control (Git)',
        'Experience with automated testing',
      ],
      benefits: [
        'Health Insurance',
        'Stock Options',
        'Flexible Hours',
        'Remote Work Options',
        'Learning Budget',
        'Quarterly Bonuses',
        'Gym Membership',
      ],
      coverLetter: 'cover_letter_john_doe.pdf',
      additionalDocuments: ['portfolio.pdf', 'certifications.pdf'],
      applicationNotes: 'Referred by John Smith from LinkedIn. Scheduled follow-up call for next week.',
      companyEmail: 'careers@techinnovations.com',
      companyPhone: '+1 (555) 123-4567',
      companyWebsite: 'www.techinnovations.com',
      companyAddress: '123 Tech Street, San Francisco, CA 94107',
      companyDescription: 'Tech Innovations Inc. is a leading technology company specializing in mobile solutions for enterprise clients. Founded in 2015, we have grown to serve over 500 clients worldwide with our innovative software solutions. Our team of 200+ professionals is dedicated to creating cutting-edge mobile experiences.',
    ),
    JobApplication(
      id: '1',
      jobTitle: 'Senior Flutter Developer',
      companyName: 'Tech Innovations Inc.',
      jobType: 'Full-time',
      location: 'San Francisco, CA (Hybrid)',
      salary: '\$120,000 - \$150,000 per year',
      workMode: 'Hybrid (3 days office)',
      appliedDate: DateTime.now().subtract(Duration(days: 3)),
      skillsRequired: ['Flutter', 'Dart', 'Firebase', 'REST API', 'BLoC', 'Git', 'Agile'],
      description: 'We are seeking an experienced Flutter Developer to join our mobile team. You will be responsible for building and maintaining our flagship mobile applications used by millions of users worldwide. The ideal candidate has 3+ years of experience in mobile development and a strong portfolio of published apps.',
      status: 'Under Review',
      experienceLevel: '3-5 years',
      applicationDeadline: 'December 15, 2024',
      requirements: [
        'Bachelor\'s degree in Computer Science or related field',
        '3+ years of professional mobile development experience',
        'Strong understanding of Flutter framework and Dart language',
        'Experience with state management (BLoC, Provider, Riverpod)',
        'Knowledge of RESTful APIs and third-party libraries',
        'Familiarity with version control (Git)',
        'Experience with automated testing',
      ],
      benefits: [
        'Health Insurance',
        'Stock Options',
        'Flexible Hours',
        'Remote Work Options',
        'Learning Budget',
        'Quarterly Bonuses',
        'Gym Membership',
      ],
      coverLetter: 'cover_letter_john_doe.pdf',
      additionalDocuments: ['portfolio.pdf', 'certifications.pdf'],
      applicationNotes: 'Referred by John Smith from LinkedIn. Scheduled follow-up call for next week.',
      companyEmail: 'careers@techinnovations.com',
      companyPhone: '+1 (555) 123-4567',
      companyWebsite: 'www.techinnovations.com',
      companyAddress: '123 Tech Street, San Francisco, CA 94107',
      companyDescription: 'Tech Innovations Inc. is a leading technology company specializing in mobile solutions for enterprise clients. Founded in 2015, we have grown to serve over 500 clients worldwide with our innovative software solutions. Our team of 200+ professionals is dedicated to creating cutting-edge mobile experiences.',
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Icon(Icons.arrow_back_ios_rounded, color: context.iconColor),
        ),
        title: Text(
          "Applied Jobs",
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          return JobCard(
            application: applications[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfessionalJobDetailsScreen(job: applications[index],
                   // application: applications[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onTap;

  const JobCard({
    Key? key,
    required this.application,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title and Company
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.jobTitle,
                          style: context.textTheme.titleLarge?.copyWith(color: context.theme.primaryColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          application.companyName,
                          style: context.textTheme.bodyMedium
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(application.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      application.status,
                      style: context.textTheme.bodyMedium?.copyWith(color: context.theme.cardColor)
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Job Details Row
              Row(
                //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailIcon(Icons.schedule, application.jobType),
                  _buildDetailIcon(Icons.location_on, application.location),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  _buildDetailIcon(Icons.work, application.workMode),
                  _buildDetailIcon(Icons.attach_money, application.salary),
                ],
              ),



              SizedBox(height: 16),

              // Skills Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: application.skillsRequired
                    .take(3)
                    .map((skill) => Chip(
                  label: Text(skill),
                  backgroundColor: context.theme.primaryColorLight,
                  labelStyle: context.textTheme.bodyMedium,
                ))
                    .toList(),
              ),

              SizedBox(height: 8),

              // Applied Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Applied: Nov 5, 2025',
                    style: context.textTheme.bodyMedium,
                  ),
                  Icon(
                    Icons.chevron_right,
                    color:context.theme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailIcon(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Get.theme.primaryColor),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Get.theme.textTheme.bodyMedium,
             // TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'interview scheduled':
        return Colors.orange;
      case 'under review':
        return Colors.blue;
      case 'applied':
        return Colors.grey;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}





class ProfessionalJobDetailsScreen extends StatelessWidget {
  final JobApplication job;

  ProfessionalJobDetailsScreen({required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            leading:GestureDetector(
              onTap: Get.back,
              child: Icon(Icons.arrow_back_ios_rounded, color: context.iconColor),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title:  Text(
                job.companyName,
                style: context.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Title and Basic Info
                  _buildJobHeader(),
                  SizedBox(height: 24),

                  // Application Timeline
                  _buildTimelineSection(),
                  SizedBox(height: 24),

                  // Job Details Sections
                  _buildDetailCard(
                    title: 'Job Details',
                    icon: Icons.work,
                    child: _buildJobDetails(),
                  ),
                  SizedBox(height: 16),

                  _buildDetailCard(
                    title: 'Requirements & Qualifications',
                    icon: Icons.checklist,
                    child: _buildRequirements(),
                  ),
                  SizedBox(height: 16),

                  _buildDetailCard(
                    title: 'Benefits & Perks',
                    icon: Icons.card_giftcard,
                    child: _buildBenefits(),
                  ),
                  SizedBox(height: 16),

                  _buildDetailCard(
                    title: 'Your Application',
                    icon: Icons.description,
                    child: _buildYourApplication(),
                  ),
                  SizedBox(height: 16),

                  _buildDetailCard(
                    title: 'Company & Contact',
                    icon: Icons.business,
                    child: _buildCompanyContact(),
                  ),
                  SizedBox(height: 30),

                  // Action Buttons
                  //_buildActionButtons(context),
                 // SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.jobTitle,
                        style: Get.theme.textTheme.headlineMedium?.copyWith(color: Get.theme.primaryColor)
                      ),
                      SizedBox(height: 8),
                      Text(
                        job.companyName,
                        style: Get.theme.textTheme.bodyLarge
                        // TextStyle(
                        //   fontSize: 18,
                        //   color: Colors.grey[700],
                        // ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Get.theme.primaryColor.withOpacity(0.7), Get.theme.primaryColor.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.status,
                    style: Get.textTheme.bodyMedium?.copyWith(color: Get.theme.cardColor)
                    // TextStyle(
                    //   color: Colors.white,
                    //   fontWeight: FontWeight.bold,
                    // ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildInfoChip(Icons.schedule, job.jobType),
                _buildInfoChip(Icons.location_on, job.location),
                _buildInfoChip(Icons.attach_money, job.salary),
                _buildInfoChip(Icons.work_outline, job.workMode),
                _buildInfoChip(Icons.timeline, 'Experience: ${job.experienceLevel}'),
                _buildInfoChip(Icons.event_busy, 'Deadline: ${job.applicationDeadline}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          SizedBox(width: 6),
          Text(
            text,
            style:Get.textTheme.bodyMedium
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    List<TimelineEvent> timelineEvents = [
      TimelineEvent(
        title: 'Applied',
        date: job.appliedDate,
        status: 'completed',
        icon: Icons.send,
      ),
      TimelineEvent(
        title: 'Under Review',
        date: job.appliedDate.add(Duration(days: 1)),
        status: 'completed',
        icon: Icons.visibility,
      ),
      TimelineEvent(
        title: 'Decision',
        date: job.appliedDate.add(Duration(days: 7)),
        status: 'upcoming',
        icon: Icons.gavel,
      ),
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color:  Get.theme.primaryColor),
                SizedBox(width: 10),
                Text(
                  'Application Timeline',
                  style:Get.textTheme.headlineMedium?.copyWith(color: Get.theme.primaryColor)
                  // TextStyle(
                  //   fontSize: 18,
                  //   fontWeight: FontWeight.bold,
                  // ),
                ),
              ],
            ),
          //  SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: timelineEvents.length,
              separatorBuilder: (_, __) => SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = timelineEvents[index];
                return _buildTimelineItem(event, index == timelineEvents.length - 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(TimelineEvent event, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Get.theme.primaryColorLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            event.icon,
            size: 20,
            color: Get.theme.primaryColor,
          ),
        ),
        // Column(
        //   children: [
        //     Container(
        //       width: 40,
        //       height: 40,
        //       decoration: BoxDecoration(
        //         shape: BoxShape.circle,
        //         color: _getTimelineColor(event.status),
        //         border: Border.all(color: Colors.white, width: 2),
        //       ),
        //       child: Icon(
        //         event.icon,
        //         size: 20,
        //         color: Colors.white,
        //       ),
        //     ),
        //     if (!isLast)
        //       Container(
        //         width: 2,
        //         height: 40,
        //         color: Colors.grey[300],
        //       ),
        //   ],
        // ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: Get.textTheme.titleMedium,
              ),
              SizedBox(height: 4),
              Text(
                "5 Nov, 2025",
                //DateFormat('MMM dd, yyyy').format(event.date),
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTimelineStatusColor(event.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.status.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Color _getTimelineStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'upcoming':
        return Colors.blue[300]!;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Get.theme.primaryColor),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: Get.textTheme.titleLarge
                ),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Job Type', job.jobType),
        _buildDetailRow('Work Mode', job.workMode),
        _buildDetailRow('Location', job.location),
        _buildDetailRow('Salary Range', job.salary),
        _buildDetailRow('Experience Level', job.experienceLevel),
        _buildDetailRow('Application Deadline', job.applicationDeadline),
        SizedBox(height: 12),
        Text(
          'Job Description:',
          style: Get.textTheme.titleMedium
        //  TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text(
          job.description,
          style: Get.textTheme.bodyMedium
          //TextStyle(height: 1.6),
        ),
      ],
    );
  }

  Widget _buildRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: job.skillsRequired
              .map((skill) => Chip(
            label: Text(skill),
            backgroundColor: Colors.blue[50],
            labelStyle: TextStyle(color: Colors.blue[800]),
          ))
              .toList(),
        ),
        SizedBox(height: 16),
        ...job.requirements.map((req) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  req,
                  style: Get.textTheme.bodyMedium
                //  TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildBenefits() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: job.benefits
          .map((benefit) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Get.theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 16, color: Colors.green),
            SizedBox(width: 8),
            Text(
              benefit,
              style: TextStyle(color: Colors.green[800]),
            ),
          ],
        ),
      ))
          .toList(),
    );
  }

  Widget _buildYourApplication() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDocumentItem(
          'Resume',
          'resume_john_doe.pdf',
          true,
          onTap: () {
            // Open PDF
          },
        ),
        // _buildDocumentItem(
        //   'Cover Letter',
        //   job.coverLetter ?? 'Not Attached',
        //   job.coverLetter != null,
        // ),
        // _buildDocumentItem(
        //   'Additional Documents',
        //   job.additionalDocuments?.join(', ') ?? 'No additional documents',
        //   job.additionalDocuments != null && job.additionalDocuments!.isNotEmpty,
        // ),
        SizedBox(height: 16),
        Text(
          'Application Notes:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Get.theme.hoverColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Get.theme.dividerColor),
          ),
          child: Text(
            job.applicationNotes ?? 'No additional notes provided',
            style: TextStyle(height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem(String title, String subtitle, bool available, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:Get.theme.hoverColor ,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Get.theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            available ? Icons.description : Icons.description_outlined,
            color: available ? Colors.blue : Colors.grey,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:Get.textTheme.titleMedium
                  // TextStyle(
                  //   fontWeight: FontWeight.w500,
                  // ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Get.textTheme.bodyMedium
                  // TextStyle(
                  //   fontSize: 12,
                  //   color: Colors.grey[600],
                  // ),
                ),
              ],
            ),
          ),
          if (available && onTap != null)
            IconButton(
              icon: Icon(Icons.open_in_new, size: 20),
              onPressed: onTap,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }

  Widget _buildCompanyContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Email', job.companyEmail),
        _buildDetailRow('Phone', job.companyPhone),
        _buildDetailRow('Website', job.companyWebsite),
        _buildDetailRow('Address', job.companyAddress),
        SizedBox(height: 12),
        Text(
          'About Company:',
          style:Get.textTheme.titleMedium
          //TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text(
          job.companyDescription,
          style:Get.textTheme.bodyMedium
          //TextStyle(height: 1.6),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            child: Text(
              '$label:',
              style:Get.textTheme.bodyMedium
              // TextStyle(
              //   fontWeight: FontWeight.w500,
              //   color: Colors.grey[700],
              // ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Get.textTheme.bodyMedium
             // TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Update application
            },
            icon: Icon(Icons.edit),
            label: Text('Edit Application'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // View company profile
            },
            icon: Icon(Icons.business),
            label: Text('View Company'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Updated Data Model with all new fields
class JobApplication {
  final String id;
  final String jobTitle;
  final String companyName;
  final String jobType;
  final String location;
  final String salary;
  final String workMode;
  final DateTime appliedDate;
  final List<String> skillsRequired;
  final String description;
  final String status;
  final String experienceLevel;
  final String applicationDeadline;
  final List<String> requirements;
  final List<String> benefits;
  final String? coverLetter;
  final List<String>? additionalDocuments;
  final String? applicationNotes;
  final String companyEmail;
  final String companyPhone;
  final String companyWebsite;
  final String companyAddress;
  final String companyDescription;

  JobApplication({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.jobType,
    required this.location,
    required this.salary,
    required this.workMode,
    required this.appliedDate,
    required this.skillsRequired,
    required this.description,
    required this.status,
    required this.experienceLevel,
    required this.applicationDeadline,
    required this.requirements,
    required this.benefits,
    this.coverLetter,
    this.additionalDocuments,
    this.applicationNotes,
    required this.companyEmail,
    required this.companyPhone,
    required this.companyWebsite,
    required this.companyAddress,
    required this.companyDescription,
  });
}

class TimelineEvent {
  final String title;
  final DateTime date;
  final String status; // completed, pending, upcoming
  final IconData icon;

  TimelineEvent({
    required this.title,
    required this.date,
    required this.status,
    required this.icon,
  });
}

// Sample Static Data
final sampleJob = JobApplication(
  id: '1',
  jobTitle: 'Senior Flutter Developer',
  companyName: 'Tech Innovations Inc.',
  jobType: 'Full-time',
  location: 'San Francisco, CA (Hybrid)',
  salary: '\$120,000 - \$150,000 per year',
  workMode: 'Hybrid (3 days office)',
  appliedDate: DateTime.now().subtract(Duration(days: 3)),
  skillsRequired: ['Flutter', 'Dart', 'Firebase', 'REST API', 'BLoC', 'Git', 'Agile'],
  description: 'We are seeking an experienced Flutter Developer to join our mobile team. You will be responsible for building and maintaining our flagship mobile applications used by millions of users worldwide. The ideal candidate has 3+ years of experience in mobile development and a strong portfolio of published apps.',
  status: 'Under Review',
  experienceLevel: '3-5 years',
  applicationDeadline: 'December 15, 2024',
  requirements: [
    'Bachelor\'s degree in Computer Science or related field',
    '3+ years of professional mobile development experience',
    'Strong understanding of Flutter framework and Dart language',
    'Experience with state management (BLoC, Provider, Riverpod)',
    'Knowledge of RESTful APIs and third-party libraries',
    'Familiarity with version control (Git)',
    'Experience with automated testing',
  ],
  benefits: [
    'Health Insurance',
    'Stock Options',
    'Flexible Hours',
    'Remote Work Options',
    'Learning Budget',
    'Quarterly Bonuses',
    'Gym Membership',
  ],
  coverLetter: 'cover_letter_john_doe.pdf',
  additionalDocuments: ['portfolio.pdf', 'certifications.pdf'],
  applicationNotes: 'Referred by John Smith from LinkedIn. Scheduled follow-up call for next week.',
  companyEmail: 'careers@techinnovations.com',
  companyPhone: '+1 (555) 123-4567',
  companyWebsite: 'www.techinnovations.com',
  companyAddress: '123 Tech Street, San Francisco, CA 94107',
  companyDescription: 'Tech Innovations Inc. is a leading technology company specializing in mobile solutions for enterprise clients. Founded in 2015, we have grown to serve over 500 clients worldwide with our innovative software solutions. Our team of 200+ professionals is dedicated to creating cutting-edge mobile experiences.',
);


