namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Purchases.Payables;
using Microsoft.Purchases.History;

query 36963 "Vendor Ledger Entries"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Vendor Ledger Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'vendorLedgerEntry';
    EntitySetName = 'vendorLedgerEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(VendorLedgerEntry; "Vendor Ledger Entry")
        {
            column(vleEntryNo; "Entry No.")
            {
            }
            column(vleDueDate; "Due Date")
            {
            }
            column(vleOpen; Open)
            {
            }
            column(vlePostingDate; "Posting Date")
            {
            }
            column(vleDocumentDate; "Document Date")
            {
            }
            column(vleDimensionSetID; "Dimension Set ID")
            {
            }
            dataitem(DetailedVendLedgerEntry; "Detailed Vendor Ledg. Entry")
            {
                DataItemLink = "Vendor Ledger Entry No." = VendorLedgerEntry."Entry No.";
                column(dvleEntryNo; "Entry No.")
                {
                }
                column(dvlePostingDate; "Posting Date")
                {
                }
                column(dvleLedgerEntryAmount; "Ledger Entry Amount")
                {
                }
                column(dvleEntryType; "Entry Type")
                {
                }
                column(dvleDocumentType; "Document Type")
                {
                }
                column(dvleDocumentNo; "Document No.")
                {
                }
                column(dvleInitialEntryDueDate; "Initial Entry Due Date")
                {
                }
                column(dvleAmountLCY; "Amount (LCY)")
                {
                }
                column(dvleVendorNo; "Vendor No.")
                {
                }
                column(dvleApplicationNo; "Application No.")
                {
                }
                column(dvleAppliedVendLedgerEntryNo; "Applied Vend. Ledger Entry No.")
                {
                }
                dataitem(PurchaseInvHeader; "Purch. Inv. Header")
                {
                    DataItemLink = "No." = DetailedVendLedgerEntry."Document No.";
                    SqlJoinType = LeftOuterJoin;
                    column(purchInvHeaderDocumentNo; "No.")
                    {
                    }
                    column(purchInvHeaderPaymentTermsCode; "Payment Terms Code")
                    {
                    }
                    column(purchInvHeaderPmtDiscountDate; "Pmt. Discount Date")
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
        DateFilterText := PBIMgt.GenerateVLEReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(vlePostingDate, DateFilterText);
    end;
}