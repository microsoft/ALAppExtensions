namespace Microsoft.Bank.PayPal;


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
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default name for the PayPal payment service.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default description for the PayPal payment service.';
                }
                field(Logo; Rec.Logo)
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
                        Rec.SetTargetURL(ServiceTargetURL);
                    end;
                }
                field("Terms of Service"; Rec."Terms of Service")
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
                        Rec.SetLogoURL(ServiceLogoURL);
                    end;
                }
                field("Logo Update Frequency"; Rec."Logo Update Frequency")
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
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(ResetToDefault_Promoted; ResetToDefault)
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    begin
        ServiceLogoURL := Rec.GetLogoURL();
        ServiceTargetURL := Rec.GetTargetURL();
    end;

    trigger OnOpenPage();
    var
        TempMSPayPalStandardTemplate: Record 1071 temporary;
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
    begin
        if not Rec.GET() then begin
            MSPayPalStandardMgt.GetTemplate(TempMSPayPalStandardTemplate);
            Rec.TRANSFERFIELDS(TempMSPayPalStandardTemplate);
            Rec.INSERT();
        end;
    end;

    var
        ServiceLogoURL: Text;
        ServiceTargetURL: Text;
        SetToDefaultMsg: Label 'Settings have been set to default.';
}



