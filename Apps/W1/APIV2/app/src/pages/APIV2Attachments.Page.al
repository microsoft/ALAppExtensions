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

                    trigger OnValidate()
                    begin
                        if Rec."Document Type" in [Rec."Document Type"::Employee, Rec."Document Type"::Job, Rec."Document Type"::Item, Rec."Document Type"::Customer, Rec."Document Type"::Vendor] then
                            Error(ParentTypeNotSupportedErr, Rec."Document Type");
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        if not IsNullGuid(Rec."Document Id") then
            GraphMgtAttachmentBuffer.PropagateDeleteAttachmentWithDocumentType(Rec)
        else
            GraphMgtAttachmentBuffer.PropagateDeleteAttachmentWithoutDocumentType(Rec);
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
                if not IsNullGuid(DocumentId) then begin
                    DocumentTypeFilter := Format(GraphMgtAttachmentBuffer.GetDocumentTypeFromAttachmentIdAndDocumentId(AttachmentIdFilter, DocumentId));
                    DocumentIdFilter := Format(DocumentId);
                end;
            end;
            if DocumentIdFilter <> '' then
                GraphMgtAttachmentBuffer.LoadAttachmentsWithDocumentType(Rec, DocumentIdFilter, AttachmentIdFilter, DocumentTypeFilter)
            else
                GraphMgtAttachmentBuffer.LoadAttachmentsWithoutDocumentType(Rec, AttachmentIdFilter);

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

        if not FileManagement.IsValidFileName(Rec."File Name") then
            Rec.Validate("File Name", 'filename.txt');

        Rec.Validate("Created Date-Time", RoundDateTime(CurrentDateTime(), 1000));
        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("Created Date-Time"), TempFieldBuffer);

        ByteSizeFromContent();

        if not IsNullGuid(Rec."Document Id") then
            GraphMgtAttachmentBuffer.PropagateInsertAttachmentSafeWithDocumentType(Rec, TempFieldBuffer)
        else
            GraphMgtAttachmentBuffer.PropagateInsertAttachmentSafeWithoutDocumentType(Rec, TempFieldBuffer);

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

        if not IsNullGuid(Rec."Document Id") then
            GraphMgtAttachmentBuffer.PropagateModifyAttachmentWithDocumentType(Rec, TempFieldBuffer)
        else
            GraphMgtAttachmentBuffer.PropagateModifyAttachmentWithoutDocumentType(Rec, TempFieldBuffer);

        ByteSizeFromContent();
        exit(false);
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        GraphMgtAttachmentBuffer: Codeunit "Graph Mgt - Attachment Buffer";
        AttachmentsLoaded: Boolean;
        AttachmentsFound: Boolean;
        CannotModifyKeyFieldErr: Label 'You cannot change the value of the key field %1.', Comment = '%1 = Field name';
        ParentTypeNotSupportedErr: Label 'Parent type %1 is not supported. Use documentAttachments API instead.', Comment = '%1 = Parent type';

    local procedure ByteSizeFromContent()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.FromRecord(Rec, Rec.FieldNo(Content));
        Rec."Byte Size" := GraphMgtAttachmentBuffer.GetContentLength(TempBlob);
    end;
}