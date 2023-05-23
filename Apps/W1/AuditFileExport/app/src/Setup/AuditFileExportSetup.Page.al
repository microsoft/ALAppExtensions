page 5264 "Audit File Export Setup"
{
    PageType = Card;
    SourceTable = "Audit File Export Setup";
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    Caption = 'Audit File Export Setup';
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(AuditFileExportFormatCode; Rec."Audit File Export Format")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default audit file export format code.';
                }
            }
            group("Data Quality")
            {
                field(CheckCompanyInformation; Rec."Check Company Information")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to be notified about fields that have not been set up correctly in the Company Information.';
                }
                field(CheckCustomer; Rec."Check Customer")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to be notified about fields that have not been set up correctly for specific customers.';
                }
                field(CheckVendor; Rec."Check Vendor")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to be notified about fields that have not been set up correctly for specific vendors';
                }
                field(CheckBankAccount; Rec."Check Bank Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to be notified about fields that have not been set up correctly for specific bank accounts.';
                }
                field(CheckPostCode; Rec."Check Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to be notified about the post code that has not been set up correctly.';
                }
                field(CheckAddress; Rec."Check Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to be notified about the address that has not been set up correctly.';
                }
                field(DefaultPostCode; Rec."Default Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the post code to use when no values specified in the customer or vendor card.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;

}
