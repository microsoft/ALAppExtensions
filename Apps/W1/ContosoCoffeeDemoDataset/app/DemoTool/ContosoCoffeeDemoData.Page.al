page 4762 "Contoso Coffee Demo Data"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Contoso Coffee Demo Data Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    Extensible = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Starting Year"; Rec."Starting Year")
                {
                    ToolTip = 'Specifies the Starting Year that you want to create the demo data with.';
                }
                field("Company Type"; Rec."Company Type")
                {
                    ToolTip = 'Specifies the Company Type that you want to create the demo data with.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the Country or Region Code that you want to create the demo data with.';
                }
                field("Language Name"; Language.GetWindowsLanguageName(Rec."Language ID"))
                {
                    ToolTip = 'Specifies the Language Name that you create the demo data with for the first time.';
                    Editable = false;
                    Caption = 'Language Name';
                }
            }
            group(Pricing)
            {
                Caption = 'Price/cost factor and rounding';
                field("Price Factor"; Rec."Price Factor")
                {
                    ToolTip = 'Specifies the Price Factor that you want to create the demo data with.';
                }
                field("Rounding Precision"; Rec."Rounding Precision")
                {
                    ToolTip = 'Specifies the Rounding Precision that you want to create the demo data with.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitRecord();
    end;

    var
        Language: Codeunit Language;
}