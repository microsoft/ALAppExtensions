// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;

codeunit 10031 "IRS 1099 Form Document"
{
    Access = Internal;

    var
        Telemetry: Codeunit Telemetry;
        ReportingPeriodNotDefinedErr: Label 'Reporting period is not defined';
        CannotChangeIRSDataInEntryConnectedToFormDocumentErr: Label 'You cannot change the IRS data in the vendor ledger entry connected to the form document. Period = %1, Vendor No. = %2, Form No. = %3', Comment = '%1 = Period No., %2 = Vendor No., %3 = Form No.';
        FormDocHasBeenMarkedAsSubmittedMsg: Label 'The form document %1 has been marked as submitted', Comment = '%1 = document id';
        IRSFormsTok: Label 'IRS Forms', Locked = true;

    procedure Reopen(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    begin
        if IRS1099FormDocHeader.Status <> IRS1099FormDocHeader.Status::Released then
            IRS1099FormDocHeader.FieldError(Status);
        IRS1099FormDocHeader.Validate(Status, IRS1099FormDocHeader.Status::Open);
        IRS1099FormDocHeader.Modify(true);
    end;

    procedure Release(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    begin
        if IRS1099FormDocHeader.Status <> IRS1099FormDocHeader.Status::Open then
            IRS1099FormDocHeader.FieldError(Status);
        IRS1099FormDocHeader.Validate(Status, IRS1099FormDocHeader.Status::Released);
        IRS1099FormDocHeader.Modify(true);
    end;

    procedure CreateForms(PeriodNo: Code[20])
    begin
        RunCreateFormDocsReport(PeriodNo, '', '', false);
    end;

    procedure RecreateForm(IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    begin
        RunCreateFormDocsReport(IRS1099FormDocHeader."Period No.", IRS1099FormDocHeader."Vendor No.", IRS1099FormDocHeader."Form No.", true);
    end;

    local procedure RunCreateFormDocsReport(PeriodNo: Code[20]; VendorNo: Code[20]; FormNo: Code[20]; Recreate: Boolean)
    var
        IRS1099CreateFormDocs: Report "IRS 1099 Create Form Docs";
    begin
        IRS1099CreateFormDocs.InitializeRequest(PeriodNo, VendorNo, FormNo, Recreate);
        IRS1099CreateFormDocs.RunModal();
    end;

    procedure CreateFormDocs(IRS1099CalcParameters: Record "IRS 1099 Calc. Params");
    var
        IRSFormsSetup: Record "IRS Forms Setup";
        TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        IRSFormsFacade: Codeunit "IRS Forms Facade";
    begin
        if IRS1099CalcParameters."Period No." = '' then
            error(ReportingPeriodNotDefinedErr);
        IRSFormsSetup.InitSetup();
        IRSFormsFacade.GetVendorFormBoxAmount(TempVendFormBoxBuffer, IRS1099CalcParameters);
        IRSFormsFacade.CreateFormDocs(TempVendFormBoxBuffer, IRS1099CalcParameters);
    end;

    procedure MarkAsSubmitted(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    begin
        IRS1099FormDocHeader.Validate(Status, IRS1099FormDocHeader.Status::Submitted);
        IRS1099FormDocHeader.Modify(true);
        Telemetry.LogMessage('0000MJP', StrSubstNo(FormDocHasBeenMarkedAsSubmittedMsg, IRS1099FormDocHeader.ID), Verbosity::Verbose, DataClassification::SystemMetadata);
    end;

    procedure DrillDownCalculatedAmountInLine(IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line")
    var
        IRSFormsSetup: Record "IRS Forms Setup";
        IRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail";
    begin
        IRSFormsSetup.Get();
        IRSFormsSetup.TestField("Collect Details For Line");
        IRS1099FormDocLineDetail.SetRange("Document ID", IRS1099FormDocLine."Document ID");
        IRS1099FormDocLineDetail.SetRange("Line No.", IRS1099FormDocLine."Line No.");
        Page.Run(0, IRS1099FormDocLineDetail);
    end;

    procedure CheckIfVendLedgEntryAllowed(EntryNo: Integer)
    var
        IRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
    begin
        IRS1099FormDocLineDetail.SetRange("Vendor Ledger Entry No.", EntryNo);
        if IRS1099FormDocLineDetail.FindFirst() then begin
            IRS1099FormDocHeader.Get(IRS1099FormDocLineDetail."Document ID");
            Error(CannotChangeIRSDataInEntryConnectedToFormDocumentErr, IRS1099FormDocHeader."Period No.", IRS1099FormDocHeader."Vendor No.", IRS1099FormDocHeader."Form No.");
        end;
    end;

    procedure GetActivityLogContext(): Text[30]
    begin
        exit(IRSFormsTok);
    end;
}
