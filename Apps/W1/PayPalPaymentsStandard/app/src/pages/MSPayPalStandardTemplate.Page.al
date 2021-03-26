page 1071 "MS - PayPal Standard Template"
{
    Caption = 'PayPal Payments Standard Template';
    PageType = Card;
    SourceTable = "MS - PayPal Standard Template";

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
                    ToolTip = 'Specifies the default name for the PayPal payment service.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default description for the PayPal payment service.';
                }
                field(Logo; Logo)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default logo for the PayPal payment service.';
                }
                field(TargetURL; ServiceTargetURL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Target URL';
                    MultiLine = true;
                    ToolTip = 'Specifies the default target URL that will be used for the PayPal payment services.';

                    trigger OnValidate();
                    var
                        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
                    begin
                        MSPayPalStandardMgt.ValidateChangeTargetURL();
                        SetTargetURL(ServiceTargetURL);
                    end;
                }
                field("Terms of Service"; "Terms of Service")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the terms of use for the PayPal payment service.';
                }
                field(LogoURL; ServiceLogoURL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Logo URL';
                    MultiLine = true;
                    ToolTip = 'Specifies the URL from which the logo will be refreshed regularly.';

                    trigger OnValidate();
                    begin
                        SetLogoURL(ServiceLogoURL);
                    end;
                }
                field("Logo Update Frequency"; "Logo Update Frequency")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the frequency with which the logo is updated.';
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
                ToolTip = 'Resets values to default.';

                trigger OnAction();
                var
                    MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
                begin
                    MSPayPalStandardMgt.TemplateAssignDefaultValues(Rec);
                    MESSAGE(SetToDefaultMsg);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    begin
        ServiceLogoURL := GetLogoURL();
        ServiceTargetURL := GetTargetURL();
    end;

    trigger OnOpenPage();
    var
        TempMSPayPalStandardTemplate: Record 1071 temporary;
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
    begin
        IF NOT GET() THEN BEGIN
            MSPayPalStandardMgt.GetTemplate(TempMSPayPalStandardTemplate);
            TRANSFERFIELDS(TempMSPayPalStandardTemplate);
            INSERT();
        END;
    end;

    var
        ServiceLogoURL: Text;
        ServiceTargetURL: Text;
        SetToDefaultMsg: Label 'Settings have been set to default.';
}

