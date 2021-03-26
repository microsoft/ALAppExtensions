page 1073 "MS - PayPal Standard Accounts"
{
    Caption = 'PayPal Payments Standard Accounts';
    CardPageID = "MS - PayPal Standard Setup";
    Editable = false;
    InsertAllowed = false;
    UsageCategory = Administration;
    PageType = List;
    SourceTable = "MS - PayPal Standard Account";
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the PayPal Standard account.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the PayPal Standard account description.';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the PayPal Standard account is enabled.';
                }
                field("Always Include on Documents"; "Always Include on Documents")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to make this PayPal Standard account available on all documents.';
                }
                field("Account ID"; "Account ID")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the account id.';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(NewAction)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'New';
                Image = NewDocument;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Creates a new PayPal Standard account.';

                trigger OnAction();
                var
                    TempPaymentServiceSetup: Record 1060 temporary;
                    MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
                begin
                    MSPayPalStandardMgt.RegisterPayPalStandardTemplate(TempPaymentServiceSetup);
                    TempPaymentServiceSetup.OnCreatePaymentService(TempPaymentServiceSetup);
                end;
            }
        }
    }
}

