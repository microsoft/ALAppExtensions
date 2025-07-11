namespace Microsoft.Sustainability.Certificate;

page 6243 "Sust. Certificate Card"
{
    PageType = Card;
    Caption = 'Sustainability Certificate Card';
    UsageCategory = Administration;
    SourceTable = "Sustainability Certificate";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Type of Sustainability Certificate';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the No. of Sustainability Certificate';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Name of Sustainability Certificate';
                }
                field("Area"; Rec."Area")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Area of Sustainability Certificate';
                }
                field(Standard; Rec.Standard)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Standard of Sustainability Certificate';
                }
                field(Issuer; Rec.Issuer)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Issuer of Sustainability Certificate';
                }
                field("Has Value"; Rec."Has Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Has Value of Sustainability Certificate';
                }
                field(Value; Rec.Value)
                {
                    Editable = Rec."Has Value";
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value for your Sustainability Certificate if you have specific measured values related to this certificate on the Item card.';
                }
            }
        }
    }
}