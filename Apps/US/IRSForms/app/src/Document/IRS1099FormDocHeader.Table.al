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

    trigger OnDelete()
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormReport: Record "IRS 1099 Form Report";
    begin
        TestStatusOpen();
        IRS1099FormDocLine.SetRange("Document ID", ID);
        IRS1099FormDocLine.DeleteAll(true);
        IRS1099FormReport.SetRange("Document ID", ID);
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
        if not IRS1099FormDocHeader.IsEmpty() then
            Error(CannotCreateFormDocSamePeriodVendorFormErr);
    end;
}
