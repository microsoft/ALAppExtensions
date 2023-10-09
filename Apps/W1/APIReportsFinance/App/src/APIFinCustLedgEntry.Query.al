namespace Microsoft.API.FinancialManagement;

using Microsoft.Sales.Receivables;

query 30302 "API Fin - Cust Ledg Entry"
{
    QueryType = API;
    EntityCaption = 'Customer Ledger Entry';
    EntityName = 'customerLedgerEntry';
    EntitySetName = 'customerLedgerEntries';
    APIGroup = 'reportsFinance';
    APIPublisher = 'microsoft';
    APIVersion = 'beta';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(custLedgerEntry; "Cust. Ledger Entry")
        {
            column(entryNumber; "Entry No.")
            {
                Caption = 'Entry Number';
            }
            column(documentType; "Document Type")
            {
                Caption = 'Document Type';
            }
            column(description; Description)
            {
                Caption = 'Description';
            }
            column(postingDate; "Posting Date")
            {
                Caption = 'Date Filter';
            }
            column(documentNumber; "Document No.")
            {
                Caption = 'Document Number';
            }
            column(externalDocumentNumber; "External Document No.")
            {
                Caption = 'External Document Number';
            }
            column(balancingAccountNumber; "Bal. Account No.")
            {
                Caption = 'Balancing Account Number';
            }
            column(balancingAccountType; "Bal. Account Type")
            {
                Caption = 'Bal. Account Type';
            }
            column(customerNumber; "Customer No.")
            {
                Caption = 'Customer Number';
            }
            column(open; Open)
            {
                Caption = 'Open';
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
            column(dimensionSetID; "Dimension Set ID")
            {
                Caption = 'Dimension Set ID';
            }
            column(debitAmountLocalCurrency; "Debit Amount (LCY)")
            {
                Caption = 'Debit Amount (LCY)';
            }
            column(creditAmountLocalCurrency; "Credit Amount (LCY)")
            {
                Caption = 'Credit Amount (LCY)';
            }
            column(currencyCode; "Currency Code")
            {
                Caption = 'Currency Code';
            }
            column(yourReference; "Your Reference")
            {
                Caption = 'Your Reference';
            }
            column(lastModifiedDateTime; SystemModifiedAt)
            {
                Caption = 'Last  Modified Date Time';
            }
        }
    }
}