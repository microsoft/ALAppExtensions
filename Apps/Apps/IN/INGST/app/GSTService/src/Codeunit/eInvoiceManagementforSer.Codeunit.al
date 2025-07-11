// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Services;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Sales;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Service.History;
using Microsoft.Service.Posting;

codeunit 18161 "e-Invoice Management for Ser."
{
    Permissions = tabledata "Service Invoice Header" = rm,
                  tabledata "Service Cr.Memo Header" = rm;

    var
        IRNLengthErr: Label 'IRN Hash must be 64 character text.', Locked = true;
        AccountingPeriodErr: Label 'Tax Accounting Period does not exist for the given Date %1.', Comment = '%1 = Posting Date';

    [EventSubscriber(ObjectType::Table, Database::"Service Invoice Header", 'OnAfterValidateEvent', 'IRN Hash', false, false)]
    local procedure OnAfterValidateIRNHashOnInvoice(var Rec: Record "Service Invoice Header")
    begin
        CheckIRNHashLength(Rec."IRN Hash");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Cr.Memo Header", 'OnAfterValidateEvent', 'IRN Hash', false, false)]
    local procedure OnAfterValidateIRNHashOnCreditMemo(var Rec: Record "Service Cr.Memo Header")
    begin
        CheckIRNHashLength(Rec."IRN Hash");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnAfterPostServiceDoc', '', false, false)]
    local procedure CreateJsonFile(ServInvoiceNo: Code[20]; ServCrMemoNo: Code[20])
    var
        GSTSetup: Record "GST Setup";
    begin
        GSTSetup.Get();
        if not (GSTSetup."Generate E-Inv. on Ser. Post" and GuiAllowed) then
            exit;

        Case true of
            ServInvoiceNo <> '':
                GenerateIrnOnServiceInvoice(ServInvoiceNo);
            ServCrMemoNo <> '':
                GenerateIrnOnServiceCrMemo(ServCrMemoNo);
        end;
    end;

    local procedure GenerateIrnOnServiceCrMemo(ServCrMemoNo: Code[20])
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        eInvoiceJsonHandlerForSer: Codeunit "e-Invoice Json Handler for Ser";
    begin
        ServiceCrMemoHeader.Get(ServCrMemoNo);
        if not (ServiceCrMemoHeader."GST Customer Type" in [ServiceCrMemoHeader."GST Customer Type"::Unregistered, ServiceCrMemoHeader."GST Customer Type"::" "]) then begin
            eInvoiceJsonHandlerForSer.SetCrMemoHeader(ServiceCrMemoHeader);
            eInvoiceJsonHandlerForSer.Run();
            GenerateIRN(ServCrMemoNo, Database::"Service Cr.Memo Header");
        end;
    end;

    local procedure GenerateIrnOnServiceInvoice(ServInvoiceNo: Code[20])
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        eInvoiceJsonHandlerForSer: Codeunit "e-Invoice Json Handler for Ser";
    begin
        ServiceInvoiceHeader.Get(ServInvoiceNo);
        if not (ServiceInvoiceHeader."GST Customer Type" in [ServiceInvoiceHeader."GST Customer Type"::Unregistered, ServiceInvoiceHeader."GST Customer Type"::" "]) then begin
            eInvoiceJsonHandlerForSer.SetServiceInvHeader(ServiceInvoiceHeader);
            eInvoiceJsonHandlerForSer.Run();
            GenerateIRN(ServInvoiceNo, Database::"Service Invoice Header");
        end;
    end;

    local procedure CheckIRNHashLength(IRNHash: Text[64])
    begin
        if (IRNHash <> '') and (StrLen(IRNHash) < 64) then
            Error(IRNLengthErr);
    end;

    procedure GenerateIRN(DocNo: Code[20]; CallByTable: Integer)
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
        GSTSetup: Record "GST Setup";
        TaxType: Record "Tax Type";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        eInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        InvoiceType: Enum "Service Invoice Type";
        IRNInput: Text;
        FINYr: Text;
        InvoiceTypeText: Text;
        PostingDate: Date;
    begin
        RecordRef.Open(CallByTable);
        FieldRef := RecordRef.Field(3);
        FieldRef.Value := DocNo;
        if not RecordRef.Find('=') then
            exit;

        if not GSTSetup.Get() then
            exit;

        TaxType.Get(GSTSetup."GST Tax Type");

        if Not IsGSTApplicable(DocNo, CallByTable) then
            exit;

        FieldRef := RecordRef.Field(ServiceInvoiceHeader.FieldNo("Posting Date"));
        PostingDate := FieldRef.Value;
        FieldRef := RecordRef.Field(ServiceInvoiceHeader.FieldNo("Invoice Type"));
        InvoiceType := FieldRef.Value;

        TaxAccountingPeriod.SetRange("Tax Type Code", TaxType."Accounting Period");
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
        TaxAccountingPeriod.SetFilter("Ending Date", '>=%1', PostingDate);
        if TaxAccountingPeriod.FindFirst() then begin
            FINYr := Format(TaxAccountingPeriod."Starting Date", 0, '<Year4>');
            FINYr += '-' + Format(TaxAccountingPeriod."Ending Date", 0, '<Year>');
        end else
            Error(AccountingPeriodErr, PostingDate);

        if CallByTable = Database::"Service Invoice Header" then begin
            if (InvoiceType = InvoiceType::"Debit Note") or (InvoiceType = InvoiceType::Supplementary) then
                InvoiceTypeText := 'DBN'
            else
                InvoiceTypeText := 'INV';
        end else
            InvoiceTypeText := 'CRN';

        FieldRef := RecordRef.Field(ServiceInvoiceHeader.FieldNo("Location GST Reg. No."));
        IRNInput := Format(FieldRef.Value) + FINYr + InvoiceTypeText + DocNo;
        FieldRef := RecordRef.Field(ServiceInvoiceHeader.FieldNo("IRN Hash"));
        FieldRef.Value := eInvoiceJsonHandler.GenerateIRN(IRNInput);
        RecordRef.Modify();
    end;

    procedure IsGSTApplicable(DocumentNo: Code[20]; TableID: Integer): Boolean
    var
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        case TableID of
            Database::"Service Invoice Header":
                exit(CheckServiceInvoiceLine(DocumentNo, GSTSetup."GST Tax Type"));
            Database::"Service Cr.Memo Header":
                exit(CheckServiceCrMemoLine(DocumentNo, GSTSetup."GST Tax Type"));
        end;
    end;

    local procedure CheckServiceInvoiceLine(DocumentNo: Code[20]; TaxType: Code[20]): Boolean
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
        Found: Boolean;
    begin
        ServiceInvoiceLine.SetRange("Document No.", DocumentNo);
        ServiceInvoiceLine.SetFilter("No.", '<>%1', '');
        if ServiceInvoiceLine.FindSet() then
            repeat
                Found := TransactionValueExist(ServiceInvoiceLine.RecordId, TaxType);
            until (ServiceInvoiceLine.Next() = 0) or Found;

        exit(Found);
    end;

    local procedure CheckServiceCrMemoLine(DocumentNo: Code[20]; TaxType: Code[20]): Boolean
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        Found: Boolean;
    begin
        ServiceCrMemoLine.SetRange("Document No.", DocumentNo);
        ServiceCrMemoLine.SetFilter("No.", '<>%1', '');
        if ServiceCrMemoLine.FindSet() then
            repeat
                Found := TransactionValueExist(ServiceCrMemoLine.RecordId, TaxType);
            until (ServiceCrMemoLine.Next() = 0) or Found;

        exit(Found);
    end;

    local procedure TransactionValueExist(RecID: RecordID; TaxType: Code[20]): Boolean
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Type", TaxType);
        TaxTransactionValue.SetRange("Tax Record ID", RecId);
        Exit(not TaxTransactionValue.IsEmpty());
    end;
}
