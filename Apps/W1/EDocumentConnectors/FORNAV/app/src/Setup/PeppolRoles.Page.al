namespace Microsoft.EServices.EDocumentConnector.ForNAV;

page 6412 "ForNAV Peppol Roles"
{
    PageType = List;
    SourceTable = "Fornav Peppol Role";
    Caption = 'ForNAV Peppol Roles';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Role; Rec.Role)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the roles that you have on the ForNAV Peppol network.';
                }
            }
        }
    }
}