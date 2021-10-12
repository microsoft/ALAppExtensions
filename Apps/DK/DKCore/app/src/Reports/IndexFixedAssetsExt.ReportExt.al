reportextension 13605 IndexFixedAssetsExt extends "Index Fixed Assets"
{
    requestpage
    {
        layout
        {
            modify("IndexChoices[5]")
            {
                Visible = false;
            }

            modify("IndexChoices[6]")
            {
                Visible = false;
            }
        }
    }
}