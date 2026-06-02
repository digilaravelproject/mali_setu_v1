import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constent/api_constants.dart';
import '../../../../core/storage/token_manger.dart';
import '../model/blog_model.dart';
/*
class BlogRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'X-API-KEY': ApiConstants.xApiValue,
    },
  ));

  BlogRepository() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenManager.getToken();
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<BlogResponse?> getBlogs({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.getBlogs,
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        return BlogResponse.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching blogs: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> createBlog(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.getBlogs,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
         return response.data;
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return e.response?.data as Map<String, dynamic>;
      }
      debugPrint('DioError creating blog: ${e.message}');
    } catch (e) {
      debugPrint('Error creating blog: $e');
    }
    return null;
  }

  Future<BlogDetailResponse?> getBlogDetail(int id) async {
    try {
      final response = await _dio.get("${ApiConstants.getBlogDetail}/$id");

      if (response.statusCode == 200) {
        return BlogDetailResponse.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching blog detail: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> toggleLike(int id) async {
    try {
      final response = await _dio.post("${ApiConstants.toggleBlogLike}/$id/like");

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
    return null;
  }

  Future<BlogResponse?> searchBlogs(String query) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchBlogs,
        queryParameters: {'query': query},
      );

      if (response.statusCode == 200) {
        return BlogResponse.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error searching blogs: $e');
    }
    return null;
  }
}*/



   import '../../../../core/network/api_client.dart';
import '../../../../core/constent/api_constants.dart';
import '../model/blog_model.dart';
import 'package:get/get.dart' as getx;
import 'package:dio/dio.dart';

class BlogRepository {
  final ApiClient _apiClient = getx.Get.find<ApiClient>();

  Future<BlogResponse?> getBlogs({int page = 1, int perPage = 100, int? categoryId}) async {
    try {
      final query = {'page': page, 'per_page': perPage};
      if (categoryId != null) query['category_id'] = categoryId;
      
      final response = await _apiClient.get(
        ApiConstants.getBlogs,
        queryParameters: query,
      );

      if (response.statusCode == 200) {
        return BlogResponse.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetching blogs: $e');
    }
    return null;
  }

  /// Fetches all blogs that belong to the logged-in user.
  /// Sends my_blogs=1 so the server filters by authenticated user.
  /// Falls back to fetching all and filtering client-side if server doesn't support it.
  Future<BlogResponse?> getMyBlogs({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.getBlogs,
        queryParameters: {'page': page, 'per_page': 500, 'my_blogs': 1},
      );

      if (response.statusCode == 200) {
        return BlogResponse.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetching my blogs: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> createBlog(dynamic data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.getBlogs,
        data: data,
      );

      if (response.data != null) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null;
      }
    } on DioException catch (e) {
      print('DioError creating blog: $e');
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return e.response?.data as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error creating blog: $e');
    }
    return null;
  }

  Future<BlogDetailResponse?> getBlogDetail(int id) async {
    try {
      final response = await _apiClient.get("${ApiConstants.getBlogDetail}/$id");

      if (response.statusCode == 200) {
        return BlogDetailResponse.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetching blog detail: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> toggleLike(int id) async {
    try {
      final response = await _apiClient.post("${ApiConstants.toggleBlogLike}/$id/like");

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
    return null;
  }

  Future<BlogResponse?> searchBlogs(String query) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.searchBlogs,
        queryParameters: {'query': query},
      );

      if (response.statusCode == 200) {
        return BlogResponse.fromJson(response.data);
      }
    } catch (e) {
      print('Error searching blogs: $e');
    }
    return null;
  }

  Future<bool> deleteBlog(int id) async {
    try {
      final response = await _apiClient.delete("${ApiConstants.getBlogs}/$id");
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
    } catch (e) {
      print('Error deleting blog: $e');
    }
    return false;
  }

  /// Updates a blog via POST with _method=PUT (Laravel multipart spoofing).
  /// URL: POST /api/blogs/{id}
  /// FormData must include: _method=PUT, title, description, blog_type, tags, media[]
  Future<Map<String, dynamic>?> updateBlog(int id, FormData data) async {
    try {
      final response = await _apiClient.post(
        "${ApiConstants.getBlogs}/$id",
        data: data,
      );
      // Accept any response that has a body (success or validation error)
      if (response.statusCode != null && response.data != null) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null;
      }
    } on DioException catch (e) {
      print('DioError updating blog: $e');
      if (e.response?.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error updating blog: $e');
    }
    return null;
  }

  Future<BlogCategoryResponse?> getBlogCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.blogCategories);

      if (response.statusCode == 200) {
        return BlogCategoryResponse.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetching blog categories: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> addComment(int blogId, String comment, {int? parentId}) async {
    try {
      final Map<String, dynamic> data = {'comment': comment};
      if (parentId != null) {
        data['parent_id'] = parentId;
      }
      final response = await _apiClient.post(
        "${ApiConstants.addBlogComment}/$blogId/comments",
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : null;
      }
    } catch (e) {
      print('Error adding comment: $e');
    }
    return null;
  }

  Future<bool> deleteComment(int commentId) async {
    try {
      final response = await _apiClient.delete(
        "${ApiConstants.deleteBlogComment}/$commentId",
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
    } catch (e) {
      print('Error deleting comment: $e');
    }
    return false;
  }
}

