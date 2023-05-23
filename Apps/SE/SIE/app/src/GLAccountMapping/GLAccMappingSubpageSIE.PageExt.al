pageextension 5318 "G/L Acc. Mapping Subpage SIE" extends "G/L Account Mapping Subpage"
{
    layout
    {
        modify(CategoryNo)
        {
            Enabled = false;
            Visible = false;
        }
    }
}