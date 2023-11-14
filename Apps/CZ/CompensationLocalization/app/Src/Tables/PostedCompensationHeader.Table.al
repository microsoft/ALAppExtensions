// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.CRM.Team;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.Navigate;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Globalization;
using System.Security.AccessControl;
using System.Utilities;

#pragma warning disable AA0232
table 31274 "Posted Compensation Header CZC"
{
    Caption = 'Posted Compensation Header';
    DataCaptionFields = "No.", Description;
    LookupPageID = "Posted Compensation List CZC";

    fields
    {
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
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
        }
        field(15; "Company No."; Code[20])
        {
            Caption = 'Company No.';
            TableRelation = if ("Company Type" = const(Customer)) Customer else
            if ("Company Type" = const(Vendor)) Vendor;
            DataClassification = CustomerContent;
        }
        field(20; "Company Name"; Text[100])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
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
        }
        field(55; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(65; "Salesperson/Purchaser Code"; Code[20])
        {
            Caption = 'Salesperson/Purchaser Code';
            TableRelation = "Salesperson/Purchaser";
            DataClassification = CustomerContent;
        }
        field(70; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
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
            CalcFormula = sum("Posted Compensation Line CZC"."Ledg. Entry Rem. Amt. (LCY)" where("Compensation No." = field("No.")));
            Caption = 'Balance (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(95; "Compensation Balance (LCY)"; Decimal)
        {
            CalcFormula = sum("Posted Compensation Line CZC"."Amount (LCY)" where("Compensation No." = field("No.")));
            Caption = 'Compensation Balance (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(96; "Compensation Value (LCY)"; Decimal)
        {
            CalcFormula = sum("Posted Compensation Line CZC"."Amount (LCY)" where("Compensation No." = field("No."), "Amount (LCY)" = filter(> 0)));
            Caption = 'Compensation Value (LCY)';
            Editable = false;
            FieldClass = FlowField;
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
        PostedCompensationLineCZC: Record "Posted Compensation Line CZC";
    begin
        PostedCompensationLineCZC.SetRange("Compensation No.", "No.");
        PostedCompensationLineCZC.DeleteAll(true);
    end;

    var
        CompensReportSelectionsCZC: Record "Compens. Report Selections CZC";

    procedure Navigation()
    var
        Navigate: Page Navigate;
    begin
        Navigate.SetDoc("Posting Date", "No.");
        Navigate.Run();
    end;

    procedure PrintRecords(ShowRequestForm: Boolean)
    var
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
    begin
        PostedCompensationHeaderCZC.Reset();
        PostedCompensationHeaderCZC.Copy(Rec);
        PostedCompensationHeaderCZC.FindFirst();
        CompensReportSelectionsCZC.SetRange(Usage, CompensReportSelectionsCZC.Usage::"Posted Compensation");
        CompensReportSelectionsCZC.SetFilter("Report ID", '<>0');
        CompensReportSelectionsCZC.FindSet();
        repeat
            Report.RunModal(CompensReportSelectionsCZC."Report ID", ShowRequestForm, false, PostedCompensationHeaderCZC);
        until CompensReportSelectionsCZC.Next() = 0;
    end;

    procedure PrintToDocumentAttachment()
    var
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
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
        PostedCompensationHeaderCZC.Copy(Rec);
        PostedCompensationHeaderCZC.SetRecFilter();
        RecordRef.GetTable(PostedCompensationHeaderCZC);
        if not RecordRef.FindFirst() then
            exit;

        CompensReportSelectionsCZC.SetRange(Usage, CompensReportSelectionsCZC.Usage::"Posted Compensation");
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
                        StrSubstNo(DocumentAttachmentFileNameLbl, CompensReportSelectionsCZC.Usage, PostedCompensationHeaderCZC."No."), 'pdf');
            TempBlob.CreateInStream(DocumentInStream);
            DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, FileName);
        until CompensReportSelectionsCZC.Next() = 0;
        DocumentAttachmentMgmt.ShowNotification(RecordRef, CompensReportSelectionsCZC.Count(), true);
    end;
}

