import '../../../shared/models/paginated_response.dart';
import 'category_breakdown_item.dart';

/// Mirrors the backend's `CategoryReportDto` (`GET /reports/category`) —
/// same paginated envelope shape as everything else, items sorted by
/// highest amount first.
typedef CategoryReport = PaginatedResponse<CategoryBreakdownItem>;
