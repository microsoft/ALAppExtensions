pageextension 31098 "Units of Measure CZL" extends "Units of Measure"
{
    layout
    {
        addafter(Description)
        {
            field("Tariff Number UOM Code CZL"; Rec."Tariff Number UOM Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the name of units of measure for revers charge reporting.';
                Visible = false;
            }
        }
    }
}