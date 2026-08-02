package com.example.cashstack

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen glance widget: current balance, this month's income/expense,
 * and budget progress. Data is pushed from Dart via
 * `lib/core/home_widget/home_widget_sync_service.dart` whenever the
 * Dashboard refreshes — this provider only ever reads what was last saved,
 * it never fetches anything itself.
 */
class BalanceWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.balance_widget).apply {
            setTextViewText(
                R.id.widget_balance,
                widgetData.getString("balance_display", null) ?: "—",
            )
            setTextViewText(
                R.id.widget_income,
                widgetData.getString("income_display", null) ?: "—",
            )
            setTextViewText(
                R.id.widget_expense,
                widgetData.getString("expense_display", null) ?: "—",
            )

            val hasBudget = widgetData.getBoolean("has_budget", false)
            if (hasBudget) {
              setViewVisibility(R.id.widget_budget_section, View.VISIBLE)
              val progress = widgetData.getInt("budget_progress", 0)
              setProgressBar(R.id.widget_budget_progress, 100, progress, false)
              val label = widgetData.getString("budget_label", null)
              if (label != null) {
                setTextViewText(R.id.widget_budget_label, label)
              }
            } else {
              setViewVisibility(R.id.widget_budget_section, View.GONE)
            }

            val pendingIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            setOnClickPendingIntent(R.id.widget_root, pendingIntent)
          }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
