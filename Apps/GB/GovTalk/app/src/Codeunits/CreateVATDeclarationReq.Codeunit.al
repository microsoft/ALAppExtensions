// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.IO;
using Microsoft.Finance.VAT.Reporting;

codeunit 10589 "Create VAT Declaration Req."
{
    TableNo = "VAT Report Header";

    trigger OnRun()
    begin
        RootXMLBuffer.Init();
        RootXMLBuffer.Validate(Name, VATDeclarationRequestTxt);
        RootXMLBuffer.Insert();
        if not GovTalkMessage.Get(Rec."VAT Report Config. Code", Rec."No.") then begin
            GovTalkMessageManagement.InitGovTalkMessage(GovTalkMessage, Rec);
            GovTalkMessage.RootXMLBuffer := RootXMLBuffer."Entry No.";
            GovTalkMessage.Modify();
        end;
        PopulateVATDeclarationRequest(Rec);
    end;

    var
        GovTalkMessage: Record "GovTalk Message";
        RootXMLBuffer: Record "XML Buffer";
        GovTalkMessageManagement: Codeunit "GovTalk Message Management";
        BaseType: Option ElevenPointTwoDigitDecimalType,ElevenPointTwoDigitNonNegativeDecimalType,ThirteenDigitIntegerType;
        VATDeclarationRequestTxt: Label 'VATDeclarationRequest', Locked = true;
        VATDueOnOutputsTxt: Label 'VATDueOnOutputs', Locked = true;
        VATDueOnECAcquisitionsTxt: Label 'VATDueOnECAcquisitions', Locked = true;
        TotalVATTxt: Label 'TotalVAT', Locked = true;
        VATReclaimedOnInputsTxt: Label 'VATReclaimedOnInputs', Locked = true;
        NetVATTxt: Label 'NetVAT', Locked = true;
        NetSalesAndOutputsTxt: Label 'NetSalesAndOutputs', Locked = true;
        NetPurchasesAndInputsTxt: Label 'NetPurchasesAndInputs', Locked = true;
        NetECSuppliesTxt: Label 'NetECSupplies', Locked = true;
        NetECAcquisitionsTxt: Label 'NetECAcquisitions', Locked = true;
        AASBalancingPaymentTxt: Label 'AASBalancingPayment', Locked = true;

    local procedure GetRowValue(VATReportHeader: Record "VAT Report Header"; BoxNo: Text): Decimal
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        VATStatementReportLine.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        VATStatementReportLine.SetRange("VAT Report No.", VATReportHeader."No.");
        VATStatementReportLine.SetRange("Box No.", CopyStr(BoxNo, 1, MaxStrLen(VATStatementReportLine."Box No.")));
        if VATStatementReportLine.FindFirst() then
            exit(VATStatementReportLine.Amount);
        exit(0);
    end;

    local procedure PopulateVATDeclarationRequest(VATReportHeader: Record "VAT Report Header")
    begin
        InsertLine(VATDueOnOutputsTxt, GetRowValue(VATReportHeader, '1'), 0);
        InsertLine(VATDueOnECAcquisitionsTxt, GetRowValue(VATReportHeader, '2'), 0);
        InsertLine(TotalVATTxt, GetRowValue(VATReportHeader, '3'), 0);
        InsertLine(VATReclaimedOnInputsTxt, GetRowValue(VATReportHeader, '4'), 0);
        InsertLine(NetVATTxt, GetRowValue(VATReportHeader, '5'), 1);
        InsertLine(NetSalesAndOutputsTxt, GetRowValue(VATReportHeader, '6'), 2);
        InsertLine(NetPurchasesAndInputsTxt, GetRowValue(VATReportHeader, '7'), 2);
        InsertLine(NetECSuppliesTxt, GetRowValue(VATReportHeader, '8'), 2);
        InsertLine(NetECAcquisitionsTxt, GetRowValue(VATReportHeader, '9'), 2);
        InsertLine(AASBalancingPaymentTxt, GetRowValue(VATReportHeader, '10'), 1);
    end;

    local procedure InsertLine(Description: Text[250]; Value: Decimal; TypeBase: Option)
    begin
        RootXMLBuffer.AddElement(Description, GetFormattedValue(Value, TypeBase));
    end;

    local procedure GetFormattedValue(Value: Decimal; FormatType: Option): Text[250]
    begin
        if FormatType = BaseType::ElevenPointTwoDigitDecimalType then
            exit(ElevenPointTwoDigitDecimalFormat(Value));
        if FormatType = BaseType::ElevenPointTwoDigitNonNegativeDecimalType then
            exit(ElevenPointTwoDigitNonNegativeDecimalFormat(Value));
        if FormatType = BaseType::ThirteenDigitIntegerType then
            exit(ThirteenDigitIntegerFormat(Value));
    end;

    local procedure ElevenPointTwoDigitDecimalFormat(Value: Decimal): Text[250]
    begin
        exit(Format(Round(Value, 0.01), 0, '<Precision,2><Standard Format,2>'));
    end;

    local procedure ElevenPointTwoDigitNonNegativeDecimalFormat(Value: Decimal): Text[250]
    begin
        exit(ElevenPointTwoDigitDecimalFormat(Abs(Value)));
    end;

    local procedure ThirteenDigitIntegerFormat(Value: Decimal): Text[250]
    begin
        exit(Format(Round(Value, 1), 0, '<Sign><Integer>'));
    end;
}

