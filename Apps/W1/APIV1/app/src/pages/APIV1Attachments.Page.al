page 20039 "APIV1 - Attachments"
{
    APIVersion = 'v1.0';
    Caption = 'attachments', Locked = true;
    DelayedInsert = true;
    EntityName = 'attachments';
    EntitySetName = 'attachments';
    ODataKeyFields = "Document Id", Id;
    PageType = API;
    SourceTable = "Attachment Entity Buffer";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Id)
                {
                    Caption = 'id', Locked = true;

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(FIELDNO(Id), TempFieldBuffer);
                    end;
                }
                field(parentId; "Document Id")
                {
                    Caption = 'parentId', Locked = true;
                    ShowMandatory = true;
                }
                field(fileName; "File Name")
                {
                    Caption = 'fileName', Locked = true;
                    ToolTip = 'Specifies the Description for the Item.';

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(FIELDNO("File Name"), TempFieldBuffer);
                    end;
                }
                field(byteSize; "Byte Size")
                {
                    Caption = 'byteSize', Locked = true;

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(FIELDNO("Byte Size"), TempFieldBuffer);
                    end;
                }
                field(content; Content)
                {
                    Caption = 'content', Locked = true;

                    trigger OnValidate()
                    begin
                        IF AttachmentsLoaded THEN
                            MODIFY();
                        GraphMgtAttachmentBuffer.RegisterFieldSet(FIELDNO(Content), TempFieldBuffer);
                    end;
                }
                field(lastModifiedDateTime; "Created Date-Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        GraphMgtAttachmentBuffer.PropagateDeleteAttachment(Rec);
        EXIT(FALSE);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        DocumentIdFilter: Text;
        AttachmentIdFilter: Text;
        FilterView: Text;
        DocumentId: Guid;
    begin
        IF NOT AttachmentsLoaded THEN BEGIN
            FilterView := GETVIEW();
            DocumentIdFilter := GETFILTER("Document Id");
            AttachmentIdFilter := GETFILTER(Id);
            IF (AttachmentIdFilter <> '') AND (DocumentIdFilter = '') THEN BEGIN
                DocumentId := GraphMgtAttachmentBuffer.GetDocumentIdFromAttachmentId(AttachmentIdFilter);
                DocumentIdFilter := FORMAT(DocumentId);
            END;
            IF DocumentIdFilter = '' THEN
                ERROR(MissingParentIdErr);

            GraphMgtAttachmentBuffer.LoadAttachments(Rec, DocumentIdFilter, AttachmentIdFilter);
            SETVIEW(FilterView);
            AttachmentsFound := FINDFIRST();
            IF NOT AttachmentsFound THEN
                EXIT(FALSE);
            AttachmentsLoaded := TRUE;
        END;
        EXIT(AttachmentsFound);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
        FileManagement: Codeunit "File Management";
        DocumentIdFilter: Text;
        FilterView: Text;
    begin
        IF ISNULLGUID("Document Id") THEN BEGIN
            FilterView := GETVIEW();
            DocumentIdFilter := GETFILTER("Document Id");
            IF DocumentIdFilter <> '' THEN
                VALIDATE("Document Id", TypeHelper.GetGuidAsString(DocumentIdFilter));
            SETVIEW(FilterView);
        END;
        IF ISNULLGUID("Document Id") THEN
            ERROR(MissingParentIdErr);

        IF NOT FileManagement.IsValidFileName("File Name") THEN
            VALIDATE("File Name", 'filename.txt');

        VALIDATE("Created Date-Time", ROUNDDATETIME(CURRENTDATETIME(), 1000));
        GraphMgtAttachmentBuffer.RegisterFieldSet(FIELDNO("Created Date-Time"), TempFieldBuffer);

        ByteSizeFromContent();

        GraphMgtAttachmentBuffer.PropagateInsertAttachmentSafe(Rec, TempFieldBuffer);

        EXIT(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IF xRec.Id <> Id THEN
            ERROR(CannotModifyKeyFieldErr, 'id');
        IF xRec."Document Id" <> "Document Id" THEN
            ERROR(CannotModifyKeyFieldErr, 'parentId');

        GraphMgtAttachmentBuffer.PropagateModifyAttachment(Rec, TempFieldBuffer);
        ByteSizeFromContent();
        EXIT(FALSE);
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        GraphMgtAttachmentBuffer: Codeunit "Graph Mgt - Attachment Buffer";
        AttachmentsLoaded: Boolean;
        AttachmentsFound: Boolean;
        MissingParentIdErr: Label 'You must specify a parentId in the request body.', Locked = true;
        CannotModifyKeyFieldErr: Label 'You cannot change the value of the key field %1.', Locked = true;

    local procedure ByteSizeFromContent()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.FromRecord(Rec, FieldNo(Content));
        "Byte Size" := GraphMgtAttachmentBuffer.GetContentLength(TempBlob);
    end;
}







