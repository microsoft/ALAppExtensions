namespace Microsoft.API.V2;

using System.IO;
using Microsoft.Integration.Graph;
using System.Utilities;
using System.Reflection;

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
                field(id; Rec.Id)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(parentId; Rec."Document Id")
                {
                    Caption = 'Parent Id';
                    ShowMandatory = true;
                }
                field(fileName; Rec."File Name")
                {
                    Caption = 'File Name';

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("File Name"), TempFieldBuffer);
                    end;
                }
                field(byteSize; Rec."Byte Size")
                {
                    Caption = 'Byte Size';

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("Byte Size"), TempFieldBuffer);
                    end;
                }
                field(attachmentContent; Rec.Content)
                {
                    Caption = 'Content';

                    trigger OnValidate()
                    begin
                        if AttachmentsLoaded then
                            Rec.Modify();
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo(Content), TempFieldBuffer);
                    end;
                }
                field(lastModifiedDateTime; Rec."Created Date-Time")
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                field(parentType; Rec."Document Type")
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
            FilterView := Rec.GetView();
            DocumentIdFilter := Rec.GetFilter("Document Id");
            DocumentTypeFilter := Rec.GetFilter("Document Type");
            AttachmentIdFilter := Rec.GetFilter(Id);
            if (AttachmentIdFilter <> '') and ((DocumentIdFilter = '') or (DocumentTypeFilter = '')) then begin
                DocumentId := GraphMgtAttachmentBuffer.GetDocumentIdFromAttachmentId(AttachmentIdFilter);
                DocumentTypeFilter := Format(GraphMgtAttachmentBuffer.GetDocumentTypeFromAttachmentIdAndDocumentId(AttachmentIdFilter, DocumentId));
                DocumentIdFilter := Format(DocumentId);
            end;
            if DocumentIdFilter = '' then
                Error(MissingParentIdErr);

            GraphMgtAttachmentBuffer.LoadAttachmentsWithDocumentType(Rec, DocumentIdFilter, AttachmentIdFilter, DocumentTypeFilter);
            Rec.SetView(FilterView);
            AttachmentsFound := Rec.FindFirst();
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
        if IsNullGuid(Rec."Document Id") then begin
            FilterView := Rec.GetView();
            DocumentIdFilter := Rec.GetFilter("Document Id");
            DocumentTypeFilter := Rec.GetFilter("Document Type");
            if (DocumentIdFilter <> '') and (DocumentTypeFilter <> '') then begin
                Rec.Validate("Document Id", Format(DocumentIdFilter));
                Evaluate(AttachmentEntityBufferDocType, DocumentTypeFilter);
                Rec.Validate("Document Type", AttachmentEntityBufferDocType);
            end;
            Rec.SetView(FilterView);
        end;
        if IsNullGuid(Rec."Document Id") then
            Error(MissingParentIdErr);

        if not FileManagement.IsValidFileName(Rec."File Name") then
            Rec.Validate("File Name", 'filename.txt');

        Rec.Validate("Created Date-Time", RoundDateTime(CurrentDateTime(), 1000));
        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("Created Date-Time"), TempFieldBuffer);

        ByteSizeFromContent();

        GraphMgtAttachmentBuffer.PropagateInsertAttachmentSafeWithDocumentType(Rec, TempFieldBuffer);

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.Id <> Rec.Id then
            Error(CannotModifyKeyFieldErr, 'id');
        if xRec."Document Id" <> Rec."Document Id" then
            Error(CannotModifyKeyFieldErr, 'parentId');
        if xRec."Document Type" <> Rec."Document Type" then
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
        TempBlob.FromRecord(Rec, Rec.FieldNo(Content));
        Rec."Byte Size" := GraphMgtAttachmentBuffer.GetContentLength(TempBlob);
    end;
}