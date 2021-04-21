pageextension 11767 "Customer List CZL" extends "Customer List"
{
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