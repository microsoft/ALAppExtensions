namespace Microsoft.Finance.RoleCenters;

using Microsoft.Sales.Receivables;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;

page 1954 "LP - Invoices at Risk"
{
    PageType = ListPart;
    SourceTable = "Cust. Ledger Entry";
    Caption = 'Invoices at risk';
    DeleteAllowed = false;
    InsertAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(OverdueCustomers)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document number of the open invoice.';

                    trigger OnDrillDown()
                    var
                        SalesInvoiceHeader: Record "Sales Invoice Header";
                    begin
                        if not SalesInvoiceHeader.Get(Rec."Document No.") then
                            Page.Run(Page::"Customer Ledger Entries", Rec)
                        else
                            Page.Run(Page::"Posted Sales Invoice", SalesInvoiceHeader);
                    end;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the customer.';

                    trigger OnDrillDown()
                    var
                        Customer: Record Customer;
                    begin
                        Customer.Get(Rec."Customer No.");
                        Page.Run(Page::"Customer Card", Customer);
                    end;
                }
                field("Remaining Amount (LCY)"; Rec."Remaining Amt. (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the remaining amount to be paid for this invoice.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the due date of the invoice.';
                }
                field("Payment Prediction"; Rec."Payment Prediction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this invoice will be paid on time. Configure in the Late Payment Prediction Setup page how this field is computed.';
                }
                field("Prediction Confidence %"; Rec."Prediction Confidence %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the confidence level of the payment prediction.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Document Type", Rec."Document Type"::Invoice);
        Rec.SetRange(Open, true);
        Rec.SetFilter("Remaining Amount", '>%1', 0);
        Rec.SetFilter("Due Date", '>=%1', WorkDate());
        Rec.SetCurrentKey("Due Date");
        Rec.SetAscending("Due Date", true);
        Rec.FilterGroup(0);
    end;
}