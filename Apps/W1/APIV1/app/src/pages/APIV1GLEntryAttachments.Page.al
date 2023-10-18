namespace Microsoft.API.V1;

using System.IO;
using System.Reflection;
using Microsoft.Integration.Graph;
using System.Utilities;

page 20040 "APIV1 - G/L Entry Attachments"
{
    APIVersion = 'v1.0';
    Caption = 'generalLedgerEntryAttachments', Locked = true;
    DelayedInsert = true;
    EntityName = 'generalLedgerEntryAttachments';
    EntitySetName = 'generalLedgerEntryAttachments';
    ODataKeyFields = "G/L Entry No.", Id;
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
                field(generalLedgerEntryNumber; Rec."G/L Entry No.")
                {
                    Caption = 'generalLedgerEntryNumber', Locked = true;
                    ShowMandatory = true;
                }
                field(id; Rec.Id)
                {
                    Caption = 'id', Locked = true;

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo(Id), TempFieldBuffer);
                    end;
                }
                field(fileName; Rec."File Name")
                {
                    Caption = 'fileName', Locked = true;

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
                field(createdDateTime; Rec."Created Date-Time")
                {
                    Caption = 'createdDateTime', Locked = true;
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
        GLEntryNoFilter: Text;
        AttachmentIdFilter: Text;
        FilterView: Text;
    begin
        if not AttachmentsLoaded then begin
            FilterView := Rec.GetView();
            GLEntryNoFilter := Rec.GetFilter("G/L Entry No.");
            AttachmentIdFilter := Rec.GetFilter(Id);
            if GLEntryNoFilter = '' then
                error(MissingGLEntryNoErr);

            GraphMgtAttachmentBuffer.LoadAttachments(Rec, GLEntryNoFilter, AttachmentIdFilter);
            Rec.SETVIEW(FilterView);
            AttachmentsFound := Rec.FINDFIRST();
            if not AttachmentsFound then
                exit(false);
            AttachmentsLoaded := true;
        end;
        exit(AttachmentsFound);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        FileManagement: Codeunit "File Management";
        TypeHelper: Codeunit "Type Helper";
#pragma warning disable AA0072
        Value: Variant;
#pragma warning restore
        GLEntryNoFilter: Text;
        FilterView: Text;
    begin
        if Rec."G/L Entry No." = 0 then begin
            FilterView := Rec.GetView();
            GLEntryNoFilter := Rec.GetFilter("G/L Entry No.");
            if GLEntryNoFilter <> '' then begin
                Value := Rec."G/L Entry No.";
                TypeHelper.Evaluate(Value, GLEntryNoFilter, '', 'en-US');
                Rec."G/L Entry No." := Value;
            end;
            Rec.SETVIEW(FilterView);
        end;
        if Rec."G/L Entry No." = 0 then
            error(MissingGLEntryNoErr);

        if not FileManagement.IsValidFileName(Rec."File Name") then
            Rec.Validate("File Name", 'filename.txt');

        Rec.Validate("Created Date-Time", ROUNDDATETIME(CURRENTDATETIME(), 1000));
        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("Created Date-Time"), TempFieldBuffer);

        ByteSizeFromContent();

        GraphMgtAttachmentBuffer.PropagateInsertAttachment(Rec, TempFieldBuffer);

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.Id <> Rec.Id then
            error(CannotModifyKeyFieldErr, 'id');
        if xRec."G/L Entry No." <> Rec."G/L Entry No." then
            error(CannotModifyKeyFieldErr, 'generalLedgerEntryNumber');

        GraphMgtAttachmentBuffer.PropagateModifyAttachment(Rec, TempFieldBuffer);
        ByteSizeFromContent();
        exit(false);
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        GraphMgtAttachmentBuffer: Codeunit "Graph Mgt - Attachment Buffer";
        AttachmentsLoaded: Boolean;
        AttachmentsFound: Boolean;
        MissingGLEntryNoErr: Label 'You must specify a generalLedgerEntryNumber in the request body.', Locked = true;
        CannotModifyKeyFieldErr: Label 'You cannot change the value of the key field %1.', Locked = true;

    local procedure ByteSizeFromContent()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.FromRecord(Rec, Rec.FieldNo(Content));
        Rec."Byte Size" := GraphMgtAttachmentBuffer.GetContentLength(TempBlob);
    end;
}








