// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.EServices.EDocument;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.BatchProcessing;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;
using System.Automation;
using System.Globalization;
using System.Security.AccessControl;
using System.Utilities;

#pragma warning disable AA0232
table 31272 "Compensation Header CZC"
{
    Caption = 'Compensation Header';
    DataCaptionFields = "No.", Description;
    LookupPageID = "Compensation List CZC";

    fields
    {
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CompensationsSetupCZC: Record "Compensations Setup CZC";
                NoSeriesMgt: Codeunit NoSeriesManagement;
            begin
                if "No." <> xRec."No." then begin
                    CompensationsSetupCZC.Get();
                    NoSeriesMgt.TestManual(CompensationsSetupCZC."Compensation Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(13; "Company Type"; Enum "Compensation Company Type CZC")
        {
            Caption = 'Company Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
                if "Company Type" <> xRec."Company Type" then
                    Validate("Company No.", '');
            end;
        }
        field(15; "Company No."; Code[20])
        {
            Caption = 'Company No.';
            TableRelation = IF ("Company Type" = const(Customer)) Customer else
            if ("Company Type" = const(Vendor)) Vendor else
            if ("Company Type" = const(Contact)) Contact."No." where(Type = const(Company));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Customer: Record Customer;
                Vendor: Record Vendor;
                Contact: Record Contact;
            begin
                TestField(Status, Status::Open);
                case "Company Type" of
                    "Company Type"::Customer:
                        begin
                            if not Customer.Get("Company No.") then
                                Clear(Customer);
                            InitCompanyInformation(
                              Customer.Name,
                              Customer."Name 2",
                              Customer.Address,
                              Customer."Address 2",
                              Customer.City,
                              Customer.Contact,
                              Customer."Post Code",
                              Customer."Country/Region Code",
                              Customer.County);
                            "Language Code" := Customer."Language Code";
                            "Format Region" := Customer."Format Region";
                        end;
                    "Company Type"::Vendor:
                        begin
                            if not Vendor.Get("Company No.") then
                                Clear(Vendor);
                            InitCompanyInformation(
                              Vendor.Name,
                              Vendor."Name 2",
                              Vendor.Address,
                              Vendor."Address 2",
                              Vendor.City,
                              Vendor.Contact,
                              Vendor."Post Code",
                              Vendor."Country/Region Code",
                              Vendor.County);
                            "Language Code" := Vendor."Language Code";
                            "Format Region" := Vendor."Format Region";
                        end;
                    "Company Type"::Contact:
                        begin
                            if not Contact.Get("Company No.") then
                                Clear(Contact);
                            InitCompanyInformation(
                              Contact.Name,
                              Contact."Name 2",
                              Contact.Address,
                              Contact."Address 2",
                              Contact.City,
                              '',
                              Contact."Post Code",
                              Contact."Country/Region Code",
                              Contact.County);
                            "Language Code" := Contact."Language Code";
                            "Format Region" := Contact."Format Region";
                        end;
                end;
            end;
        }
        field(20; "Company Name"; Text[100])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                case "Company Type" of
                    "Company Type"::Customer:
                        if ShouldLookForCustomerByName("Company No.") then
                            Validate("Company No.", Customer.GetCustNo("Company Name"));
                    "Company Type"::Vendor:
                        if ShouldLookForVendorByName("Company No.") then
                            Validate("Company No.", Vendor.GetVendorNo("Company Name"));
                    "Company Type"::Contact:
                        Validate("Company No.", Contact.GetContNo("Company Name"));
                end;
            end;
        }
        field(25; "Company Name 2"; Text[50])
        {
            Caption = 'Company Name 2';
            DataClassification = CustomerContent;
        }
        field(30; "Company Address"; Text[100])
        {
            Caption = 'Company Address';
            DataClassification = CustomerContent;
        }
        field(35; "Company Address 2"; Text[50])
        {
            Caption = 'Company Address 2';
            DataClassification = CustomerContent;
        }
        field(40; "Company City"; Text[30])
        {
            Caption = 'Company City';
            TableRelation = "Post Code".City;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(
                  "Company City", "Company Post Code", "Company County", "Company Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(45; "Company Contact"; Text[100])
        {
            Caption = 'Company Contact';
            DataClassification = CustomerContent;
        }
        field(46; "Company County"; Text[30])
        {
            Caption = 'Company County';
            CaptionClass = '5,12,' + "Company Country/Region Code";
            DataClassification = CustomerContent;
        }
        field(47; "Company Country/Region Code"; Code[10])
        {
            Caption = 'Company Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(50; "Company Post Code"; Code[20])
        {
            Caption = 'Company Post Code';
            TableRelation = "Post Code";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(
                  "Company City", "Company Post Code", "Company County", "Company Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(55; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(60; Status; Enum "Compensation Status CZC")
        {
            Caption = 'Status';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(65; "Salesperson/Purchaser Code"; Code[20])
        {
            Caption = 'Salesperson/Purchaser Code';
            TableRelation = "Salesperson/Purchaser";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(70; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Posting Date", "Document Date");
            end;
        }
        field(75; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(80; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(85; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
            DataClassification = CustomerContent;
        }
        field(86; "Format Region"; Text[80])
        {
            Caption = 'Format Region';
            TableRelation = "Language Selection"."Language Tag";
            DataClassification = CustomerContent;
        }
        field(90; "Balance (LCY)"; Decimal)
        {
            CalcFormula = sum("Compensation Line CZC"."Ledg. Entry Rem. Amt. (LCY)" where("Compensation No." = field("No.")));
            Caption = 'Balance (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(95; "Compensation Balance (LCY)"; Decimal)
        {
            CalcFormula = sum("Compensation Line CZC"."Amount (LCY)" where("Compensation No." = field("No.")));
            Caption = 'Compensation Balance (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(96; "Compensation Value (LCY)"; Decimal)
        {
            CalcFormula = sum("Compensation Line CZC"."Amount (LCY)" where("Compensation No." = field("No."), "Amount (LCY)" = filter(> 0)));
            Caption = 'Compensation Value (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(165; "Incoming Document Entry No."; Integer)
        {
            Caption = 'Incoming Document Entry No.';
            TableRelation = "Incoming Document";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IncomingDocument: Record "Incoming Document";
            begin
                if "Incoming Document Entry No." = xRec."Incoming Document Entry No." then
                    exit;
                if "Incoming Document Entry No." = 0 then
                    IncomingDocument.RemoveReferenceToWorkingDocument(xRec."Incoming Document Entry No.")
                else
                    IncomingDocument.SetCompensationCZC(Rec);
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        TestField(Status, Status::Open);
        Validate("Incoming Document Entry No.", 0);
        DeleteRecordInApprovalRequest();

        CompensationLineCZC.SetRange("Compensation No.", "No.");
        CompensationLineCZC.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        CompensationsSetupCZC: Record "Compensations Setup CZC";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        CompensationsSetupCZC.Get();
        if "No." = '' then begin
            CompensationsSetupCZC.TestField("Compensation Nos.");
            NoSeriesManagement.InitSeries(CompensationsSetupCZC."Compensation Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
    end;

    trigger OnRename()
    begin
        Error(RenameErr, TableCaption);
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
        CompensReportSelectionsCZC: Record "Compens. Report Selections CZC";
        PostCode: Record "Post Code";
        CompensationApprovMgtCZC: Codeunit "Compensation Approv. Mgt. CZC";
        RenameErr: Label 'You cannot rename a %1.', Comment = '%1 = TableCaption';
        ApprovalProcessPrintErr: Label 'This document can only be printed when the approval process is complete.';

    procedure AssistEdit(OldCompensationHeaderCZC: Record "Compensation Header CZC"): Boolean
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        CompensationsSetupCZC: Record "Compensations Setup CZC";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        CompensationHeaderCZC.Copy(Rec);
        CompensationsSetupCZC.Get();
        CompensationsSetupCZC.TestField("Compensation Nos.");
        if NoSeriesManagement.SelectSeries(CompensationsSetupCZC."Compensation Nos.", OldCompensationHeaderCZC."No. Series", CompensationHeaderCZC."No. Series") then begin
            CompensationsSetupCZC.Get();
            CompensationsSetupCZC.TestField("Compensation Nos.");
            NoSeriesManagement.SetSeries(CompensationHeaderCZC."No.");
            Rec := CompensationHeaderCZC;
            exit(true);
        end;
    end;

    procedure LookupCompanyName(): Boolean
    var
        CustomerLookup: Page "Customer Lookup";
        VendorLookup: Page "Vendor Lookup";
        ContactList: Page "Contact List";
    begin
        case "Company Type" of
            "Company Type"::Customer:
                begin
                    if "Company No." <> '' then
                        Customer.Get("Company No.");
                    CustomerLookup.SetTableView(Customer);
                    CustomerLookup.SetRecord(Customer);
                    CustomerLookup.LookupMode := true;
                    if CustomerLookup.RunModal() = Action::LookupOK then begin
                        CustomerLookup.GetRecord(Customer);
                        Validate("Company No.", Customer."No.");
                        exit(true);
                    end;
                end;
            "Company Type"::Vendor:
                begin
                    if "Company No." <> '' then
                        Vendor.Get("Company No.");
                    VendorLookup.SetTableView(Vendor);
                    VendorLookup.SetRecord(Vendor);
                    VendorLookup.LookupMode := true;
                    if VendorLookup.RunModal() = Action::LookupOK then begin
                        VendorLookup.GetRecord(Vendor);
                        Validate("Company No.", Vendor."No.");
                        exit(true);
                    end;
                end;
            "Company Type"::Contact:
                begin
                    if "Company No." <> '' then
                        Contact.Get("Company No.");
                    Contact.SetRange(Type, Contact.Type::Company);
                    ContactList.SetTableView(Contact);
                    ContactList.SetRecord(Contact);
                    ContactList.LookupMode := true;
                    if ContactList.RunModal() = Action::LookupOK then begin
                        ContactList.GetRecord(Contact);
                        Validate("Company No.", Contact."No.");
                        exit(true);
                    end;
                end;
        end;
    end;

    procedure PrintRecords(ShowRequestForm: Boolean)
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        CompensationHeaderCZC.Copy(Rec);
        CheckCompensationPrintRestrictions();
        CompensationHeaderCZC.FindFirst();
        CompensReportSelectionsCZC.SetRange(Usage, CompensReportSelectionsCZC.Usage::Compensation);
        CompensReportSelectionsCZC.SetFilter("Report ID", '<>0');
        CompensReportSelectionsCZC.FindSet();
        repeat
            Report.RunModal(CompensReportSelectionsCZC."Report ID", ShowRequestForm, false, CompensationHeaderCZC);
        until CompensReportSelectionsCZC.Next() = 0;
    end;

    procedure PerformManualPrintRecords(ShowRequestForm: Boolean)
    begin
        if CompensationApprovMgtCZC.IsCompensationApprovalsWorkflowEnabled(Rec) and (Status = Status::Open) then
            Error(ApprovalProcessPrintErr);

        PrintRecords(ShowRequestForm);
    end;

    procedure PrintToDocumentAttachment()
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        DummyInStream: InStream;
        ReportOutStream: OutStream;
        DocumentInStream: InStream;
        FileName: Text[250];
        DocumentAttachmentFileNameLbl: Label '%1 %2', Comment = '%1 = Usage, %2 = Compensation No.';
    begin
        CompensationHeaderCZC.Copy(Rec);
        CompensationHeaderCZC.SetRecFilter();
        RecordRef.GetTable(CompensationHeaderCZC);
        if not RecordRef.FindFirst() then
            exit;

        CompensReportSelectionsCZC.SetRange(Usage, CompensReportSelectionsCZC.Usage::Compensation);
        CompensReportSelectionsCZC.SetFilter("Report ID", '<>0');
        CompensReportSelectionsCZC.FindSet();
        repeat
            if not Report.RdlcLayout(CompensReportSelectionsCZC."Report ID", DummyInStream) then
                exit;

            Clear(TempBlob);
            TempBlob.CreateOutStream(ReportOutStream);
            Report.SaveAs(CompensReportSelectionsCZC."Report ID", '', ReportFormat::Pdf, ReportOutStream, RecordRef);

            Clear(DocumentAttachment);
            DocumentAttachment.InitFieldsFromRecRef(RecordRef);
            FileName := DocumentAttachment.FindUniqueFileName(
                        StrSubstNo(DocumentAttachmentFileNameLbl, CompensReportSelectionsCZC.Usage, CompensationHeaderCZC."No."), 'pdf');
            TempBlob.CreateInStream(DocumentInStream);
            DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, FileName);
        until CompensReportSelectionsCZC.Next() = 0;
        DocumentAttachmentMgmt.ShowNotification(RecordRef, CompensReportSelectionsCZC.Count(), true);
    end;

    procedure SendToPosting(PostingCodeunitID: Integer)
    begin
        if not IsApprovedPosting() then
            exit;

        Codeunit.Run(PostingCodeunitID, Rec);
    end;

    local procedure IsApprovedPosting(): Boolean
    begin
        if CompensationApprovMgtCZC.PrePostApprovalCheckCompensation(Rec) then
            exit(true);
    end;

    local procedure InitCompanyInformation(CompanyName: Text[100]; CompanyName2: Text[50]; CompanyAddress: Text[100]; CompanyAddress2: Text[50]; CompanyCity: Text[30]; CompanyContact: Text[100]; CompanyPostCode: Code[20]; CompanyCountryRegionCode: Code[10]; CompanyCounty: Text[30])
    begin
        "Company Name" := CompanyName;
        "Company Name 2" := CompanyName2;
        "Company Address" := CompanyAddress;
        "Company Address 2" := CompanyAddress2;
        "Company City" := CompanyCity;
        "Company Contact" := CompanyContact;
        "Company Post Code" := CompanyPostCode;
        "Company Country/Region Code" := CompanyCountryRegionCode;
        "Company County" := CompanyCounty;
    end;

    local procedure ShouldLookForCustomerByName(CustomerNo: Code[20]): Boolean
    begin
        if CustomerNo = '' then
            exit(true);
        if not Customer.Get(CustomerNo) THEN
            exit(true);
        exit(not Customer."Disable Search by Name");
    end;

    local procedure ShouldLookForVendorByName(VendorNo: Code[20]): Boolean
    begin
        if VendorNo = '' then
            exit(true);
        if not Vendor.Get(VendorNo) THEN
            exit(true);
        exit(not Vendor."Disable Search by Name");
    end;

    procedure CheckCompensationReleaseRestrictions()
    begin
        OnCheckCompensationReleaseRestrictions();
        CompensationApprovMgtCZC.PrePostApprovalCheckCompensation(Rec);
    end;

    procedure CheckCompensationPostRestrictions()
    begin
        OnCheckCompensationPostRestrictions();
    end;

    procedure CheckCompensationPrintRestrictions()
    begin
        OnCheckCompensationPrintRestrictions();
    end;

    local procedure DeleteRecordInApprovalRequest()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDeleteRecordInApprovalRequest(Rec, IsHandled);
        if IsHandled then
            exit;

        ApprovalsMgmt.OnDeleteRecordInApprovalRequest(RecordId);
    end;

    internal procedure PerformManualRelease(var CompensationHeaderCZC: Record "Compensation Header CZC")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        NoOfSelected: Integer;
        NoOfSkipped: Integer;
    begin
        NoOfSelected := CompensationHeaderCZC.Count();
        CompensationHeaderCZC.SetFilter(Status, '<>%1', CompensationHeaderCZC.Status::Released);
        NoOfSkipped := NoOfSelected - CompensationHeaderCZC.Count();
        BatchProcessingMgt.BatchProcess(CompensationHeaderCZC, Codeunit::"Comp. Doc. Manual Release CZC", "Error Handling Options"::"Show Error", NoOfSelected, NoOfSkipped);
    end;

    internal procedure PerformManualReopen(var CompensationHeaderCZC: Record "Compensation Header CZC")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        NoOfSelected: Integer;
        NoOfSkipped: Integer;
    begin
        NoOfSelected := CompensationHeaderCZC.Count();
        CompensationHeaderCZC.SetFilter(Status, '<>%1', CompensationHeaderCZC.Status::Open);
        NoOfSkipped := NoOfSelected - CompensationHeaderCZC.Count();
        BatchProcessingMgt.BatchProcess(CompensationHeaderCZC, Codeunit::"Comp. Doc. Manual Reopen CZC", "Error Handling Options"::"Show Error", NoOfSelected, NoOfSkipped);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCheckCompensationReleaseRestrictions()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCheckCompensationPostRestrictions()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCheckCompensationPrintRestrictions()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDeleteRecordInApprovalRequest(var CompensationHeaderCZC: Record "Compensation Header CZC"; var IsHandled: Boolean);
    begin
    end;
}
