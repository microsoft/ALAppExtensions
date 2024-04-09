pageextension 5326 "G/L Account Mapping Card SIE" extends "G/L Acc. Mapping Card"
{
    layout
    {
        modify(StandardAccountCategoryNo)
        {
            Enabled = false;
            Visible = false;
        }
    }
}