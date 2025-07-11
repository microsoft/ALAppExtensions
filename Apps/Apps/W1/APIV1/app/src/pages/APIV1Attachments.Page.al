namespace Microsoft.API.V1;

using System.IO;
using Microsoft.Integration.Graph;
using System.Reflection;
using System.Utilities;

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
                field(id; Rec.Id)
                {
                    Caption = 'id', Locked = true;

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo(Id), TempFieldBuffer);
                    end;
                }
                field(parentId; Rec."Document Id")
                {
                    Caption = 'parentId', Locked = true;
                    ShowMandatory = true;
                }
                field(fileName; Rec."File Name")
                {
                    Caption = 'fileName', Locked = true;
                    ToolTip = 'Specifies the Description for the Item.';

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("File Name"), TempFieldBuffer);
                    end;
                }
                field(byteSize; Rec."Byte Size")
                {
                    Caption = 'byteSize', Locked = true;

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("Byte Size"), TempFieldBuffer);
                    end;
                }
#pragma warning disable AL0273
                field(content; Rec.Content)
#pragma warning restore
                {
                    Caption = 'content', Locked = true;

                    trigger OnValidate()
                    begin
                        if AttachmentsLoaded then
                            Rec.Modify();
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo(Content), TempFieldBuffer);
                    end;
                }
                field(lastModifiedDateTime; Rec."Created Date-Time")
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
        exit(false);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        DocumentIdFilter: Text;
        AttachmentIdFilter: Text;
        FilterView: Text;
        DocumentId: Guid;
    begin
        if not AttachmentsLoaded then begin
            FilterView := Rec.GetView();
            DocumentIdFilter := Rec.GetFilter("Document Id");
            AttachmentIdFilter := Rec.GetFilter(Id);
            if (AttachmentIdFilter <> '') and (DocumentIdFilter = '') then begin
                DocumentId := GraphMgtAttachmentBuffer.GetDocumentIdFromAttachmentId(AttachmentIdFilter);
                DocumentIdFilter := format(DocumentId);
            end;
            if DocumentIdFilter = '' then
                error(MissingParentIdErr);

            GraphMgtAttachmentBuffer.LoadAttachments(Rec, DocumentIdFilter, AttachmentIdFilter);
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
        DocumentIdFilter: Text;
        FilterView: Text;
    begin
        if IsNullGuid(Rec."Document Id") then begin
            FilterView := Rec.GetView();
            DocumentIdFilter := Rec.GetFilter("Document Id");
            if DocumentIdFilter <> '' then
                Rec.Validate("Document Id", DocumentIdFilter);
            Rec.SetView(FilterView);
        end;
        if IsNullGuid(Rec."Document Id") then
            error(MissingParentIdErr);

        if not FileManagement.IsValidFileName(Rec."File Name") then
            Rec.Validate("File Name", 'filename.txt');

        Rec.Validate("Created Date-Time", RoundDateTime(CurrentDateTime(), 1000));
        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("Created Date-Time"), TempFieldBuffer);

        ByteSizeFromContent();

        GraphMgtAttachmentBuffer.PropagateInsertAttachmentSafe(Rec, TempFieldBuffer);

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.Id <> Rec.Id then
            error(CannotModifyKeyFieldErr, 'id');
        if xRec."Document Id" <> Rec."Document Id" then
            error(CannotModifyKeyFieldErr, 'parentId');

        GraphMgtAttachmentBuffer.PropagateModifyAttachment(Rec, TempFieldBuffer);
        ByteSizeFromContent();
        exit(false);
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
        TempBlob.FromRecord(Rec, Rec.FieldNo(Content));
        Rec."Byte Size" := GraphMgtAttachmentBuffer.GetContentLength(TempBlob);
    end;
}








