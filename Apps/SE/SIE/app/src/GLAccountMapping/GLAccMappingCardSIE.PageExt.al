pageextension 5317 "G/L Acc. Mapping Card SIE" extends "G/L Account Mapping Card"
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