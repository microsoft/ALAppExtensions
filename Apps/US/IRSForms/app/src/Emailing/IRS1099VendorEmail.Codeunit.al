// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;
using System.Utilities;

codeunit 10050 "IRS 1099 Vendor Email"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
#if not CLEAN25
        IRSFormsFeature: Codeunit "IRS Forms Feature";
#endif
        EmailNotSpecifiedErr: Label 'Either E-Mail For IRS or E-mail must be specified to receive 1099 forms electronically.';
        PropagateFieldToOpenedFormDocumentsQst: Label 'Do you want to propagate the %1 to all opened 1099 form documents by this vendor?', Comment = '%1 = field name';
        PropagateFieldToSubmittedFormDocumentsQst: Label 'Do you want to propagate the %1 to all submitted 1099 form documents by this vendor?', Comment = '%1 = field name';
        CannotRemoveEmailWhenOpenedFormDocsExistErr: Label 'Cannot remove the e-mail when opened 1099 form documents exist for this vendor.';

    procedure CheckEmailForIRS(Vendor: Record Vendor)
    begin
#if not CLEAN25
        if not IRSFormsFeature.IsEnabled() then
            exit;
#endif
        if GetEmailForIRSReporting(Vendor) = '' then
            error(EmailNotSpecifiedErr);
    end;

    procedure ClearConsentForEmptyEmail(var Vendor: Record Vendor)
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
    begin
#if not CLEAN25
        if not IRSFormsFeature.IsEnabled() then
            exit;
#endif
        if GetEmailForIRSReporting(Vendor) = '' then begin
            if Vendor."Receiving 1099 E-Form Consent" then begin
                IRS1099FormDocHeader.SetRange("Vendor No.", Vendor."No.");
                IRS1099FormDocHeader.SetRange(Status, IRS1099FormDocHeader.Status::Open);
                if not IRS1099FormDocHeader.IsEmpty() then
                    Error(CannotRemoveEmailWhenOpenedFormDocsExistErr);
            end;
            Vendor."Receiving 1099 E-Form Consent" := false;
        end;
    end;

    procedure PropagateEmailToFormDocuments(Vendor: Record Vendor)
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
#if not CLEAN25
        if not IRSFormsFeature.IsEnabled() then
            exit;
#endif
        IRS1099FormDocHeader.SetRange("Vendor No.", Vendor."No.");
        IRS1099FormDocHeader.SetRange(Status, IRS1099FormDocHeader.Status::Open);
        if not IRS1099FormDocHeader.IsEmpty() then
            if ConfirmManagement.GetResponse(StrSubstNo(PropagateFieldToOpenedFormDocumentsQst, Vendor.FieldCaption("E-Mail")), false) then
                IRS1099FormDocHeader.ModifyAll("Vendor E-Mail", GetEmailForIRSReporting(Vendor));

        IRS1099FormDocHeader.SetRange(Status, IRS1099FormDocHeader.Status::Submitted);
        if not IRS1099FormDocHeader.IsEmpty() then
            if ConfirmManagement.GetResponse(StrSubstNo(PropagateFieldToSubmittedFormDocumentsQst, Vendor.FieldCaption("E-Mail")), false) then
                IRS1099FormDocHeader.ModifyAll("Vendor E-Mail", GetEmailForIRSReporting(Vendor));
    end;

    procedure PropagateReceiving1099EFormConsentToFormDocuments(Vendor: Record Vendor)
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
#if not CLEAN25
        if not IRSFormsFeature.IsEnabled() then
            exit;
#endif
        IRS1099FormDocHeader.SetRange("Vendor No.", Vendor."No.");
        IRS1099FormDocHeader.SetRange(Status, IRS1099FormDocHeader.Status::Open);
        if not IRS1099FormDocHeader.IsEmpty() then
            if ConfirmManagement.GetResponse(
                StrSubstNo(PropagateFieldToOpenedFormDocumentsQst, Vendor.FieldCaption("Receiving 1099 E-Form Consent")), false)
            then
                IRS1099FormDocHeader.ModifyAll("Receiving 1099 E-Form Consent", Vendor."Receiving 1099 E-Form Consent");

        IRS1099FormDocHeader.SetRange(Status, IRS1099FormDocHeader.Status::Submitted);
        if not IRS1099FormDocHeader.IsEmpty() then
            if ConfirmManagement.GetResponse(
                StrSubstNo(PropagateFieldToSubmittedFormDocumentsQst, Vendor.FieldCaption("Receiving 1099 E-Form Consent")), false)
            then
                IRS1099FormDocHeader.ModifyAll("Receiving 1099 E-Form Consent", Vendor."Receiving 1099 E-Form Consent");
    end;

    local procedure GetEmailForIRSReporting(Vendor: Record Vendor): Text[80]
    begin
        if Vendor."E-Mail For IRS" <> '' then
            exit(Vendor."E-Mail For IRS");
        exit(Vendor."E-Mail");
    end;
}
