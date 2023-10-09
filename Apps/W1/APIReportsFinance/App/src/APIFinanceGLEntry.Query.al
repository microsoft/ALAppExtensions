namespace Microsoft.API.FinancialManagement;

using Microsoft.Finance.GeneralLedger.Ledger;

query 30300 "API Finance - GL Entry"
{
    QueryType = API;
    EntityCaption = 'General Ledger Entry';
    EntityName = 'generalLedgerEntry';
    EntitySetName = 'generalLedgerEntries';
    APIGroup = 'reportsFinance';
    APIPublisher = 'microsoft';
    APIVersion = 'beta';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(GLEntry; "G/L Entry")
        {
            column(id; SystemId)
            {
                Caption = 'Id';
            }
            column(number; "Entry No.")
            {
                Caption = 'Number';
            }
            column(description; Description)
            {
                Caption = 'Description';
            }
            column(postingDate; "Posting Date")
            {
                Caption = 'Posting Date';
            }
            column(accountNumber; "G/L Account No.")
            {
                Caption = 'Account Number';
            }
            column(businessUnitCode; "Business Unit Code")
            {
                Caption = 'Business Unit Code';
            }
            column(reveresd; Reversed)
            {
                Caption = 'Reversed';
            }
            column(documentNumber; "Document No.")
            {
                Caption = 'Document Number';
            }
            column(externalDocumentNumber; "External Document No.")
            {
                Caption = 'External Document Number';
            }
            column(sourceType; "Source Type")
            {
                Caption = 'Source Type';
            }
            column(sourceNumber; "Source No.")
            {
                Caption = 'Source Number';
            }
            column(sourceCode; "Source Code")
            {
                Caption = 'Source Code';
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
            column(vatAmount; "VAT Amount")
            {
                Caption = 'VAT Amount';
            }
            column(additionalCurrencyAmount; "Additional-Currency Amount")
            {
                Caption = 'Additional Currency Amount';
            }
            column(dimensionSetID; "Dimension Set ID")
            {
                Caption = 'Dimension Set ID';
            }
            column(globalDimension1Code; "Global Dimension 1 Code")
            {
                Caption = 'Global Dimension 1 Code';
            }
            column(globalDimension2Code; "Global Dimension 2 Code")
            {
                Caption = 'Global Dimension 2 Code';
            }
            column(lastModifiedDateTime; SystemModifiedAt)
            {
                Caption = 'Last  Modified Date Time';
            }
        }
    }
}