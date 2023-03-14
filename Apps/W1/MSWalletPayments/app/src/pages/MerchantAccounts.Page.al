#if not CLEAN20
page 1083 "MS - Wallet Merchant Accounts"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    Caption = 'Microsoft Pay Payments Accounts';
    CardPageID = "MS - Wallet Merchant Setup";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "MS - Wallet Merchant Account";
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the Name of the merchant account.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the description.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies whether the merchant account is enabled.';
                }
                field("Always Include on Documents"; Rec."Always Include on Documents")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies whether the merchant should always be included on documents.';
                }
                field("Merchant ID"; Rec."Merchant ID")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Tooltip = 'Specifies the merchant id.';
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
                ToolTip = 'Creates a new Microsoft Pay Payments merchant account.';

                trigger OnAction();
                var
                    TempPaymentServiceSetup: Record 1060 temporary;
                    MSWalletMgt: Codeunit "MS - Wallet Mgt.";
                begin
                    MSWalletMgt.RegisterMSWalletTemplate(TempPaymentServiceSetup);
                    TempPaymentServiceSetup.OnCreatePaymentService(TempPaymentServiceSetup);
                end;
            }
        }
    }
}
#endif