package com.example.cashstack

/** Kotlin port of `TransactionNotificationParser` (see lib/features/transaction_detection).
 *
 * Kept in sync by hand — this one runs inside [NativeNotificationCaptureReceiver], which has
 * to work without the Dart VM, so the regex logic can't be shared directly.
 */
object BankNotificationParser {
    private val amountPattern =
        Regex("""(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)""", RegexOption.IGNORE_CASE)
    private val debitPattern =
        Regex("""\b(debited|debit|spent|paid|withdrawn|purchase)\b""", RegexOption.IGNORE_CASE)
    private val creditPattern =
        Regex("""\b(credited|credit|received|deposited)\b""", RegexOption.IGNORE_CASE)

    data class Candidate(val amount: Double, val isExpense: Boolean)

    fun parse(text: String): Candidate? {
        val amountMatch = amountPattern.find(text) ?: return null
        val amount = amountMatch.groupValues[1].replace(",", "").toDoubleOrNull() ?: return null
        if (amount <= 0) return null

        val isDebit = debitPattern.containsMatchIn(text)
        val isCredit = creditPattern.containsMatchIn(text)
        if (isDebit == isCredit) return null // neither, or ambiguous — skip rather than guess

        return Candidate(amount = amount, isExpense = isDebit)
    }
}
