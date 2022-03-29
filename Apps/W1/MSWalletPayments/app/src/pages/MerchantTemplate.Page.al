#if not CLEAN20
page 1081 "MS - Wallet Merchant Template"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    Caption = 'Microsoft Pay Payments Template';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "MS - Wallet Merchant Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default name of the Microsoft Pay Payments service.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default description of the Microsoft Pay Payments service.';
                }
                field(Logo; Logo)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default logo for the Microsoft Pay Payments service.';
                }
                field(PaymentRequestURL; PaymentRequestURL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Request URL';
                    MultiLine = true;
                    ToolTip = 'Specifies the default payment request URL that will be used for the Microsoft Pay Payments service.';

                    trigger OnValidate();
                    var
                        MSWalletMgt: Codeunit "MS - Wallet Mgt.";
                    begin
                        MSWalletMgt.ValidateChangePaymentRequestURL();
                        SetPaymentRequestURL(PaymentRequestURL);
                    end;
                }
                field("Terms of Service"; "Terms of Service")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the terms of use for the Microsoft Pay Payments service.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ResetToDefault)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reset To Default';
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Reset the values to the default.';

                trigger OnAction();
                var
                    MSWalletMgt: Codeunit "MS - Wallet Mgt.";
                begin
                    MSWalletMgt.TemplateAssignDefaultValues(Rec);
                    MESSAGE(SetToDefaultMsg);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    begin
        PaymentRequestURL := GetPaymentRequestURL();
    end;

    trigger OnOpenPage();
    var
        TempMSWalletMerchantTemplate: Record 1081 temporary;
        MSWalletMgt: Codeunit "MS - Wallet Mgt.";
    begin
        IF NOT GET() THEN BEGIN
            MSWalletMgt.GetTemplate(TempMSWalletMerchantTemplate);
            TRANSFERFIELDS(TempMSWalletMerchantTemplate);
            INSERT();
        END;
    end;

    var
        PaymentRequestURL: Text;
        SetToDefaultMsg: Label 'The settings have been reset to the default.';
}
#endif