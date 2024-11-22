namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument;


pageextension 6380 "E-Document" extends "E-Document"
{
    actions
    {
        addafter(GetApproval)
        {
            action(UpdateStatus)
            {
                Caption = 'Update Status';
                ApplicationArea = Basic, Suite;
                Image = Status;
                ToolTip = 'Check the status of the document in Logiq system.';

                trigger OnAction()
                var
                    EDocService: Record "E-Document Service";
                    LogiqEDocumentManagement: Codeunit "E-Document Management";
                    EDocumentErrorHelper: Codeunit "E-Document Error Helper";
                    EDocServices: Page "E-Document Services";
                begin
                    if (Rec."Logiq External Id" = '') then
                        Error(DocNotSentErr);

                    EDocServices.LookupMode := true;
                    if EDocServices.RunModal() = Action::LookupOK then begin
                        EDocServices.GetRecord(EDocService);
                        EDocumentErrorHelper.ClearErrorMessages(Rec);
                        LogiqEDocumentManagement.UpdateStatus(Rec, EDocService);
                    end;
                end;
            }
        }
        addlast(Category_Process)
        {
            actionref(UpdateStatus_Promoted; UpdateStatus)
            {
            }
        }
    }

    var
        DocNotSentErr: Label 'Status can only be updated for documents that are succesfully sent to Logiq.';
}
