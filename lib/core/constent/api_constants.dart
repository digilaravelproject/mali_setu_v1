class ApiConstants {
    ApiConstants._();

    static const String baseUrl = "https://greenyellow-grouse-707123.hostingersite.com/public";
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
    
    static const String getCategory = "category";
    static const String getCategoryDetails = "category";

    // Matrimony Api
    static const String matrimonyProfile = "matrimony/profile";

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

    // Notification Api
    static const String getNotifications = "notifications";
    static const String getUnreadCount = "notifications/unread-count";
    static const String deleteNotification = "notifications";
    static const String deleteMultipleNotifications = "notifications";
}
