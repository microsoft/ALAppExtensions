// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;
using System.EMail;
using System.Utilities;

table 10035 "IRS 1099 Form Doc. Header"
{
    DataClassification = CustomerContent;
    Caption = 'IRS 1099 Form Document Header';
    DataCaptionFields = "Period No.", "Vendor No.", "Form No.";
    DrillDownPageId = "IRS 1099 Form Documents";
    LookupPageId = "IRS 1099 Form Documents";

    fields
    {
        field(1; ID; Integer)
        {
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Period No."; Code[20])
        {
            TableRelation = "IRS Reporting Period";
        }
        field(3; "Vendor No."; Code[20])
        {
            TableRelation = Vendor;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                TestStatusOpen();
                CheckNoLinesExist();
                CheckPeriodFormVendUniqueness();
                if "Vendor No." <> '' then
                    if Vendor.Get("Vendor No.") then;
                Validate("Receiving 1099 E-Form Consent", Vendor."Receiving 1099 E-Form Consent");
                if Vendor."E-Mail For IRS" = '' then
                    Validate("Vendor E-Mail", Vendor."E-Mail")
                else
                    Validate("Vendor E-Mail", Vendor."E-Mail For IRS");
            end;
        }
        field(4; "Form No."; Code[20])
        {
            TableRelation = "IRS 1099 Form"."No." where("Period No." = field("Period No."));

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckNoLinesExist();
                CheckPeriodFormVendUniqueness();
            end;
        }
        field(10; Status; Enum "IRS 1099 Form Doc. Status")
        {
            Editable = false;

            trigger OnValidate()
            begin
                if Rec.Status = Enum::"IRS 1099 Form Doc. Status"::Released then
                    if NeedsCorrectionOnRelease() then
                        Rec."IRIS Needs Correction" := true;
            end;
        }
        field(11; "Allow Correction"; Boolean)
        {
            Caption = 'Allow Correction';
            ToolTip = 'Specifies if the 1099 form document can be reopened for correction.';
            Editable = false;
        }
        field(20; "Copy B Sent"; Boolean)
        {
            Editable = false;
        }
        field(21; "Copy 2 Sent"; Boolean)
        {
            Editable = false;
        }
        field(22; "Email Error Log"; Text[1024])
        {
            Editable = false;
        }
        field(50; "Receiving 1099 E-Form Consent"; Boolean)
        {
            Editable = false;
        }
        field(51; "Vendor E-Mail"; Text[80])
        {
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                ConfirmManagement: Codeunit "Confirm Management";
                MailManagement: Codeunit "Mail Management";
            begin
                if (Rec."Vendor E-Mail" = '') and (Rec."Receiving 1099 E-Form Consent") then
                    Error(CannotBlankEmailWithConsentErr);
                if Rec."Vendor E-Mail" <> '' then
                    MailManagement.CheckValidEmailAddresses(Rec."Vendor E-Mail");
                if (xRec."Vendor E-Mail" <> '') and (Rec."Vendor E-Mail" <> xRec."Vendor E-Mail") then
                    if not ConfirmManagement.GetResponse(EmailAddressChangeQst, false) then
                        Rec."Vendor E-Mail" := xRec."Vendor E-Mail";
            end;
        }
        field(60; "IRIS Transmission Document ID"; Integer)
        {
            Editable = false;
        }
        field(62; "IRIS Submission ID"; Text[20])
        {
            Caption = 'Submission ID';
            ToolTip = 'Specifies the unique identifier of a group of 1099 forms of the same type within the transmission, e.g., 1099-MISC, that are sent to the IRS using IRIS. The submission ID is defined when the transmission XML file is created.';
            Editable = false;
        }
        field(63; "IRIS Record ID"; Text[20])
        {
            Caption = 'Record ID';
            ToolTip = 'Specifies the identifier of the 1099 form within the submission.';
            Editable = false;
        }
        field(65; "IRIS Submission Status"; Enum "Transmission Status IRIS")
        {
            Caption = 'Submission Status';
            ToolTip = 'Specifies the status of the submission returned by the IRS after the transmission is sent.';
            Editable = false;
        }
        field(66; "IRIS Last Accepted Receipt ID"; Text[100])
        {
            Caption = 'Last Accepted Receipt ID';
            ToolTip = 'Specifies the last accepted receipt identifier returned by the IRIS system for the submission to which the 1099 form belongs.';
            Editable = false;
        }
        field(67; "IRIS Last Receipt ID"; Text[100])
        {
            Caption = 'Last Receipt ID';
            ToolTip = 'Specifies the last receipt identifier returned by the IRIS system for the submission to which the 1099 form belongs.';
            Editable = false;
        }
        field(70; "IRIS Needs Correction"; Boolean)
        {
            Caption = 'Needs Correction';
#pragma warning disable AA0219
            ToolTip = 'Select this check box if the 1099 form should be sent in a correction transmission.';
#pragma warning restore AA0219
        }
        field(71; "IRIS Updated Not Sent"; Boolean)
        {
            Caption = 'Updated Not Sent';
            ToolTip = 'Specifies if the 1099 form was opened and then released but has not been sent yet to IRIS after release.';
            Editable = false;
        }
        field(72; "IRIS Corrected"; Boolean)
        {
            Caption = 'Corrected';
            ToolTip = 'Specifies if the selected 1099 form was previously sent in a correction transmission.';
            Editable = false;
        }
        field(73; "IRIS Corrected to Zeros"; Boolean)
        {
            Caption = 'Corrected to Zeros';
            ToolTip = 'Specifies if the selected 1099 form was sent in a correction transmission with all amounts set to zero.';
            Editable = false;
        }
        field(100; "Vendor Name"; Text[100])
        {
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
            FieldClass = FlowField;
            Editable = false;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
        key(PeriodFormVend; "Period No.", "Vendor No.", "Form No.")
        {

        }
    }

    var
        CannotBlankEmailWithConsentErr: Label 'The email address cannot be blank when the Receiving 1099 E-Form Consent field is selected.';
        CannotCreateFormDocSamePeriodVendorFormErr: Label 'You cannot create multiple form documents with the same period, vendor and form.';
        EmailAddressChangeQst: Label 'The email address has been changed. Do you want to continue?';
        CannotMakeChangeWhenLineExistErr: Label 'You cannot make this change when one or more lines exist.';
        UniquenessFilterModifiedErr: Label 'It is not allowed to modify the period, vendor or form uniqueness filter in the customization.';
        DocumentLinkedToTransmissionErr: Label 'You cannot delete this document because it is linked to a transmission. Document ID: %1', Comment = '%1 = Document ID';

    trigger OnDelete()
    begin
        TestStatusOpen();
        CheckLinkToTransmission();
        RemoveRelatedRecords();
    end;

    internal procedure RemoveRelatedRecords()
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormReport: Record "IRS 1099 Form Report";
    begin
        IRS1099FormDocLine.SetRange("Document ID", Rec.ID);
        IRS1099FormDocLine.DeleteAll(true);
        IRS1099FormReport.SetRange("Document ID", Rec.ID);
        IRS1099FormReport.DeleteAll(true);
    end;

    local procedure CheckNoLinesExist()
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
    begin
        IRS1099FormDocLine.SetRange("Document ID", ID);
        if not IRS1099FormDocLine.IsEmpty() then
            Error(CannotMakeChangeWhenLineExistErr);
    end;

    local procedure TestStatusOpen()
    begin
        TestField(Status, Status::Open);
    end;

    local procedure CheckLinkToTransmission()
    begin
        if "IRIS Transmission Document ID" <> 0 then
            Error(DocumentLinkedToTransmissionErr, ID);
    end;

    local procedure NeedsCorrectionOnRelease(): Boolean
    begin
        exit(Rec."IRIS Submission Status" in
            [Enum::"Transmission Status IRIS"::Accepted,
             Enum::"Transmission Status IRIS"::"Accepted with Errors",
             Enum::"Transmission Status IRIS"::"Partially Accepted",
             Enum::"Transmission Status IRIS"::Rejected]);
    end;

    local procedure CheckPeriodFormVendUniqueness()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
    begin
        if Rec."Vendor No." = '' then
            exit;
        if Rec."Form No." = '' then
            exit;
        IRS1099FormDocHeader.SetFilter(Id, '<>%1', ID);
        IRS1099FormDocHeader.SetRange("Period No.", "Period No.");
        IRS1099FormDocHeader.SetRange("Vendor No.", "Vendor No.");
        IRS1099FormDocHeader.SetRange("Form No.", "Form No.");
        IRS1099FormDocHeader.SetFilter(Status, '<>%1', Status::Abandoned);
        AddPeriodFormVendUniquenessFilters(IRS1099FormDocHeader);
        if not IRS1099FormDocHeader.IsEmpty() then
            Error(CannotCreateFormDocSamePeriodVendorFormErr);
    end;

    local procedure AddPeriodFormVendUniquenessFilters(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    begin
        OnAddPeriodFormVendUniquenessFilters(IRS1099FormDocHeader);
        if (IRS1099FormDocHeader.GetFilter("Period No.") <> Rec."Period No.") or
           (IRS1099FormDocHeader.GetFilter("Vendor No.") <> Rec."Vendor No.") or
           (IRS1099FormDocHeader.GetFilter("Form No.") <> Rec."Form No.")
        then
            Error(UniquenessFilterModifiedErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddPeriodFormVendUniquenessFilters(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    begin
    end;
}
