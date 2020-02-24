page 1083 "MS - Wallet Merchant Accounts"
{
    Caption = 'Microsoft Pay Payments Accounts';
    CardPageID = "MS - Wallet Merchant Setup";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = 1080;
    UsageCategory = Administration;
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
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Always Include on Documents"; "Always Include on Documents")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Merchant ID"; "Merchant ID")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
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
                ToolTip = 'Creates a new Microsoft Pay Payments merchant account.';

                trigger OnAction();
                var
                    TempPaymentServiceSetup: Record 1060 temporary;
                    MSWalletMgt: Codeunit 1080;
                begin
                    MSWalletMgt.RegisterMSWalletTemplate(TempPaymentServiceSetup);
                    TempPaymentServiceSetup.OnCreatePaymentService(TempPaymentServiceSetup);
                end;
            }
        }
    }
}

