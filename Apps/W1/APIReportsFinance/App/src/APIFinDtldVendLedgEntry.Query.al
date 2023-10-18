namespace Microsoft.API.FinancialManagement;

using Microsoft.Purchases.Payables;

query 30304 "API Fin - Dtld Vend Ledg Entry"
{
    QueryType = API;
    EntityCaption = 'Detailed Vendor Ledger Entry';
    EntityName = 'detailedVendorLedgerEntry';
    EntitySetName = 'detailedVendorLedgerEntries';
    APIGroup = 'reportsFinance';
    APIPublisher = 'microsoft';
    APIVersion = 'beta';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(detailedCustLedgerEntry; "Detailed Vendor Ledg. Entry")
        {
            column(entryNumber; "Entry No.")
            {
                Caption = 'Entry Number';
            }
            column(entryType; "Entry Type")
            {
                Caption = 'Entry Number';
            }
            column(vendorNumber; "Vendor No.")
            {
                Caption = 'Vendor Number';
            }
            column(amount; Amount)
            {
                Caption = 'Amount';
            }
            column(debitAmount; "Debit Amount")
            {
                Caption = 'Debit Amount';
            }
            column(creditAmount; "Credit Amount")
            {
                Caption = 'Credit Amount';
            }
            column(amountLocalCurrency; "Amount (LCY)")
            {
                Caption = 'Amount (LCY)';
            }
            column(debitAmountLocalCurrency; "Debit Amount (LCY)")
            {
                Caption = 'Debit Amount (LCY)';
            }
            column(creditAmountLocalCurrency; "Credit Amount (LCY)")
            {
                Caption = 'Credit Amount (LCY)';
            }
            column(initialEntryGLobalDim1; "Initial Entry Global Dim. 1")
            {
                Caption = 'Initial Entry Global Dimension 1';
            }
            column(initialEntryGLobalDim2; "Initial Entry Global Dim. 2")
            {
                Caption = 'Initial Entry Global Dimension 1';
            }
            column(postingDate; "Posting Date")
            {
                Caption = 'Date Filter';
            }
            column(currencyCode; "Currency Code")
            {
                Caption = 'Currency Code';
            }
            column(lastModifiedDateTime; SystemModifiedAt)
            {
                Caption = 'Last  Modified Date Time';
            }
        }
    }
}