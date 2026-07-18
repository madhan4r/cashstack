import '../../../shared/models/paginated_response.dart';
import 'account_report_item.dart';

/// Mirrors the backend's `AccountReportDto` (`GET /reports/account`).
typedef AccountReport = PaginatedResponse<AccountReportItem>;
