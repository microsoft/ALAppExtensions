page 1074 "MS - PayPal Standard Settings"
{
    Caption = 'PayPal';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "MS - PayPal Standard Account";

    layout
    {
        area(content)
        {
            group("PayPal Information")
            {
                Caption = 'PayPal Information';
                InstructionalText = 'Enter your email address for PayPal payments.';
                field(AccountID; PayPalAccountID)
                {
                    ApplicationArea = Invoicing, Basic, Suite;
                    Caption = 'PayPal Email';
                    ExtendedDatatype = EMail;
                    ToolTip = 'Specifies the PayPal email.';

                    trigger OnValidate();
                    var
                        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
                    begin
                        MSPayPalStandardMgt.SetPaypalAccount(PayPalAccountID, false);
                        if FindFirst() then;
                    end;
                }
                field("Terms of Service"; TermsOfServiceLbl)
                {
                    ApplicationArea = Invoicing, Basic, Suite;
                    Caption = 'PayPal Terms of Service';
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies PayPal terms of service.';

                    trigger OnDrillDown();
                    begin
                        Hyperlink("Terms of Service");
                    end;
                }

                group(SandboxGroup)
                {
                    Visible = IsSandbox;
                    field(SandboxControl; IsSandbox)
                    {
                        ApplicationArea = Invoicing, Basic, Suite;
                        Editable = false;
                        Caption = 'Sandbox active';
                        ToolTip = 'Specifies whether the Sandbox is active.';
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord();
    begin
        PayPalAccountID := "Account ID";
        IsSandbox := (lowercase(GetTargetURL()) = lowercase(MSPayPalStandardMgt.GetSandboxURL()));
    end;

    trigger OnOpenPage();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
    begin
        IF ISEMPTY() THEN BEGIN
            MSPayPalStandardMgt.RegisterPayPalStandardTemplate(TempPaymentServiceSetup);

            MSPayPalStandardMgt.GetTemplate(MSPayPalStandardTemplate);
            MSPayPalStandardTemplate.RefreshLogoIfNeeded();
            TRANSFERFIELDS(MSPayPalStandardTemplate, FALSE);
            INSERT(TRUE);
        END;
    end;

    var
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
        PayPalAccountID: Text[250];
        IsSandbox: Boolean;
        TermsOfServiceLbl: Label 'Terms of service';
}

