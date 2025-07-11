// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Sales;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;

codeunit 18146 "e-Invoice Management"
{
    Permissions = tabledata "Sales Invoice Header" = rm,
                  tabledata "Sales Cr.Memo Header" = rm;

    var
        IRNLengthErr: Label 'IRN Hash must be 64 character text.', Locked = true;
        AccountingPeriodErr: Label 'Tax Accounting Period does not exist for the given Date %1.', Comment = '%1 = Posting Date';

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnAfterValidateEvent', 'IRN Hash', false, false)]
    local procedure OnAfterValidateIRNHashOnInvoice(var Rec: Record "Sales Invoice Header")
    begin
        CheckIRNHashLength(Rec."IRN Hash");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Header", 'OnAfterValidateEvent', 'IRN Hash', false, false)]
    local procedure OnAfterValidateIRNHashOnCreditMemo(var Rec: Record "Sales Cr.Memo Header")
    begin
        CheckIRNHashLength(Rec."IRN Hash");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure CreateJsonFile(SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        eInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
    begin
        GeneralLedgerSetup.Get();
        if SalesInvHdrNo <> '' then begin
            SalesInvoiceHeader.Reset();
            SalesInvoiceHeader.SetRange("No.", SalesInvHdrNo);
            if SalesInvoiceHeader.FindFirst() then
                if not (SalesInvoiceHeader."GST Customer Type" in
                        [SalesInvoiceHeader."GST Customer Type"::Unregistered,
                         SalesInvoiceHeader."GST Customer Type"::" "])
                then
                    if GeneralLedgerSetup."Generate E-Inv. on Sales Post" and GuiAllowed then begin
                        SalesInvoiceHeader.Mark(true);
                        eInvoiceJsonHandler.SetSalesInvHeader(SalesInvoiceHeader);
                        eInvoiceJsonHandler.Run();
                        GenerateIRN(SalesInvHdrNo, Database::"Sales Invoice Header");
                    end;
        end else
            if SalesCrMemoHdrNo <> '' then begin
                SalesCrMemoHeader.Reset();
                SalesCrMemoHeader.SetRange("No.", SalesCrMemoHdrNo);
                if SalesCrMemoHeader.FindFirst() then
                    if not (SalesCrMemoHeader."GST Customer Type" in
                            [SalesCrMemoHeader."GST Customer Type"::Unregistered,
                             SalesCrMemoHeader."GST Customer Type"::" "])
                    then
                        if GeneralLedgerSetup."Generate E-Inv. on Sales Post" and GuiAllowed then begin
                            SalesCrMemoHeader.Mark(true);
                            eInvoiceJsonHandler.SetCrMemoHeader(SalesCrMemoHeader);
                            eInvoiceJsonHandler.Run();
                            GenerateIRN(SalesCrMemoHdrNo, Database::"Sales Cr.Memo Header");
                        end;
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
        SalesInvoiceHeader: Record "Sales Invoice Header";
        eInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        InvoiceType: Enum "Sales Invoice Type";
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

        FieldRef := RecordRef.Field(SalesInvoiceHeader.FieldNo("Posting Date"));
        PostingDate := FieldRef.Value;
        FieldRef := RecordRef.Field(SalesInvoiceHeader.FieldNo("Invoice Type"));
        InvoiceType := FieldRef.Value;

        TaxAccountingPeriod.SetRange("Tax Type Code", TaxType."Accounting Period");
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
        TaxAccountingPeriod.SetFilter("Ending Date", '>=%1', PostingDate);
        if TaxAccountingPeriod.FindFirst() then begin
            FINYr := Format(TaxAccountingPeriod."Starting Date", 0, '<Year4>');
            FINYr += '-' + Format(TaxAccountingPeriod."Ending Date", 0, '<Year>');
        end else
            Error(AccountingPeriodErr, PostingDate);

        if CallByTable = Database::"Sales Invoice Header" then begin
            if (InvoiceType = InvoiceType::"Debit Note") or (InvoiceType = InvoiceType::Supplementary) then
                InvoiceTypeText := 'DBN'
            else
                InvoiceTypeText := 'INV';
        end else
            InvoiceTypeText := 'CRN';

        FieldRef := RecordRef.Field(SalesInvoiceHeader.FieldNo("Location GST Reg. No."));
        IRNInput := Format(FieldRef.Value) + FINYr + InvoiceTypeText + DocNo;
        FieldRef := RecordRef.Field(SalesInvoiceHeader.FieldNo("IRN Hash"));
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
            Database::"Sales Invoice Header":
                exit(CheckSalesInvoiceLine(DocumentNo, GSTSetup."GST Tax Type"));
            Database::"Sales Cr.Memo Header":
                exit(CheckSalesCrMemoLine(DocumentNo, GSTSetup."GST Tax Type"));
        end;
    end;

    local procedure CheckSalesInvoiceLine(DocumentNo: Code[20]; TaxType: Code[20]): Boolean
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        Found: Boolean;
    begin
        SalesInvoiceLine.SetRange("Document No.", DocumentNo);
        SalesInvoiceLine.SetFilter("No.", '<>%1', '');
        if SalesInvoiceLine.FindSet() then
            repeat
                Found := TransactionValueExist(SalesInvoiceLine.RecordId, TaxType);
            until (SalesInvoiceLine.Next() = 0) or Found;

        exit(Found);
    end;

    local procedure CheckSalesCrMemoLine(DocumentNo: Code[20]; TaxType: Code[20]): Boolean
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        Found: Boolean;
    begin
        SalesCrMemoLine.SetRange("Document No.", DocumentNo);
        SalesCrMemoLine.SetFilter("No.", '<>%1', '');
        if SalesCrMemoLine.FindSet() then
            repeat
                Found := TransactionValueExist(SalesCrMemoLine.RecordId, TaxType);
            until (SalesCrMemoLine.Next() = 0) or Found;

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
