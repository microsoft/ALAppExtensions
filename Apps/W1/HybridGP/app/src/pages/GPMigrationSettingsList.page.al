page 4021 "GP Migration Settings List"
{
    SourceTable = "GP Company Migration Settings";
    SourceTableView = where(Replicate = CONST(true));
    PageType = ListPart;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    Caption = 'Select company settings for data migration';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(Companies)
            {
                ShowCaption = false;

                field("Name"; Rec."Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Name of the company';
                    Width = 6;
                }
            }
        }
    }
}