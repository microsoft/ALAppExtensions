namespace Microsoft.Integration.Shopify;

page 30138 "Shpfy Languages"
{
    ApplicationArea = All;
    Caption = 'Shpfy Languages';
    PageType = List;
    SourceTable = "Shpfy Language";
    UsageCategory = None;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Locale; Rec.Locale)
                {
                    ToolTip = 'Specifies the shop locale to sync translations.';
                }
                field("Language Code"; Rec."Language Code")
                {
                    ToolTip = 'Specifies the language code for the locale.';
                }
                field("Sync Translations"; Rec."Sync Translations")
                {
                    ToolTip = 'Specifies if the translations should be synced for this locale.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Refresh;
                ToolTip = 'Refreshes the list of Shopify languages.';

                trigger OnAction()
                var
                    ShpfyTranslationAPI: Codeunit "Shpfy Translation API";
                begin
                    ShpfyTranslationAPI.PullLanguages(CopyStr(Rec.GetFilter("Shop Code"), 1, 20));
                end;
            }
        }
    }
}
