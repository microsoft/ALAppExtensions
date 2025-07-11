namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Sales.Receivables;
using Microsoft.Sales.History;

query 36957 "Customer Ledger Entries"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Customer Ledger Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'customerLedgerEntry';
    EntitySetName = 'customerLedgerEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(CustomerLedgerEntry; "Cust. Ledger Entry")
        {
            column(cleEntryNo; "Entry No.")
            {
            }
            column(cleDueDate; "Due Date")
            {
            }
            column(cleOpen; Open)
            {
            }
            column(clePostingDate; "Posting Date")
            {
            }
            column(cleDocumentDate; "Document Date")
            {
            }
            column(cleDimensionSetID; "Dimension Set ID")
            {
            }
            dataitem(DetailedCustLedgEntry; "Detailed Cust. Ledg. Entry")
            {
                DataItemLink = "Cust. Ledger Entry No." = CustomerLedgerEntry."Entry No.";
                column(dcleEntryNo; "Entry No.")
                {
                }
                column(dclePostingDate; "Posting Date")
                {
                }
                column(dcleLedgerEntryAmount; "Ledger Entry Amount")
                {
                }
                column(dcleEntryType; "Entry Type")
                {
                }
                column(dcleDocumentType; "Document Type")
                {
                }
                column(dcleDocumentNo; "Document No.")
                {
                }
                column(dcleInitialEntryDueDate; "Initial Entry Due Date")
                {
                }
                column(dcleAmountLCY; "Amount (LCY)")
                {
                }
                column(dcleCustomerNo; "Customer No.")
                {
                }
                column(dcleApplicationNo; "Application No.")
                {
                }
                column(dcleAppliedCustLedgerEntryNo; "Applied Cust. Ledger Entry No.")
                {
                }
                dataitem(SalesInvoiceHeader; "Sales Invoice Header")
                {
                    DataItemLink = "No." = DetailedCustLedgEntry."Document No.";
                    SqlJoinType = LeftOuterJoin;
                    column(salesInvHeaderDocumentNo; "No.")
                    {
                    }
                    column(salesInvHeaderPaymentTermsCode; "Payment Terms Code")
                    {
                    }
                    column(salesInvHeaderPmtDiscountDate; "Pmt. Discount Date")
                    {
                    }
                }
            }
        }
    }

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "Finance Filter Helper";
        DateFilterText: Text;
    begin
        DateFilterText := PBIMgt.GenerateCLEReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(clePostingDate, DateFilterText);
    end;

}