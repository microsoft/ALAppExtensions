pageextension 10790 "Intrastat Report Subform ES" extends "Intrastat Report Subform"
{
    layout
    {
        addafter("Shpt. Method Code")
        {
            field("Statistical System"; Rec."Statistical System")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the statistical system to apply to the merchandise.';
            }
        }
    }
}