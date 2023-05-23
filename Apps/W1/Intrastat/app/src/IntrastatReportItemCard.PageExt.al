pageextension 4812 "Intrastat Report Item Card" extends "Item Card"
{
    layout
    {
        addafter("Country/Region of Origin Code")
        {
            field("Exclude from Intrastat Report"; Rec."Exclude from Intrastat Report")
            {
                ApplicationArea = BasicEU, BasicCH, BasicNO;
                Importance = Additional;
                ToolTip = 'Specifies if the item shall be excluded from Intrastat report.';
            }
            field("Supplementary Unit of Measure"; Rec."Supplementary Unit of Measure")
            {
                ApplicationArea = BasicEU, BasicCH, BasicNO;
                Importance = Additional;
                ToolTip = 'Specifies the unit of measure code used in Intrastat report as supplementary unit.';
            }
        }
    }
}