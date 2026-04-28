// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.eServices.EDocument;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Telemetry;
using System.Utilities;

codeunit 10971 "Export E-Reporting FR"
{
    Access = Internal;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FeatureNameTok: Label 'E-document E-Reporting FR Format', Locked = true;
        StartEventNameTok: Label 'E-document E-Reporting FR batch export started', Locked = true;
        EndEventNameTok: Label 'E-document E-Reporting FR batch export completed', Locked = true;
        XmlNamespaceTrsTok: Label 'transaction', Locked = true;

    /// <summary>
    /// Creates the batch XML for French e-reporting from a set of E-Documents.
    /// </summary>
    /// <param name="EDocument">The E-Document records to include in the batch export.</param>
    /// <param name="TempBlob">The Temp Blob to write the generated XML to.</param>
    procedure CreateBatchXML(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        VATEntry: Record "VAT Entry";
        RootXMLNode: XmlElement;
        XMLDoc: XmlDocument;
        FileOutStream: OutStream;
        TransBaseAmounts: Dictionary of [Text, Decimal];
        TransVATAmounts: Dictionary of [Text, Decimal];
        TransCounts: Dictionary of [Text, Integer];
        SubTaxableAmounts: Dictionary of [Text, Decimal];
        SubVATAmounts: Dictionary of [Text, Decimal];
        TransType: Enum "FR E-Reporting Trans. Type";
        XMLDocText: Text;
        GroupKey: Text;
        SubKey: Text;
        CurrencyCode: Code[10];
        PeriodStartDate: Date;
        PeriodEndDate: Date;
        VATRate: Decimal;
    begin
        FeatureTelemetry.LogUptake('0000TDO', FeatureNameTok, Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000TDM', FeatureNameTok, StartEventNameTok);

        GetSetups();

        EDocument.SetLoadFields("Document No.", "Posting Date", "Document Type");
        GetPeriodFromEDocuments(EDocument, PeriodStartDate, PeriodEndDate);

        // Iterate E-Documents and aggregate VAT Entries
        if EDocument.FindSet() then
            repeat
                FindVATEntriesForEDocument(EDocument, VATEntry);
                if VATEntry.FindSet() then begin
                    repeat
                        TransType := GetTransactionType(VATEntry);
                        if TransType <> TransType::" " then begin
                            CurrencyCode := GetCurrencyCodeFromVATEntry(VATEntry);
                            VATRate := GetVATRate(VATEntry);
                            GroupKey := Format(TransType) + '|' + CurrencyCode;
                            SubKey := GroupKey + '|' + Format(VATRate, 0, 9);

                            AddToDecimalDict(TransBaseAmounts, GroupKey, GetSignedAmount(VATEntry, VATEntry.Base));
                            AddToDecimalDict(TransVATAmounts, GroupKey, GetSignedAmount(VATEntry, VATEntry.Amount));

                            AddToDecimalDict(SubTaxableAmounts, SubKey, GetSignedAmount(VATEntry, VATEntry.Base));
                            AddToDecimalDict(SubVATAmounts, SubKey, GetSignedAmount(VATEntry, VATEntry.Amount));
                        end;
                    until VATEntry.Next() = 0;
                    AddToIntegerDict(TransCounts, GroupKey, 1);
                end;
            until EDocument.Next() = 0;

        // Generate XML
        XmlDocument.ReadFrom(GetXMLHeader(), XMLDoc);
        XMLDoc.GetRoot(RootXMLNode);

        InsertReportPeriod(RootXMLNode, PeriodStartDate, PeriodEndDate);
        InsertTransactions(
            RootXMLNode, PeriodStartDate,
            TransBaseAmounts, TransVATAmounts, TransCounts,
            SubTaxableAmounts, SubVATAmounts);

        TempBlob.CreateOutStream(FileOutStream, TextEncoding::UTF8);
        XMLDoc.WriteTo(XMLDocText);
        FileOutStream.WriteText(XMLDocText);

        FeatureTelemetry.LogUsage('0000TDN', FeatureNameTok, EndEventNameTok);
    end;

    local procedure GetPeriodFromEDocuments(var EDocument: Record "E-Document"; var PeriodStartDate: Date; var PeriodEndDate: Date)
    begin
        EDocument.SetCurrentKey("Posting Date");
        if EDocument.FindFirst() then
            PeriodStartDate := EDocument."Posting Date";
        if EDocument.FindLast() then
            PeriodEndDate := EDocument."Posting Date";
        EDocument.SetCurrentKey("Entry No");
    end;

    local procedure FindVATEntriesForEDocument(EDocument: Record "E-Document"; var VATEntry: Record "VAT Entry")
    begin
        VATEntry.Reset();
        VATEntry.SetLoadFields(Type, "Document Type", "Bill-to/Pay-to No.", "Source Currency Code", Base, Amount, "VAT Bus. Posting Group", "VAT Prod. Posting Group");
        VATEntry.SetRange("Document No.", EDocument."Document No.");
        VATEntry.SetRange("Posting Date", EDocument."Posting Date");

        case EDocument."Document Type" of
            "E-Document Type"::"Sales Invoice",
            "E-Document Type"::"Service Invoice":
                begin
                    VATEntry.SetRange(Type, VATEntry.Type::Sale);
                    VATEntry.SetRange("Document Type", VATEntry."Document Type"::Invoice);
                end;
            "E-Document Type"::"Sales Credit Memo",
            "E-Document Type"::"Service Credit Memo":
                begin
                    VATEntry.SetRange(Type, VATEntry.Type::Sale);
                    VATEntry.SetRange("Document Type", VATEntry."Document Type"::"Credit Memo");
                end;
            "E-Document Type"::"Purchase Invoice":
                begin
                    VATEntry.SetRange(Type, VATEntry.Type::Purchase);
                    VATEntry.SetRange("Document Type", VATEntry."Document Type"::Invoice);
                end;
            "E-Document Type"::"Purchase Credit Memo":
                begin
                    VATEntry.SetRange(Type, VATEntry.Type::Purchase);
                    VATEntry.SetRange("Document Type", VATEntry."Document Type"::"Credit Memo");
                end;
        end;
    end;

    local procedure GetTransactionType(VATEntry: Record "VAT Entry"): Enum "FR E-Reporting Trans. Type"
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        case VATEntry.Type of
            VATEntry.Type::Sale:
                begin
                    Customer.SetLoadFields("FR E-Reporting Trans. Type");
                    if not Customer.Get(VATEntry."Bill-to/Pay-to No.") then
                        exit("FR E-Reporting Trans. Type"::" ");
                    exit(Customer."FR E-Reporting Trans. Type");
                end;
            VATEntry.Type::Purchase:
                begin
                    Vendor.SetLoadFields("FR E-Reporting Trans. Type");
                    if not Vendor.Get(VATEntry."Bill-to/Pay-to No.") then
                        exit("FR E-Reporting Trans. Type"::" ");
                    exit(Vendor."FR E-Reporting Trans. Type");
                end;
        end;
        exit("FR E-Reporting Trans. Type"::" ");
    end;

    local procedure GetCurrencyCodeFromVATEntry(VATEntry: Record "VAT Entry"): Code[10]
    begin
        if VATEntry."Source Currency Code" <> '' then
            exit(VATEntry."Source Currency Code");
        exit(GeneralLedgerSetup."LCY Code");
    end;

    local procedure GetVATRate(VATEntry: Record "VAT Entry"): Decimal
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetLoadFields("VAT %");
        if VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group") then
            exit(VATPostingSetup."VAT %");
        exit(0);
    end;

    local procedure GetXMLHeader(): Text
    begin
        exit('<?xml version="1.0" encoding="UTF-8"?>' +
            '<TransactionsReport xmlns="transaction" />');
    end;

    local procedure InsertReportPeriod(var RootXMLNode: XmlElement; StartDate: Date; EndDate: Date)
    var
        ReportPeriodElement: XmlElement;
    begin
        ReportPeriodElement := XmlElement.Create('ReportPeriod', XmlNamespaceTrsTok);
        ReportPeriodElement.Add(XmlElement.Create('StartDate', XmlNamespaceTrsTok, FormatDate(StartDate)));
        ReportPeriodElement.Add(XmlElement.Create('EndDate', XmlNamespaceTrsTok, FormatDate(EndDate)));
        RootXMLNode.Add(ReportPeriodElement);
    end;

    local procedure InsertTransactions(
        var RootXMLNode: XmlElement;
        PeriodDate: Date;
        TransBaseAmounts: Dictionary of [Text, Decimal];
        TransVATAmounts: Dictionary of [Text, Decimal];
        TransCounts: Dictionary of [Text, Integer];
        SubTaxableAmounts: Dictionary of [Text, Decimal];
        SubVATAmounts: Dictionary of [Text, Decimal])
    var
        TransactionsElement: XmlElement;
        GroupKeys: List of [Text];
        Parts: List of [Text];
        GroupKey: Text;
        TransType: Text;
        CurrencyCode: Text;
    begin
        GroupKeys := TransBaseAmounts.Keys();
        foreach GroupKey in GroupKeys do begin
            SplitKey(GroupKey, Parts);
            TransType := Parts.Get(1);
            CurrencyCode := Parts.Get(2);

            TransactionsElement := XmlElement.Create('Transactions', XmlNamespaceTrsTok);
            TransactionsElement.Add(XmlElement.Create('Date', XmlNamespaceTrsTok, FormatDate(PeriodDate)));
            TransactionsElement.Add(XmlElement.Create('TransactionsCurrency', XmlNamespaceTrsTok, CurrencyCode));
            TransactionsElement.Add(XmlElement.Create('CategoryCode', XmlNamespaceTrsTok, TransType));
            TransactionsElement.Add(XmlElement.Create('TaxExclusiveAmount', XmlNamespaceTrsTok, FormatDecimal(TransBaseAmounts.Get(GroupKey))));
            TransactionsElement.Add(XmlElement.Create('TaxTotal', XmlNamespaceTrsTok, FormatDecimal(TransVATAmounts.Get(GroupKey))));
            TransactionsElement.Add(XmlElement.Create('TransactionsCount', XmlNamespaceTrsTok, Format(TransCounts.Get(GroupKey))));

            InsertTaxSubtotals(TransactionsElement, GroupKey, SubTaxableAmounts, SubVATAmounts);

            RootXMLNode.Add(TransactionsElement);
        end;
    end;

    local procedure InsertTaxSubtotals(
        var TransactionsElement: XmlElement;
        GroupKey: Text;
        SubTaxableAmounts: Dictionary of [Text, Decimal];
        SubVATAmounts: Dictionary of [Text, Decimal])
    var
        TaxSubtotalElement: XmlElement;
        SubKeys: List of [Text];
        Parts: List of [Text];
        SubKey: Text;
        VATRateText: Text;
    begin
        SubKeys := SubTaxableAmounts.Keys();
        foreach SubKey in SubKeys do
            if SubKey.StartsWith(GroupKey + '|') then begin
                SplitKey(SubKey, Parts);
                VATRateText := Parts.Get(3);

                TaxSubtotalElement := XmlElement.Create('TaxSubtotal', XmlNamespaceTrsTok);
                TaxSubtotalElement.Add(XmlElement.Create('TaxPercent', XmlNamespaceTrsTok, VATRateText));
                TaxSubtotalElement.Add(XmlElement.Create('TaxableAmount', XmlNamespaceTrsTok, FormatDecimal(SubTaxableAmounts.Get(SubKey))));
                TaxSubtotalElement.Add(XmlElement.Create('TaxTotal', XmlNamespaceTrsTok, FormatDecimal(SubVATAmounts.Get(SubKey))));

                TransactionsElement.Add(TaxSubtotalElement);
            end;
    end;

    local procedure AddToDecimalDict(var Dict: Dictionary of [Text, Decimal]; DictKey: Text; Value: Decimal)
    begin
        if not Dict.ContainsKey(DictKey) then
            Dict.Add(DictKey, Value)
        else
            Dict.Set(DictKey, Dict.Get(DictKey) + Value);
    end;

    local procedure AddToIntegerDict(var Dict: Dictionary of [Text, Integer]; DictKey: Text; Value: Integer)
    begin
        if not Dict.ContainsKey(DictKey) then
            Dict.Add(DictKey, Value)
        else
            Dict.Set(DictKey, Dict.Get(DictKey) + Value);
    end;

    local procedure SplitKey(CompositeKey: Text; var Parts: List of [Text])
    begin
        Clear(Parts);
        Parts := CompositeKey.Split('|');
    end;

    local procedure GetSetups()
    begin
        GeneralLedgerSetup.Get();
    end;

    local procedure FormatDate(VarDate: Date): Text[20]
    begin
        if VarDate = 0D then
            exit('1753-01-01');
        exit(Format(VarDate, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    local procedure GetSignedAmount(VATEntry: Record "VAT Entry"; Amount: Decimal): Decimal
    begin
        if VATEntry.Type = VATEntry.Type::Sale then
            exit(-Amount);
        exit(Amount);
    end;

    local procedure FormatDecimal(VarDecimal: Decimal): Text[30]
    begin
        exit(Format(Round(VarDecimal, GeneralLedgerSetup."Amount Rounding Precision"), 0, 9));
    end;
}
