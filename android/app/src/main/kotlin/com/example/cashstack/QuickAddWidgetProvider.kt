package com.example.cashstack

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Static two-button widget: Add Expense / Add Income. No data to display,
 * so unlike [BalanceWidgetProvider] this never needs `widgetData` — tapping
 * either button launches the app with a `cashstack://add?type=` URI that
 * `lib/core/home_widget/home_widget_launch_handler.dart` reads to open the
 * Add Transaction form pre-filled with that type.
 */
class QuickAddWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.quick_add_widget).apply {
            setOnClickPendingIntent(
                R.id.widget_add_expense,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("cashstack://add?type=EXPENSE"),
                ),
            )
            setOnClickPendingIntent(
                R.id.widget_add_income,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("cashstack://add?type=INCOME"),
                ),
            )
          }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
