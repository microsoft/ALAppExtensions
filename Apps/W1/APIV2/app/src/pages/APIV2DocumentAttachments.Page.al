namespace Microsoft.API.V2;

using Microsoft.Foundation.Attachment;
using Microsoft.Integration.Graph;
using System.IO;
using System.Utilities;
using System.Reflection;

page 30080 "APIV2 - Document Attachments"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Document Attachment';
    EntitySetCaption = 'Document Attachments';
    DelayedInsert = true;
    EntityName = 'documentAttachment';
    EntitySetName = 'documentAttachments';
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
                    Editable = false;
                }
                field(attachmentContent; Rec.Content)
                {
                    Caption = 'Content';

                    trigger OnValidate()
                    begin
                        if AttachmentsLoaded then begin
                            Rec.Modify();
                            ContentLoaded := true;
                        end;
                    end;
                }
                field(parentType; Rec."Document Type")
                {
                    Caption = 'Parent Type';
                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("Document Type"), TempFieldBuffer);
                    end;
                }
                field(parentId; Rec."Document Id")
                {
                    Caption = 'Parent Id';
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("Document Id"), TempFieldBuffer);
                    end;
                }
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'Line No.';
                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("Line No."), TempFieldBuffer);
                    end;
                }
                field(documentFlowSales; Rec."Document Flow Sales")
                {
                    Caption = 'Flow to Sales Transactions';
                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("Document Flow Sales"), TempFieldBuffer);
                    end;
                }
                field(documentFlowPurchase; Rec."Document Flow Purchase")
                {
                    Caption = 'Flow to Purchase Transactions';
                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("Document Flow Purchase"), TempFieldBuffer);
                    end;
                }
                field(lastModifiedDateTime; Rec."Created Date-Time")
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Attachment Type", Rec."Attachment Type"::"Document Attachment");
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        GraphMgtAttachmentBuffer.PropagateDeleteAttachmentWithDocumentType(Rec);
        exit(false);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        DocumentAttachment: Record "Document Attachment";
        AttachmentIdFilter: Text;
        DocumentAttachmentFilterView: Text;
        ExistingFilter: Text;
    begin
        if not AttachmentsLoaded then begin
            ExistingFilter := Rec.GetView();
            TransferFiltersToDocumentAttachments(DocumentAttachment, Rec);
            DocumentAttachmentFilterView := DocumentAttachment.GetView();

            AttachmentIdFilter := Rec.GetFilter(Id);
            Rec.Reset();
            GraphMgtAttachmentBuffer.LoadDocumentAttachments(Rec, DocumentAttachmentFilterView);
            Rec.SetView(ExistingFilter);
            AttachmentsFound := Rec.FindFirst();
            if not AttachmentsFound then
                exit(false);
            AttachmentsLoaded := true;
        end;
        exit(AttachmentsFound);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        DocumentAttachment: Record "Document Attachment";
        FileManagement: Codeunit "File Management";
    begin
        if not FileManagement.IsValidFileName(Rec."File Name") then
            Rec.Validate("File Name", 'filename.txt');

        Rec.Validate("Created Date-Time", RoundDateTime(CurrentDateTime(), 1000));
        GraphMgtAttachmentBuffer.RegisterFieldSet(Rec.FieldNo("Created Date-Time"), TempFieldBuffer);

        GraphMgtAttachmentBuffer.InsertFromTempAttachmentEntityBufferToDocumentAttachment(DocumentAttachment, Rec, TempFieldBuffer);
        DocumentAttachment.SetRecFilter();
        GraphMgtAttachmentBuffer.LoadDocumentAttachments(Rec, DocumentAttachment.GetView());
        ByteSizeFromContent();

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        DocumentAttachment: Record "Document Attachment";
        ContentInStream: InStream;
    begin
        if xRec.Id <> Rec.Id then
            Error(CannotModifyKeyFieldErr, 'id');

        TransferFiltersToDocumentAttachments(DocumentAttachment, Rec);
        DocumentAttachment.FindFirst();

        if ContentLoaded then begin
            Rec.CalcFields(Content);
            Rec.Content.CreateInStream(ContentInStream);
            DocumentAttachment.ImportAttachment(ContentInStream, Rec."File Name");
            DocumentAttachment.SetRecFilter();
            GraphMgtAttachmentBuffer.LoadDocumentAttachments(Rec, DocumentAttachment.GetView());
            exit(false);
        end;

        GraphMgtAttachmentBuffer.ModifyFromTempAttachmentEntityBufferToDocumentAttachment(DocumentAttachment, Rec, TempFieldBuffer);
        DocumentAttachment.SetRecFilter();
        GraphMgtAttachmentBuffer.LoadDocumentAttachments(Rec, DocumentAttachment.GetView());
        ByteSizeFromContent();
        exit(false);
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        GraphMgtAttachmentBuffer: Codeunit "Graph Mgt - Attachment Buffer";
        AttachmentsLoaded: Boolean;
        AttachmentsFound: Boolean;
        CannotModifyKeyFieldErr: Label 'You cannot change the value of the key field %1.', Comment = '%1 = Field name';
        ContentLoaded: Boolean;


    local procedure TransferFiltersToDocumentAttachments(var DocumentAttachment: Record "Document Attachment"; var TempAttachmentEntityBuffer: Record "Attachment Entity Buffer" temporary)
    var
        LocalDocumentAttachment: Record "Document Attachment";
        FilterText: Text;
    begin
        FilterText := TempAttachmentEntityBuffer.GetFilter(Id);
        if FilterText <> '' then
            DocumentAttachment.SetFilter(SystemId, FilterText);

        FilterText := TempAttachmentEntityBuffer.GetFilter("Created Date-Time");
        if FilterText <> '' then
            DocumentAttachment.SetFilter("Attached Date", FilterText);

        FilterText := TempAttachmentEntityBuffer.GetFilter("Document Type");
        if FilterText <> '' then begin
            Evaluate(TempAttachmentEntityBuffer."Document Type", FilterText, 9);
            FilterText := TempAttachmentEntityBuffer.GetFilter("Document Id");
            if FilterText <> '' then
                Evaluate(TempAttachmentEntityBuffer."Document Id", FilterText, 9);

            GraphMgtAttachmentBuffer.ConvertDocumentTypeToDocumentAttachment(Rec, LocalDocumentAttachment);
            DocumentAttachment.SetRange("Table ID", LocalDocumentAttachment."Table ID");

            if (FilterText <> '') and (LocalDocumentAttachment."No." = '') then
                GraphMgtAttachmentBuffer.SetDocumentAttachmentNo(LocalDocumentAttachment, Rec);

            if LocalDocumentAttachment."No." <> '' then
                DocumentAttachment.SetRange("No.", LocalDocumentAttachment."No.");
        end;

        FilterText := TempAttachmentEntityBuffer.GetFilter("Line No.");
        if FilterText <> '' then
            DocumentAttachment.SetFilter("Line No.", FilterText);

        FilterText := TempAttachmentEntityBuffer.GetFilter("File Name");
        if FilterText <> '' then
            DocumentAttachment.SetFilter("File Name", FilterText);

        FilterText := TempAttachmentEntityBuffer.GetFilter("Document Flow Sales");
        if FilterText <> '' then
            DocumentAttachment.SetFilter("Document Flow Sales", FilterText);
    end;


    local procedure ByteSizeFromContent()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.FromRecord(Rec, Rec.FieldNo(Content));
        Rec."Byte Size" := GraphMgtAttachmentBuffer.GetContentLength(TempBlob);
    end;
}
