namespace Microsoft.SubscriptionBilling;

using System.Globalization;

page 8030 "Field Translations"
{
    Caption = 'Field Translations';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Field Translation";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table ID field.';
                    ShowMandatory = true;
                    Visible = false;
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field.';
                    ShowMandatory = true;
                    Visible = false;
                }
                field(SourceTextCtrl; Rec.GetSourceText())
                {
                    ApplicationArea = All;
                    Caption = 'Source Text';
                    Editable = false;
                    ToolTip = 'Specifies the value of field being translated.';
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the language to be used on printouts.';
                }
                field(PrimaryLanguageIDCtrl; GetPrimaryLanguageID())
                {
                    ApplicationArea = All;
                    Caption = 'Primary Language ID';
                    ToolTip = 'Specifies the value of the Primary Language ID field.';
                    Visible = false;
                }
                field(Translation; Rec.Translation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the equivalent text for selected language.';
                }
                field("Source SystemId"; Rec."Source SystemId")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source SystemId field.';
                    Visible = false;
                }
            }
        }
    }

    local procedure GetPrimaryLanguageID(): Integer
    var
        WindowsLanguage: Record "Windows Language";
        Language: Codeunit Language;
    begin
        if WindowsLanguage.Get(Language.GetLanguageIdOrDefault(Rec."Language Code")) then
            exit(WindowsLanguage."Primary Language ID");
        exit(0);
    end;
}