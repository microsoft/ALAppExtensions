pageextension 4823 "Intrastat Report Tariff Nmbs." extends "Tariff Numbers"
{
    layout
    {
        addafter("Supplementary Units")
        {
            field("Suppl. Conversion Factor"; Rec."Suppl. Conversion Factor")
            {
                ApplicationArea = BasicEU, BasicNO, BasicCH;
                ToolTip = 'Specifies the conversion factor for the tariff number.';
            }
            field("Suppl. Unit of Measure"; Rec."Suppl. Unit of Measure")
            {
                ApplicationArea = BasicEU, BasicNO, BasicCH;
                ToolTip = 'Specifies the unit of measure for the tariff number.';
            }
        }
    }
}