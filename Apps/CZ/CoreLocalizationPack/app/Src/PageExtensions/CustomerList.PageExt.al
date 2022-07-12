pageextension 11767 "Customer List CZL" extends "Customer List"
{
    layout
    {
        addafter(Contact)
        {
            field("VAT Registration No."; Rec."VAT Registration No.")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the customer''s VAT registration number for customers in EU countries/regions.';
            }
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of customer.';
            }
        }
    }

    actions
    {
        addafter(ReportCustomerPaymentReceipt)
        {
            action("Open Cust. Entries to Date CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Customer Entries to Date';
                Image = Report;
                RunObject = report "Open Cust. Entries to Date CZL";
                ToolTip = 'View, print, or send a report that shows Open Customer Entries to Date';
            }
        }
        addlast(reporting)
        {
            action("Balance Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance Reconciliation';
                Image = Balance;
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Cust.- Bal. Reconciliation CZL";
                ToolTip = 'Open the report for customer''s balance reconciliation.';
            }
        }
    }
}