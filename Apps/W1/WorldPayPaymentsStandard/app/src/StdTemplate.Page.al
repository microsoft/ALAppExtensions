page 1361 "MS - WorldPay Std. Template"
{
    Caption = 'WorldPay Payments Standard Template';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "MS - WorldPay Std. Template";

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
                    ToolTip = 'Specifies the default name for the WorldPay payment service.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default description for the WorldPay payment service.';
                }
                field(Logo; Logo)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default logo for the WorldPay payment service.';
                }
                field(TargetURL; TargetURL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Target URL';
                    MultiLine = true;
                    ToolTip = 'Specifies the default target URL that will be used for the WorldPay payment services.';

                    trigger OnValidate()
                    var
                        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
                    begin
                        MSWorldPayStandardMgt.ValidateChangeTargetURL();
                        SetTargetURL(TargetURL);
                    end;
                }
                field("Terms of Service"; "Terms of Service")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the terms of use for the WorldPay payment service.';
                }
                field(LogoURL; LogoURL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Logo URL';
                    MultiLine = true;
                    ToolTip = 'Specifies the URL from which the logo will be refreshed regularly.';

                    trigger OnValidate()
                    begin
                        SetLogoURL(LogoURL);
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

                trigger OnAction()
                var
                    MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
                begin
                    MSWorldPayStandardMgt.TemplateAssignDefaultValues(Rec);
                    MESSAGE(SetToDefaultMsg);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        LogoURL := GetLogoURL();
        TargetURL := GetTargetURL();
    end;

    trigger OnOpenPage()
    var
        TempMSWorldPayStdTemplate: Record 1361 temporary;
        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
    begin
        IF NOT GET() THEN BEGIN
            MSWorldPayStandardMgt.GetTemplate(TempMSWorldPayStdTemplate);
            TRANSFERFIELDS(TempMSWorldPayStdTemplate);
            INSERT();
        END;
    end;

    var
        LogoURL: Text;
        TargetURL: Text;
        SetToDefaultMsg: Label 'Settings have been set to default.';
}

