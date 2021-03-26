pageextension 11704 "Customer Card CZL" extends "Customer Card"
{
    layout
    {
        addafter("VAT Registration No.")
        {
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of customer.';

                trigger OnDrillDown()
                var
                    RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
                begin
                    CurrPage.SaveRecord();
                    RegistrationLogMgtCZL.AssistEditCustomerRegNo(Rec);
                    CurrPage.Update(false);
                end;
            }
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the customer.';
                Importance = Additional;
            }
        }
        addafter(PricesandDiscounts)
        {
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';

                field("Transaction Type CZL"; Rec."Transaction Type CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default Transaction type for Intrastat reporting purposes.';
                }
                field("Transaction Specification CZL"; Rec."Transaction Specification CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default Transaction specification for Intrastat reporting purposes.';
                }
                field("Transport Method CZL"; Rec."Transport Method CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default Transport Method for Intrastat reporting purposes.';
                }
            }
        }
    }
    actions
    {
        addafter(BackgroundStatement)
        {
            action("Balance Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance Reconciliation';
                Image = Balance;
                Promoted = true;
                PromotedCategory = "Report";
                ToolTip = 'Open the report for customer''s balance reconciliation.';

                trigger OnAction()
                begin
                    RunReport(Report::"Cust.- Bal. Reconciliation CZL", Rec."No.");
                end;
            }
        }
    }
}
