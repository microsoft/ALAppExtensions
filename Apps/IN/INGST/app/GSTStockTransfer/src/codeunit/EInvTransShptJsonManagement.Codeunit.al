// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;

codeunit 18021 "EInvTransshptJsonManagement"
{
    var
        IRNLengthErr: Label 'IRN Hash must be 64 character text.', Locked = true;
        TaxableLbl: Label 'Taxable', Locked = true;
        NonGSTLbl: Label 'Non-GST', Locked = true;
        AccountingPeriodErr: Label 'Tax Accounting Period does not exist for the given Date %1.', Comment = '%1 = Posting Date';

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Header", 'OnAfterValidateEvent', 'IRN Hash', false, false)]
    local procedure OnAfterValidateIRNHashOnTransferShipment(var Rec: Record "Transfer Shipment Header")
    begin
        CheckIRNHashLength(Rec."IRN Hash");
    end;

    procedure IsGSTApplicable(DocumentNo: Code[20]; TableID: Integer): Boolean
    var
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        case TableID of
            Database::"Transfer Shipment Header":
                exit(CheckTransferShipmentLine(DocumentNo, GSTSetup."GST Tax Type"));
        end;
    end;

    local procedure CheckTransferShipmentLine(DocumentNo: Code[20]; TaxType: Code[20]): Boolean
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        Found: Boolean;
    begin
        TransferShipmentLine.LoadFields("Document No.", "Item No.");
        TransferShipmentLine.SetRange("Document No.", DocumentNo);
        TransferShipmentLine.SetFilter("Item No.", '<>%1', '');
        if TransferShipmentLine.FindSet() then
            repeat
                Found := TransactionValueExist(TransferShipmentLine.RecordId, TaxType);
            until (TransferShipmentLine.Next() = 0) or Found;

        exit(Found);
    end;

    local procedure TransactionValueExist(RecID: RecordID; TaxType: Code[20]): Boolean
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.LoadFields("Tax Type", "Tax Record ID");
        TaxTransactionValue.SetRange("Tax Type", TaxType);
        TaxTransactionValue.SetRange("Tax Record ID", RecId);
        exit(not TaxTransactionValue.IsEmpty());
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
        TransferShipmentHeader: Record "Transfer Shipment Header";
        Location: Record Location;
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        IRNInput: Text[64];
        FINYr: Text;
        InvoiceTypeText: Text;
        PostingDate: Date;
    begin
        TransferShipmentHeader.Get(DocNo);
        RecordRef.Open(CallByTable);
        FieldRef := RecordRef.Field(3);
        FieldRef.Value := DocNo;

        if not GSTSetup.Get() then
            exit;

        TaxType.Get(GSTSetup."GST Tax Type");

        if not IsGSTApplicable(DocNo, CallByTable) then
            exit;

        PostingDate := TransferShipmentHeader."Posting Date";

        TaxAccountingPeriod.LoadFields("Tax Type Code", "Starting Date", "Ending Date");
        TaxAccountingPeriod.SetRange("Tax Type Code", TaxType."Accounting Period");
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
        TaxAccountingPeriod.SetFilter("Ending Date", '>=%1', PostingDate);
        if TaxAccountingPeriod.FindFirst() then begin
            FINYr := Format(TaxAccountingPeriod."Starting Date", 0, '<Year4>');
            FINYr += '-' + Format(TaxAccountingPeriod."Ending Date", 0, '<Year>');
        end else
            Error(AccountingPeriodErr, PostingDate);

        if CallByTable = Database::"Transfer Shipment Header" then
            if TransferShipmentHeader."Transfer-from Code" <> TransferShipmentHeader."Transfer-to Code" then
                InvoiceTypeText := TaxableLbl
            else
                InvoiceTypeText := NonGSTLbl;

        Location.Get(TransferShipmentHeader."Transfer-from Code");
        IRNInput := Location."GST Registration No." + FINYr + InvoiceTypeText + DocNo;
        TransferShipmentHeader."IRN Hash" := IRNInput;
        TransferShipmentHeader.Modify();
    end;
}