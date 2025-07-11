// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Reporting;
using Microsoft.Finance.Currency;
using Microsoft.eServices.EDocument.Integration;
using System.Telemetry;
using Microsoft.Foundation.Attachment;
using Microsoft.Utilities;
using System.Automation;
using System.IO;
using System.Reflection;
using System.Threading;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

table 6121 "E-Document"
{
    DataCaptionFields = "Entry No", "Bill-to/Pay-to Name";
    LookupPageId = "E-Documents";
    DrillDownPageId = "E-Documents";
    DataClassification = CustomerContent;

    Permissions =
        tabledata "E-Document" = i,
        tabledata "E-Document Service Status" = d;


    fields
    {
        field(1; "Entry No"; Integer)
        {
            Caption = 'Document Entry No';
            AutoIncrement = true;
        }
        field(2; "Document Record ID"; RecordId)
        {
            Caption = 'Document Record ID';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                EDocAttachmentProcessor: Codeunit "E-Doc. Attachment Processor";
            begin
                EDocAttachmentProcessor.MoveAttachmentsAndDelete(Rec, Rec."Document Record ID");
            end;
        }
        field(3; "Bill-to/Pay-to No."; Code[20])
        {
            Caption = 'Bill-to/Pay-to No.';
        }
        field(4; "Bill-to/Pay-to Name"; Text[100])
        {
            Caption = 'Bill-to/Pay-to Name';
            Editable = false;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(6; "Document Type"; Enum "E-Document Type")
        {
            Caption = 'Document Type';
            Editable = false;
        }
        field(7; "Document Date"; Date)
        {
            Caption = 'Document Date';
            Editable = false;
        }
        field(8; "Due Date"; Date)
        {
            Caption = 'Due Date';
            Editable = false;
        }
        field(9; "Amount Incl. VAT"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            Editable = false;
        }
        field(10; "Amount Excl. VAT"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Excluding VAT';
            Editable = false;
        }
        field(11; "Index In Batch"; Integer)
        {
            Caption = 'Index In Batch';
            Editable = false;
        }
        field(12; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(13; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
        }
        field(14; Direction; Enum "E-Document Direction")
        {
            Caption = 'Direction';
            Editable = false;
        }
        field(15; "Incoming E-Document No."; Text[50])
        {
            Caption = 'Incoming E-Document No.';
            Editable = false;
        }
        field(16; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(17; "Table Name"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
            Caption = 'Document Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(18; Status; Enum "E-Document Status")
        {
            Caption = 'Electronic Document Status';
        }
        field(19; "Document Sending Profile"; Code[20])
        {
            Caption = 'Document Sending Profile';
            TableRelation = "Document Sending Profile";
        }
        field(20; "Source Type"; enum "E-Document Source Type")
        {
            Caption = 'Source Type';
        }
        field(21; "Data Exch. Def. Code"; Code[20])
        {
            TableRelation = "Data Exch. Def";
            Caption = 'Data Exch. Def. Code';
        }
        field(22; "Receiving Company VAT Reg. No."; Text[20])
        {
            Caption = 'Receiving Company VAT Reg. No.';
        }
        field(23; "Receiving Company GLN"; Code[13])
        {
            Caption = 'Receiving Company GLN';
            Numeric = true;
        }
        field(24; "Receiving Company Name"; Text[150])
        {
            Caption = 'Receiving Company Name';
        }
        field(25; "Receiving Company Address"; Text[200])
        {
            Caption = 'Receiving Company Address';
        }
        field(26; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(27; "Workflow Code"; Code[20])
        {
            TableRelation = Workflow where(Template = const(false), Category = const('EDOC'));
            Caption = 'Workflow Code';
        }
        field(28; "Workflow Step Instance ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(29; "Job Queue Entry ID"; Guid)
        {
            TableRelation = "Job Queue Entry";
            DataClassification = SystemMetadata;
        }
        field(30; "Journal Line System ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(31; "Receiving Company Id"; Text[250])
        {
            Caption = 'Receiving Company Id';
            ToolTip = 'Specifies the receiving company id, such as PEPPOL id, or other identifiers used in the electronic document exchange.';
        }
        field(32; "Unstructured Data Entry No."; Integer)
        {
            Caption = 'Unstructured Content';
            ToolTip = 'Specifies the content that is not structured, such as PDF';
            TableRelation = "E-Doc. Data Storage";
        }
        field(33; "Structured Data Entry No."; Integer)
        {
            Caption = 'Structured Content';
            ToolTip = 'Specifies the content that is structured, such as XML';
            TableRelation = "E-Doc. Data Storage";
        }
        field(34; Service; Code[20])
        {
            Caption = 'Service';
            ToolTip = 'Specifies the service that is used to process the E-Document.';
            Editable = false;
            TableRelation = "E-Document Service";
            ValidateTableRelation = true;
        }
        field(35; "File Name"; Text[256])
        {
            Caption = 'File Name';
            ToolTip = 'Specifies the file name of the E-Document source.';
        }
#if not CLEANSCHEMA26
        field(36; "File Type"; Integer)
        {
            Caption = 'File Type';
            ToolTip = 'Specifies the file type of the E-Document source.';
            ObsoleteReason = 'Use File Format in the "E-Doc. Data Storage" table instead.';
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
        }
        field(37; "Structured Data Process"; Integer)
        {
            Caption = 'Structured Data Process';
            ToolTip = 'Specifies the structured data process to run on the E-Document data.';
            ObsoleteReason = 'Use "Process Draft Impl." field instead.';
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
        }
#endif
        field(38; "Service Integration"; Enum "Service Integration")
        {
            Caption = 'Service Integration';
            ToolTip = 'Specifies the service integration to use for the E-Document.';
            Editable = false;
        }
        field(39; "Source Details"; Text[2048])
        {
            Caption = 'Source Details';
            ToolTip = 'Specifies details about the the E-Document source.';
        }
        field(40; "Additional Source Details"; Text[2048])
        {
            Caption = 'Additional Source Details';
            ToolTip = 'Specifies additional details about the E-Document source.';
        }
        field(41; "Import Processing Status"; Enum "Import E-Doc. Proc. Status")
        {
            Caption = 'Import Processing Status';
            ToolTip = 'Specifies the E-Document import processing status.';
            FieldClass = FlowField;
            CalcFormula = lookup("E-Document Service Status"."Import Processing Status" where("E-Document Entry No" = field("Entry No")));
        }
        #region Import Process Implementations
        field(42; "Structure Data Impl."; Enum "Structure Received E-Doc.")
        {
            Caption = 'Structure Data Implementation';
            ToolTip = 'Specifies the implementation to use for structuring the E-Document data.';
        }
        field(43; "Read into Draft Impl."; Enum "E-Doc. Read into Draft")
        {
            Caption = 'Read into Draft Implementation';
            ToolTip = 'Specifies the implementation to use for reading the E-Document data into a draft.';
        }
        field(44; "Process Draft Impl."; Enum "E-Doc. Process Draft")
        {
            Caption = 'Structured Data Process';
            ToolTip = 'Specifies the implementation to use for processing the draft received.';
        }
        #endregion
    }
    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
        key(Key2; "Document Record ID")
        {
        }
        key(Key3; "Incoming E-Document No.", "Bill-to/Pay-to No.", "Document Date", "Entry No")
        {
        }
        key(Key4; SystemCreatedAt)
        {
        }
    }

    trigger OnDelete()
    begin
        if (Rec.Status = Rec.Status::Processed) then
            Error(this.DeleteProcessedNotAllowedErr);

        if (Rec."Document Record ID".TableNo <> 0) then
            Error(this.DeleteLinkedNotAllowedErr);

        if (not Rec.IsDuplicate(false)) then
            if not GuiAllowed() then
                Error(DeleteUniqueNotAllowedErr)
            else
                if not Confirm(this.DeleteConfirmQst) then
                    Error('');

        this.CleanupDocument();
    end;

    /// <summary>
    /// Inserts a new E-Document record with the specified parameters.
    /// </summary>
    [InherentPermissions(PermissionObjectType::TableData, Database::"E-Document", 'i')]
    internal procedure Create(EDocumentDirection: Enum "E-Document Direction"; EDocumentType: Enum "E-Document Type"; EDocumentService: Record "E-Document Service")
    begin
        Rec."Entry No" := 0;
        Rec.Direction := EDocumentDirection;
        Rec."Document Type" := EDocumentType;
        Rec.Service := EDocumentService.Code;
        Rec."Service Integration" := EDocumentService."Service Integration V2";
        Rec.Insert(true);
    end;

    internal procedure IsDuplicate(ShowMessage: Boolean): Boolean
    var
        EDocument: Record "E-Document";
    begin
        EDocument.ReadIsolation := EDocument.ReadIsolation::ReadUncommitted;
        EDocument.SetRange("Incoming E-Document No.", Rec."Incoming E-Document No.");
        EDocument.SetRange("Bill-to/Pay-to No.", Rec."Bill-to/Pay-to No.");
        EDocument.SetRange("Document Date", Rec."Document Date");
        EDocument.SetFilter("Entry No", '<>%1', Rec."Entry No");
        if not EDocument.FindFirst() then
            exit(false);

        if ShowMessage and GuiAllowed() then
            Message(EDocumentExistsMsg, EDocument."Entry No");
        Telemetry.LogMessage('0000PHB', StrSubstNo(EDocumentExistsMsg, EDocument."Entry No"), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
        exit(true);
    end;

    internal procedure IsSourceDocumentStructured(): Boolean
    var
        EDocDataStorage: Record "E-Doc. Data Storage";
    begin
        // If the E-Document Data Storage can't be retrieved from the Unstructured Data Entry No.,
        // it means that the E-Document is coming from versions before 2, and these are all structured.
        if not EDocDataStorage.Get(Rec."Unstructured Data Entry No.") then
            exit(true);
        exit(Rec."Structure Data Impl." = "Structure Received E-Doc."::"Already Structured");
    end;

    internal procedure GetTotalAmountIncludingVAT(): Decimal
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
    begin
        if Rec."Amount Incl. VAT" <> 0 then
            exit(Rec."Amount Incl. VAT");
        if Rec.Direction = Rec.Direction::Outgoing then
            exit(-Rec."Amount Incl. VAT");
        if GetEDocumentService()."Import Process" = "E-Document Import Process"::"Version 1.0" then
            exit(Rec."Amount Incl. VAT");
        EDocumentPurchaseHeader.GetFromEDocument(Rec);
        exit(EDocumentPurchaseHeader.Total);
    end;

    procedure CleanupDocument()
    var
        DocumentAttachment: Record "Document Attachment";
        EDocMappingLog: Record "E-Doc. Mapping Log";
        EDocumentIntegrationLog: Record "E-Document Integration Log";
        EDocumentLog: Record "E-Document Log";
        EDocumentServiceStatus: Record "E-Document Service Status";
        IProcessStructuredData: Interface IProcessStructuredData;
    begin
        EDocumentLog.SetRange("E-Doc. Entry No", Rec."Entry No");
        if not EDocumentLog.IsEmpty() then
            EDocumentLog.DeleteAll(true);

        EDocumentIntegrationLog.SetRange("E-Doc. Entry No", Rec."Entry No");
        if not EDocumentIntegrationLog.IsEmpty() then
            EDocumentIntegrationLog.DeleteAll(true);

        EDocumentServiceStatus.SetRange("E-Document Entry No", Rec."Entry No");
        if not EDocumentServiceStatus.IsEmpty() then
            EDocumentServiceStatus.DeleteAll(true);

        DocumentAttachment.SetRange("E-Document Attachment", true);
        DocumentAttachment.SetRange("E-Document Entry No.", Rec."Entry No");
        if not DocumentAttachment.IsEmpty() then
            DocumentAttachment.DeleteAll(true);

        EDocMappingLog.SetRange("E-Doc Entry No.", Rec."Entry No");
        if not EDocMappingLog.IsEmpty() then
            EDocMappingLog.DeleteAll(true);

        IProcessStructuredData := Rec."Process Draft Impl.";
        IProcessStructuredData.CleanUpDraft(Rec);
    end;

    internal procedure ExportDataStorage()
    var
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocumentLog: Record "E-Document Log";
    begin
        if Rec."Structured Data Entry No." <> 0 then
            EDocDataStorage.Get(Rec."Structured Data Entry No.");
        if Rec."Unstructured Data Entry No." <> 0 then
            EDocDataStorage.Get(Rec."Unstructured Data Entry No.");

        EDocumentLog.SetRange("E-Doc. Entry No", Rec."Entry No");
        EDocumentLog.SetRange("E-Doc. Data Storage Entry No.", EDocDataStorage."Entry No.");
        if not EDocumentLog.FindFirst() then
            Error(NoFileErr, Rec.TableCaption());

        EDocumentLog.ExportDataStorage();
    end;

    procedure ViewSourceFile()
    var
        EDocDataStorage: Record "E-Doc. Data Storage";
        IEDocFileFormat: Interface IEDocFileFormat;
    begin
        EDocDataStorage.Get(Rec."Unstructured Data Entry No.");
        IEDocFileFormat := EDocDataStorage."File Format";
        IEDocFileFormat.PreviewContent(EDocDataStorage.Name, EDocDataStorage.GetTempBlob());
    end;

    internal procedure OpenEDocument(EDocumentRecordId: RecordId)
    var
        EDocument: Record "E-Document";
        EDocumentPage: Page "E-Document";
    begin
        EDocument.SetRange("Document Record ID", EDocumentRecordId);
        EDocument.FindFirst();
        EDocumentPage.SetTableView(EDocument);
        EDocumentPage.RunModal();
    end;

    internal procedure ShowRecord()
    var
        PageManagement: Codeunit "Page Management";
        DataTypeManagement: Codeunit "Data Type Management";
        EDocHelper: Codeunit "E-Document Processing";
        RecRef: RecordRef;
        RelatedRecord: Variant;
    begin
        if EDocHelper.GetRecord(Rec, RelatedRecord) then begin
            DataTypeManagement.GetRecordRef(RelatedRecord, RecRef);
            PageManagement.PageRun(RecRef);
        end;
    end;

    internal procedure GetEDocumentServiceStatus() EDocumentServiceStatus: Record "E-Document Service Status"
    begin
        EDocumentServiceStatus.SetRange("E-Document Entry No", Rec."Entry No");
        if EDocumentServiceStatus.FindFirst() then;
    end;

    procedure GetEDocumentService() EDocumentService: Record "E-Document Service"
    begin
        if EDocumentService.Get(Rec.Service) then
            exit;
        if EDocumentService.Get(GetEDocumentServiceStatus()."E-Document Service Code") then;
    end;

#if not CLEAN27
    [Obsolete('Use flow field "Import Processing Status"', '27.0')]
    procedure GetEDocumentImportProcessingStatus(): Enum "Import E-Doc. Proc. Status"
    begin
        exit(GetEDocumentServiceStatus()."Import Processing Status");
    end;
#endif
    internal procedure ToString(): Text
    begin
        exit(StrSubstNo(ToStringLbl, SystemId, "Document Record ID", "Workflow Step Instance ID", "Job Queue Entry ID"));
    end;

    var
        Telemetry: Codeunit Telemetry;
        ToStringLbl: Label '%1,%2,%3,%4', Locked = true;
        DeleteLinkedNotAllowedErr: Label 'The E-Document is linked to sales or purchase document and cannot be deleted.';
        DeleteProcessedNotAllowedErr: Label 'The E-Document has already been processed and cannot be deleted.';
        DeleteUniqueNotAllowedErr: Label 'Only duplicate E-Documents can be deleted without a confirmation in the user interface.';
        NoFileErr: label 'No previewable attachment exists for this %2.', Comment = '%1 - a table caption';
        DeleteConfirmQst: label 'Are you sure? You may not be able to retrieve this E-Document again.\\ Do you want to continue?';
        EDocumentExistsMsg: Label 'This E-Document is a duplicate of E-Document %1.', Comment = '%1 - E-Document No.';
}