#if not CLEAN20
page 1089 "MS - Wallet Merchant Callback"
{

    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    Caption = 'Confirm';
    Editable = false;
    PageType = NavigatePage;

    layout
    {
        area(Content)
        {
            group(MsPayMerchantGroup)
            {
                Caption = 'Microsoft Pay Payments Setup';
                InstructionalText = ' ';
            }
            group(MsPayMerchantSignupUrlGroup)
            {
                ShowCaption = false;
                InstructionalText = 'If you didn''t see the Microsoft Pay Payments page, your browser might block pop-ups. Allow pop-ups, or copy the following URL in a new browser window.';
                field(MerchantSignupUrlControl; MerchantSignupUrl)
                {
                    ShowCaption = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = URL;
                }
            }

            group(MsPayMerchantDetails)
            {
                ShowCaption = false;
                InstructionalText = 'When you have finished adding your accounts on the Microsoft Pay Payments page, choose the Done button.';
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Done)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Done';
                Promoted = true;
                PromotedOnly = true;
                InFooterBar = true;
                ToolTip = 'Confirms that you set up your Microsoft Pay Payments account.';
                Image = Completed;

                trigger OnAction();
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        MerchantSignupUrl := MSWalletMerchantMgt.GetMerchantSignupUrl();
    end;

    var
        MSWalletMerchantMgt: Codeunit "MS - Wallet Merchant Mgt";
        MerchantSignupUrl: Text;
}
#endif