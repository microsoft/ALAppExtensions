namespace Microsoft.EServices.EDocumentConnector.Continia;

pageextension 148200 "Profile Selection" extends "Profile Selection"
{

    actions
    {
        addlast(Processing)
        {
            action(DeleteProfile)
            {
                Image = Delete;
                ToolTip = 'Delete Profile. Used for automated testing only';
                trigger OnAction()
                begin
                    Rec.Delete();
                end;
            }
        }
    }
}