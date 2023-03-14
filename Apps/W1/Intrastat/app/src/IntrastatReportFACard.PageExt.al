pageextension 4811 "Intrastat Report FA Card" extends "Fixed Asset Card"
{
    layout
    {
        addafter(Maintenance)
        {
            group(Intrastat)
            {
                Caption = 'Intrastat';
                field("Tariff No."; Rec."Tariff No.")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies a code for the asset''s tariff number.';
                }
                field("Country/Region of Origin Code"; Rec."Country/Region of Origin Code")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies a code for the country/region where the asset was produced or processed.';
                }
                field("Exclude from Intrastat Report"; Rec."Exclude from Intrastat Report")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies if the asset shall be excluded from Intrastat report.';
                }
                field("Net Weight"; Rec."Net Weight")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the net weight of the asset.';
                }
                field("Gross Weight"; Rec."Gross Weight")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    Importance = Additional;
                    ToolTip = 'Specifies the gross weight of the asset.';
                }
                field("Supplementary Unit of Measure"; Rec."Supplementary Unit of Measure")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the unit of measure that is used as the supplementary unit in the Intrastat report.';
                }
            }
        }
    }
}