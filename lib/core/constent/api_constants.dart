class ApiConstants {
    ApiConstants._();

    static const String baseUrl = "https://greenyellow-grouse-707123.hostingersite.com";
    static const String imageBaseUrl = "$baseUrl/storage/";
    static const String apiBaseUrl = "$baseUrl/api/";

    static const String xApiKey = "X-API-KEY";
    static const String xApiValue = "vov5_EpoeWDnr0YSMZ83VTY4c39oi09HXhkrz";
    static const String authorization = "Authorization";

    // User Auth Endpoints
    static const String authRegister = "auth/register";
    static const String authLogin = "auth/login";
    static const String authGoogleLogin = "auth/google-login";
    static const String authChangePassword = "auth/change-password";
    static const String authLogout = "auth/logout";
    static const String authProfile = "auth/profile"; // GET current user
    static const String authProfileUpdate = "auth/profile"; // PUT update profile
    static const String forgotPassword = "auth/password/forgot";
    static const String resetPassword = "auth/password/reset";


    // Bussiness Api
    static const String allBusiness = "business";
    static const String getSingleBusiness = "business";
    static const String getBusinessProducts = "business";
    static const String getBusinessServices = "business";
    static const String updateBusinessServices = "business";
    static const String deleteBusinessServices = "business";

    static const String regBusiness = "business/register";
    static const String myBusinesses = "business/my-businesses";

    static const String addBusinessProduct = "business/products";
    static const String addBusinessService = "business/services";
    static const String searchBusiness = "search/search_business";
    
    static const String getCategory = "category";
    static const String getCategoryDetails = "category";
    static const String registerCategory = "category/register";

    static const String getCategoryBusiness = "business/category";


    // Matrimony Api
    static const String GetMatrimonyProfile = "matrimony/profile_user_id";
    static const String matrimonyProfile = "matrimony/profile";
    static const String searchMatrimony = "search/matrimony";
    static const String connectionRequest = "matrimony/connection-request";
    static const String connectionRequests = "matrimony/connection-requests";
    static const String matrimonyConversations = "matrimony/conversations";
    static const String matrimonySendMessage = "matrimony/send-message";
    static const String matrimonyMessages = "matrimony/messages"; // matrimony/messages/{conversation_id}
    static const String matrimonyRemoveRequest = "matrimony/remove-request";
    static const String matrimonyConnectedUsers = "matrimony/connected-users";
    static const String matrimonyCasts = "matrimony/casts";
    static const String matrimonySubCasts = "matrimony/casts"; // matrimony/casts/{id}/subcasts
    static const String matrimonySubscriptionPlans = "plans/matrimony";

    // Payment Api
    static const String createOrderBusiness = "payment/create-order/business";
    static const String createOrderMatrimony = "payment/create-order/matrimony";
    static const String verifyPayment = "payment/verify";
    static const String matrimonyPlans = "plans/matrimony";
    static const String businessSubscriptionPlans = "plans/business";
    static const String paymentTransactions = "payment/transactions";
    static const String donationCauses = "donation/causes";
    static const String donationCreateOrder = "donation/create-order";
    static const String donationVerifyPayment = "donation/verify-payment";

    // Volunteer Api
    static const String volunteerProfile = "volunteer/profile";
    static const String allVolunteer = "volunteer/opportunities";
    static const String volunteerOpportunity = "volunteer/opportunity";
    static const String searchVolunteers = "search/volunteer-profiles";

    // Job Api
    static const String createJobs = "jobs";
    static const String jobsById = "jobs";
    static const String jobsUpdate = "jobs";
    static const String jobsDelete = "jobs";
    static const String jobsByBusinessId = "jobs";
    static const String toggleJobStatus = "jobs";
    static const String jobAnalytics = "jobs/analytics";
    static const String applyJob = "jobs/apply";
    static const String myApplications = "jobs/my-applications";
    static const String getJobApplications = "jobs"; // jobs/{id}/applications
    static const String updateApplicationStatus = "jobs/applications"; // jobs/applications/{id}/status

    // Notification Api
    static const String getNotifications = "notifications";
    static const String getUnreadCount = "notifications/unread-count";
    static const String deleteNotification = "notifications";
    static const String deleteMultipleNotifications = "notifications";

    // Banner Api
    static const String getBanner = "banner";

    static const String matrimonyPymentOrder = "payment/create-order/matrimony";
    static const String paymentVerify = "payment/verify";
    static const String businessPymentOrder = "payment/create-order/business";

    // Blogs Api
    static const String getBlogs = "blogs";
    static const String getBlogDetail = "blogs"; // blogs/{id}
    static const String toggleBlogLike = "blogs"; // blogs/{id}/like
    static const String searchBlogs = "blogs/search";

    // Legal URLs
    static const String privacyPolicyUrl = "$baseUrl/privacy-policy";
    static const String termsConditionsUrl = "$baseUrl/terms-condition";
}
