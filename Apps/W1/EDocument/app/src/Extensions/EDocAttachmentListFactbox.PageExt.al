namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Attachment;

pageextension 6102 "E-Doc. Attachment List Factbox" extends "Doc. Attachment List Factbox"
{
    actions
    {
        modify(AttachmentsUpload)
        {
            trigger OnBeforeAction()
            begin
                if BlockUploadAction then
                    Error(UploadActionBlockedErr);
            end;
        }
    }

    var
        BlockUploadAction: Boolean;
        UploadActionBlockedErr: Label 'Upload action is blocked for E-Documents.';

    internal procedure SetBlockUploadAction(NewBlockUploadAction: Boolean)
    begin
        BlockUploadAction := NewBlockUploadAction;
    end;
}
