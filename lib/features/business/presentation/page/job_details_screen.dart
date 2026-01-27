import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobDetailsScreen extends StatelessWidget {
   JobDetailsScreen({super.key});

  // Sample Job Data
  final Map<String, dynamic> job = {
    'id': 1,
    'title': 'Senior Flutter Developer',
    'company': 'Tech Solutions Pvt Ltd',
    'companyImage': 'https://via.placeholder.com/100',
    'salary': '₹1,20,000 - ₹1,80,000 per month',
    'location': 'Lucknow, Uttar Pradesh',
    'jobType': 'Full Time',
    'experience': '3-5 Years',
    'postedDate': '2 days ago',
    'applications': 45,
    'urgent': true,
    'remote': true,
    'description': 'We are looking for a skilled Flutter Developer to join our team. You will be responsible for building cross-platform mobile applications for iOS and Android using Flutter framework.',
    'requirements': [
      'Bachelor\'s degree in Computer Science or related field',
      '3+ years of experience in mobile app development',
      'Strong knowledge of Dart programming language',
      'Experience with RESTful APIs and third-party libraries',
      'Knowledge of Git, Firebase, and state management',
      'Published at least one app on Google Play Store or App Store',
    ],
    'skills': ['Flutter', 'Dart', 'Firebase', 'REST APIs', 'Git', 'BLoC', 'Provider', 'UI/UX'],
    'benefits': [
      'Health insurance',
      'Flexible working hours',
      'Remote work options',
      'Paid time off',
      'Professional development',
      'Stock options',
      'Annual bonus',
    ],
    'companyDetails': {
      'about': 'Tech Solutions is a leading IT services company specializing in mobile and web applications. We have served over 500+ clients worldwide.',
      'size': '50-100 employees',
      'founded': '2018',
      'industry': 'Information Technology & Services',
      'website': 'www.techsolutions.com',
      'email': 'careers@techsolutions.com',
      'phone': '+91 98765 43210',
      'address': 'Sector 62, Noida, Uttar Pradesh 201309',
    },
    'similarJobs': [
      {'title': 'Flutter Developer', 'company': 'Digital Innovations', 'salary': '₹80,000 - ₹1,20,000', 'location': 'Delhi'},
      {'title': 'Mobile App Developer', 'company': 'AppTech Solutions', 'salary': '₹90,000 - ₹1,40,000', 'location': 'Bangalore'},
      {'title': 'React Native Developer', 'company': 'WebCraft Studio', 'salary': '₹85,000 - ₹1,30,000', 'location': 'Hyderabad'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Company Image
          /*SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade50, Colors.white],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              job['companyImage'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.business,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                job['title'],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                job['company'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.bookmark_border, size: 20),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.share, size: 20),
                ),
              ),
            ],
          ),*/
          SliverAppBar(
            elevation: 2,
            pinned: true,
            centerTitle: false,
            // title: Text(
            //   'My Businesses',
            //   style: context.textTheme.titleLarge?.copyWith(
            //     fontWeight: FontWeight.w700,
            //     fontSize: 22,
            //   ),
            // ),

            leading: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back_ios,
                color: context.iconColor,
                size: 18,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
              child:  Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.theme.dividerColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        job['companyImage'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: context.theme.hoverColor,
                            child: Icon(
                              Icons.business,
                              size: 30,
                              color: context.iconColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          job['company'],
                            maxLines: 2,
                          style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800,fontSize: 20)
                          // const TextStyle(
                          //   fontSize: 22,
                          //   fontWeight: FontWeight.w800,
                          //   color: Colors.black87,
                          // ),

                        ),
                        const SizedBox(height: 4),
                        Text(
                          job['title'],
                          style: context.textTheme.titleMedium?.copyWith(color: Colors.blue)
                          // TextStyle(
                          //   fontSize: 16,
                          //   fontWeight: FontWeight.w600,
                          //   color: Colors.blue.shade700,
                          // ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Job Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Urgent Badge & Status
                  if (job['urgent'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 14, color: Colors.red.shade600),
                          const SizedBox(width: 6),
                          Text(
                            'Urgent Hiring',
                            style:context.textTheme.titleSmall?.copyWith(color: Colors.red.shade600,)
                            // TextStyle(
                            //   color: Colors.red.shade600,
                            //   fontWeight: FontWeight.w600,
                            //   fontSize: 13,
                            // ),
                          ),
                        ],
                      ),
                    ),


                  // Key Details Grid
                  Column(
                    // shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
                    // crossAxisCount: 2,
                    // childAspectRatio: 2.5,
                    // crossAxisSpacing: 12,
                    // mainAxisSpacing: 12,
                    children: [
                      _buildDetailItem(
                        context : context,
                        icon: Icons.currency_rupee,
                        title: 'Salary',
                        value: job['salary'],
                        color: Colors.green,
                      ),
                      _buildDetailItem(
                        context : context,
                        icon: Icons.location_on,
                        title: 'Location',
                        value: job['location'],
                        color: Colors.blue,
                      ),
                      _buildDetailItem(
                        context : context,
                        icon: Icons.work_outline,
                        title: 'Job Type',
                        value: job['jobType'],
                        color: Colors.purple,
                      ),
                      _buildDetailItem(
                        context : context,
                        icon: Icons.timeline,
                        title: 'Experience',
                        value: job['experience'],
                        color: Colors.orange,
                      ),
                      _buildDetailItem(
                        context : context,
                        icon: Icons.calendar_today,
                        title: 'Posted',
                        value: job['postedDate'],
                        color: Colors.teal,
                      ),
                      _buildDetailItem(
                        context : context,
                        icon: Icons.people_outline,
                        title: 'Applications',
                        value: '${job['applications']} applied',
                        color: Colors.indigo,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Job Description
                  _buildSection(
                    context: context,
                    title: 'Job Description',
                    icon: Icons.description,
                    child: Text(
                      job['description'],
                      style:context.textTheme.bodyMedium
                      // TextStyle(
                      //   fontSize: 15,
                      //   color: Colors.grey[700],
                      //   height: 1.5,
                      // ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Requirements
                  _buildSection(
                    context: context,
                    title: 'Requirements',
                    icon: Icons.checklist,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var requirement in job['requirements'])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: context.theme.primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    requirement,
                                    style: context.textTheme.bodyMedium,
                                    // TextStyle(
                                    //   fontSize: 14,
                                    //   color: Colors.grey[700],
                                    //   height: 1.5,
                                    // ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Required Skills
                  _buildSection(
                    context:context,
                    title: 'Required Skills',
                    icon: Icons.code,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var skill in job['skills'])
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Text(
                              skill,
                              style:
                              context.textTheme.bodyMedium?.copyWith(color: Colors.blue.shade700,fontWeight: FontWeight.w500)
                              // TextStyle(
                              //   color: Colors.blue.shade700,
                              //   fontWeight: FontWeight.w500,
                              // ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Benefits & Perks
                  _buildSection(
                    context: context,
                    title: 'Benefits & Perks',
                    icon: Icons.card_giftcard,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (var benefit in job['benefits'])
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.green.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  benefit,
                                  style:context.textTheme.bodyMedium?.copyWith(color: Colors.green.shade800,fontWeight: FontWeight.w500)

                                  // TextStyle(
                                  //   color: Colors.green.shade800,
                                  //   fontWeight: FontWeight.w500,
                                  // ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Company Details
                  _buildSection(
                    context: context,
                    title: 'About Company',
                    icon: Icons.business,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['companyDetails']['about'],
                          style: context.textTheme.bodyMedium
                          // TextStyle(
                          //   fontSize: 15,
                          //   color: Colors.grey[700],
                          //   height: 1.5,
                          // ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          // shrinkWrap: true,
                          // physics: const NeverScrollableScrollPhysics(),
                          // crossAxisCount: 2,
                          // childAspectRatio: 3,
                          // crossAxisSpacing: 12,
                          // mainAxisSpacing: 12,
                          children: [
                            _buildCompanyDetailItem(
                              context:context,
                              icon: Icons.people,
                              title: 'Company Size',
                              value: job['companyDetails']['size'],
                            ),
                            _buildCompanyDetailItem(
                              context:context,
                              icon: Icons.calendar_month,
                              title: 'Founded',
                              value: job['companyDetails']['founded'],
                            ),
                            _buildCompanyDetailItem(
                              context:context,
                              icon: Icons.work,
                              title: 'Industry',
                              value: job['companyDetails']['industry'],
                            ),
                            _buildCompanyDetailItem(
                              context:context,
                              icon: Icons.language,
                              title: 'Website',
                              value: job['companyDetails']['website'],
                            ),
                            _buildCompanyDetailItem(
                              context:context,
                              icon: Icons.email,
                              title: 'Email',
                              value:  job['companyDetails']['email'],
                            ),
                            _buildCompanyDetailItem(
                              context:context,
                              icon: Icons.phone,
                              title: 'Contact No.',
                              value: job['companyDetails']['phone'],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // // Similar Jobs
                  // _buildSection(
                  //   context: context,
                  //   title: 'Similar Jobs',
                  //   icon: Icons.work,
                  //   child: Column(
                  //     children: [
                  //       for (var similarJob in job['similarJobs'])
                  //         Container(
                  //           margin: const EdgeInsets.only(bottom: 12),
                  //           padding: const EdgeInsets.all(16),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(12),
                  //             border: Border.all(color: Colors.grey[200]!),
                  //             boxShadow: [
                  //               BoxShadow(
                  //                 color: Colors.grey.withOpacity(0.05),
                  //                 blurRadius: 8,
                  //                 offset: const Offset(0, 2),
                  //               ),
                  //             ],
                  //           ),
                  //           child: Row(
                  //             children: [
                  //               Expanded(
                  //                 child: Column(
                  //                   crossAxisAlignment: CrossAxisAlignment.start,
                  //                   children: [
                  //                     Text(
                  //                       similarJob['title'],
                  //                       style: const TextStyle(
                  //                         fontSize: 16,
                  //                         fontWeight: FontWeight.w600,
                  //                       ),
                  //                     ),
                  //                     const SizedBox(height: 4),
                  //                     Text(
                  //                       similarJob['company'],
                  //                       style: TextStyle(
                  //                         fontSize: 14,
                  //                         color: Colors.grey[600],
                  //                       ),
                  //                     ),
                  //                     const SizedBox(height: 8),
                  //                     Row(
                  //                       children: [
                  //                         Icon(Icons.currency_rupee, size: 14, color: Colors.green.shade600),
                  //                         const SizedBox(width: 4),
                  //                         Text(
                  //                           similarJob['salary'],
                  //                           style: TextStyle(
                  //                             fontSize: 13,
                  //                             color: Colors.green.shade600,
                  //                             fontWeight: FontWeight.w500,
                  //                           ),
                  //                         ),
                  //                         const SizedBox(width: 16),
                  //                         Icon(Icons.location_on, size: 14, color: Colors.blue.shade600),
                  //                         const SizedBox(width: 4),
                  //                         Text(
                  //                           similarJob['location'],
                  //                           style: TextStyle(
                  //                             fontSize: 13,
                  //                             color: Colors.blue.shade600,
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //               Icon(
                  //                 Icons.arrow_forward_ios,
                  //                 size: 18,
                  //                 color: Colors.grey[400],
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // Apply Button
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.send, size: 20),
                label: const Text(
                  'Apply Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
              ),
              icon: Icon(
                Icons.message,
                color: Colors.blue.shade700,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.theme.primaryColorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: context.theme.primaryColor
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style:context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
              // const TextStyle(
              //   fontSize: 18,
              //   fontWeight: FontWeight.w700,
              //   color: Colors.black87,
              // ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      /*decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),*/
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)
                  // TextStyle(
                  //   fontSize: 12,
                  //   color: Colors.grey[600],
                  // ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  style:context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
                  // TextStyle(
                  //   fontSize: 14,
                  //   fontWeight: FontWeight.w600,
                  //   color: Colors.grey[800],
                  // ),

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}