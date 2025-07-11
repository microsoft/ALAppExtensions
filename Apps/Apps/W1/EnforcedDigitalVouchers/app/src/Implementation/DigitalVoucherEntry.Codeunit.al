// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.Document;
using Microsoft.Service.History;

codeunit 5586 "Digital Voucher Entry"
{
    Access = Internal;

    procedure GetVoucherTypeFromGLEntryOrSourceType(GLEntry: Record "G/L Entry"; GenJournalSourceType: Enum "Gen. Journal Source Type") DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"
    begin
        if GenJournalSourceType <> GenJournalSourceType::" " then
            case GenJournalSourceType of
                GenJournalSourceType::Customer:
                    if GLEntry."System-Created Entry" then
                        exit("Digital Voucher Entry Type"::"Sales Journal")
                    else
                        exit("Digital Voucher Entry Type"::"Sales Document");
                GenJournalSourceType::Vendor:
                    if GLEntry."System-Created Entry" then
                        exit("Digital Voucher Entry Type"::"Purchase Journal")
                    else
                        exit("Digital Voucher Entry Type"::"Purchase Document");
            end;
        DigitalVoucherEntryType := GetVoucherEntryTypeBySourceCode(GLEntry."Source Code");
        if DigitalVoucherEntryType <> DigitalVoucherEntryType::" " then
            exit(DigitalVoucherEntryType);
        exit("Digital Voucher Entry Type"::"General Journal");
    end;

    local procedure GetVoucherEntryTypeBySourceCode(SourceCode: Code[10]): Enum "Digital Voucher Entry Type";
    var
        VoucherEntrySourceCode: Record "Voucher Entry Source Code";
    begin
        if SourceCode = '' then
            exit;
        VoucherEntrySourceCode.SetRange("Source Code", SourceCode);
        if VoucherEntrySourceCode.FindFirst() then
            exit(VoucherEntrySourceCode."Entry Type");
    end;

    procedure GetVoucherEntryTypeFromGenJnlLine(GenJournalLine: Record "Gen. Journal Line") DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"
    begin
        DigitalVoucherEntryType := GetVoucherEntryTypeBySourceCode(GenJournalLine."Source Code");
        case true of
            (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) or (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Customer):
                exit("Digital Voucher Entry Type"::"Sales Journal");
            (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) or (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Vendor):
                exit("Digital Voucher Entry Type"::"Purchase Journal");
            DigitalVoucherEntryType <> DigitalVoucherEntryType::" ":
                exit(DigitalVoucherEntryType);
        end;
        exit("Digital Voucher Entry Type"::"General Journal");
    end;

    procedure GetDocNoAndPostingDateFromRecRef(var DocType: Text; var DocNo: Code[20]; var PostingDate: Date; RecRef: RecordRef): Boolean
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        ServiceHeader: Record "Service Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        ServInvHeader: Record "Service Invoice Header";
        ServCrMemoHeader: Record "Service Cr.Memo Header";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        case RecRef.Number of
            database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    DocType := Format(SalesHeader."Document Type");
                    DocNo := SalesHeader."No.";
                    PostingDate := SalesHeader."Posting Date";
                end;
            Database::"Service Header":
                begin
                    RecRef.settable(ServiceHeader);
                    DocType := Format(ServiceHeader."Document Type");
                    DocNo := ServiceHeader."No.";
                    PostingDate := ServiceHeader."Posting Date";
                end;
            database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvHeader);
                    DocType := Format(SalesHeader."Document Type"::Invoice);
                    DocNo := SalesInvHeader."No.";
                    PostingDate := SalesInvHeader."Posting Date";
                end;
            database::"Sales Cr.Memo Header":
                begin
                    RecRef.SetTable(SalesCrMemoHeader);
                    DocType := Format(SalesHeader."Document Type"::"Credit Memo");
                    DocNo := SalesCrMemoHeader."No.";
                    PostingDate := SalesCrMemoHeader."Posting Date";
                end;
            database::"Purchase Header":
                begin
                    RecRef.SetTable(PurchHeader);
                    DocType := Format(PurchHeader."Document Type");
                    DocNo := PurchHeader."No.";
                    PostingDate := PurchHeader."Posting Date";
                end;
            Database::"Purch. Inv. Header":
                begin
                    RecRef.SetTable(PurchInvHeader);
                    DocType := Format(PurchHeader."Document Type"::Invoice);
                    DocNo := PurchInvHeader."No.";
                    PostingDate := PurchInvHeader."Posting Date";
                end;
            Database::"Purch. Cr. Memo Hdr.":
                begin
                    RecRef.SetTable(PurchCrMemoHeader);
                    DocType := Format(PurchHeader."Document Type"::"Credit Memo");
                    DocNo := PurchCrMemoHeader."No.";
                    PostingDate := PurchCrMemoHeader."Posting Date";
                end;
            Database::"Service Invoice Header":
                begin
                    RecRef.SetTable(ServInvHeader);
                    DocType := Format(ServiceHeader."Document Type"::Invoice);
                    DocNo := ServInvHeader."No.";
                    PostingDate := ServInvHeader."Posting Date";
                end;
            Database::"Service Cr.Memo Header":
                begin
                    RecRef.SetTable(ServCrMemoHeader);
                    DocType := Format(ServiceHeader."Document Type"::"Credit Memo");
                    DocNo := ServCrMemoHeader."No.";
                    PostingDate := ServCrMemoHeader."Posting Date";
                end;
            database::"Gen. Journal Line":
                begin
                    RecRef.SetTable(GenJournalLine);
                    DocType := Format(GenJournalLine."Document Type");
                    DocNo := GenJournalLine."Document No.";
                    PostingDate := GenJournalLine."Posting Date";
                end;
            else begin
                OnGetDocNoAndPostingDateFromRecRefOnCaseElse(DocType, DocNo, PostingDate, RecRef);
                exit(false);
            end;
        end;
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDocNoAndPostingDateFromRecRefOnCaseElse(var DocType: Text; var DocNo: Code[20]; var PostingDate: Date; RecRef: RecordRef)
    begin
    end;
}
