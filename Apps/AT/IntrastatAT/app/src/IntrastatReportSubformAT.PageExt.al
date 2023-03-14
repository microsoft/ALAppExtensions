pageextension 11150 "Intrastat Report Subform AT" extends "Intrastat Report Subform"
{
    layout
    {
        modify("Area")
        {
            Visible = true;
        }

        modify("Transaction Specification")
        {
            Visible = true;
        }

        modify("Transport Method")
        {
            Visible = false;
        }
    }
}