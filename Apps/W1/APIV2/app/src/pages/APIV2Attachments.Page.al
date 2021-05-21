page 30039 "APIV2 - Attachments"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Attachment';
    EntitySetCaption = 'Attachments';
    DelayedInsert = true;
    EntityName = 'attachment';
    EntitySetName = 'attachments';
    ODataKeyFields = Id;
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
                    Caption = 'Id';
                    Editable = false;
                }
                field(parentId; "Document Id")
                {
                    Caption = 'Parent Id';
                    ShowMandatory = true;
                }
                field(fileName; "File Name")
                {
                    Caption = 'File Name';

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(FieldNo("File Name"), TempFieldBuffer);
                    end;
                }
                field(byteSize; "Byte Size")
                {
                    Caption = 'Byte Size';

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(FieldNo("Byte Size"), TempFieldBuffer);
                    end;
                }
                field(attachmentContent; Content)
                {
                    Caption = 'Content';

                    trigger OnValidate()
                    begin
                        if AttachmentsLoaded then
                            Modify();
                        GraphMgtAttachmentBuffer.RegisterFieldSet(FieldNo(Content), TempFieldBuffer);
                    end;
                }
                field(lastModifiedDateTime; "Created Date-Time")
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                field(parentType; "Document Type")
                {
                    Caption = 'Parent Type';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        GraphMgtAttachmentBuffer.PropagateDeleteAttachmentWithDocumentType(Rec);
        exit(false);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        DocumentIdFilter: Text;
        DocumentTypeFilter: Text;
        AttachmentIdFilter: Text;
        FilterView: Text;
        DocumentId: Guid;
    begin
        if not AttachmentsLoaded then begin
            FilterView := GetView();
            DocumentIdFilter := GetFilter("Document Id");
            DocumentTypeFilter := GetFilter("Document Type");
            AttachmentIdFilter := GetFilter(Id);
            if (AttachmentIdFilter <> '') and ((DocumentIdFilter = '') or (DocumentTypeFilter = '')) then begin
                DocumentId := GraphMgtAttachmentBuffer.GetDocumentIdFromAttachmentId(AttachmentIdFilter);
                DocumentTypeFilter := Format(GraphMgtAttachmentBuffer.GetDocumentTypeFromAttachmentIdAndDocumentId(AttachmentIdFilter, DocumentId));
                DocumentIdFilter := Format(DocumentId);
            end;
            if DocumentIdFilter = '' then
                Error(MissingParentIdErr);

            GraphMgtAttachmentBuffer.LoadAttachmentsWithDocumentType(Rec, DocumentIdFilter, AttachmentIdFilter, DocumentTypeFilter);
            SetView(FilterView);
            AttachmentsFound := FindFirst();
            if not AttachmentsFound then
                exit(false);
            AttachmentsLoaded := true;
        end;
        exit(AttachmentsFound);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        FileManagement: Codeunit "File Management";
        AttachmentEntityBufferDocType: Enum "Attachment Entity Buffer Document Type";
        DocumentIdFilter: Text;
        DocumentTypeFilter: Text;
        FilterView: Text;
    begin
        if IsNullGuid("Document Id") then begin
            FilterView := GetView();
            DocumentIdFilter := GetFilter("Document Id");
            DocumentTypeFilter := GetFilter("Document Type");
            if (DocumentIdFilter <> '') and (DocumentTypeFilter <> '') then begin
                Validate("Document Id", Format(DocumentIdFilter));
                Evaluate(AttachmentEntityBufferDocType, DocumentTypeFilter);
                Validate("Document Type", AttachmentEntityBufferDocType);
            end;
            SetView(FilterView);
        end;
        if IsNullGuid("Document Id") then
            Error(MissingParentIdErr);

        if not FileManagement.IsValidFileName("File Name") then
            Validate("File Name", 'filename.txt');

        Validate("Created Date-Time", RoundDateTime(CurrentDateTime(), 1000));
        GraphMgtAttachmentBuffer.RegisterFieldSet(FieldNo("Created Date-Time"), TempFieldBuffer);

        ByteSizeFromContent();

        GraphMgtAttachmentBuffer.PropagateInsertAttachmentSafeWithDocumentType(Rec, TempFieldBuffer);

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.Id <> Id then
            Error(CannotModifyKeyFieldErr, 'id');
        if xRec."Document Id" <> "Document Id" then
            Error(CannotModifyKeyFieldErr, 'parentId');
        if xRec."Document Type" <> "Document Type" then
            Error(CannotModifyKeyFieldErr, 'parentType');

        GraphMgtAttachmentBuffer.PropagateModifyAttachmentWithDocumentType(Rec, TempFieldBuffer);
        ByteSizeFromContent();
        exit(false);
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        GraphMgtAttachmentBuffer: Codeunit "Graph Mgt - Attachment Buffer";
        AttachmentsLoaded: Boolean;
        AttachmentsFound: Boolean;
        MissingParentIdErr: Label 'You must specify a parentId in the request body.';
        CannotModifyKeyFieldErr: Label 'You cannot change the value of the key field %1.', Comment = '%1 = Field name';

    local procedure ByteSizeFromContent()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.FromRecord(Rec, FieldNo(Content));
        "Byte Size" := GraphMgtAttachmentBuffer.GetContentLength(TempBlob);
    end;
}