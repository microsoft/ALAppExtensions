// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10531 "MTD Create Return Content"
{
    TableNo = "VAT Report Header";

    trigger OnRun()
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Record TempBlob;
        DummyGUID: Guid;
        RequestJson: Text;
    begin
        IF VATReportArchive.GET("VAT Report Config. Code", "No.", DummyGUID) THEN
            VATReportArchive.Delete();

        RequestJson := CreateReturnContent(Rec);

        TempBlob.Init();
        TempBlob.WriteAsText(RequestJson, TEXTENCODING::UTF8);
        VATReportArchive.ArchiveSubmissionMessage("VAT Report Config. Code", "No.", TempBlob, DummyGUID);
    end;

    local procedure CreateReturnContent(VATReportHeader: Record "VAT Report Header"): Text;
    var
        TempMTDReturnDetails: Record "MTD Return Details" temporary;
        VATReturnPeriod: Record "VAT Return Period";
    begin
        TempMTDReturnDetails."VAT Due Sales" := GetVATReportBoxValue(VATReportHeader, '1');
        TempMTDReturnDetails."VAT Due Acquisitions" := GetVATReportBoxValue(VATReportHeader, '2');
        TempMTDReturnDetails."Total VAT Due" := GetVATReportBoxValue(VATReportHeader, '3');
        TempMTDReturnDetails."VAT Reclaimed Curr Period" := GetVATReportBoxValue(VATReportHeader, '4');
        TempMTDReturnDetails."Net VAT Due" := GetVATReportBoxValue(VATReportHeader, '5');
        TempMTDReturnDetails."Total Value Sales Excl. VAT" := ROUND(GetVATReportBoxValue(VATReportHeader, '6'), 1);
        TempMTDReturnDetails."Total Value Purchases Excl.VAT" := ROUND(GetVATReportBoxValue(VATReportHeader, '7'), 1);
        TempMTDReturnDetails."Total Value Goods Suppl. ExVAT" := ROUND(GetVATReportBoxValue(VATReportHeader, '8'), 1);
        TempMTDReturnDetails."Total Acquisitions Excl. VAT" := ROUND(GetVATReportBoxValue(VATReportHeader, '9'), 1);
        if VATReturnPeriod.Get(VATReportHeader."Return Period No.") then
            TempMTDReturnDetails."Period Key" := VATReturnPeriod."Period Key";
        TempMTDReturnDetails.Finalised := true;
        exit(CreateRequestJson(TempMTDReturnDetails));
    end;

    local procedure CreateRequestJson(MTDReturnDetails: Record "MTD Return Details"): Text;
    var
        JSONMgt: Codeunit "JSON Management";
    begin
        WITH MTDReturnDetails DO BEGIN
            JSONMgt.SetValue('periodKey', "Period Key");
            JSONMgt.SetValue('vatDueSales', "VAT Due Sales");
            JSONMgt.SetValue('vatDueAcquisitions', "VAT Due Acquisitions");
            JSONMgt.SetValue('totalVatDue', "Total VAT Due");
            JSONMgt.SetValue('vatReclaimedCurrPeriod', "VAT Reclaimed Curr Period");
            JSONMgt.SetValue('netVatDue', "Net VAT Due");
            JSONMgt.SetValue('totalValueSalesExVAT', "Total Value Sales Excl. VAT");
            JSONMgt.SetValue('totalValuePurchasesExVAT', "Total Value Purchases Excl.VAT");
            JSONMgt.SetValue('totalValueGoodsSuppliedExVAT', "Total Value Goods Suppl. ExVAT");
            JSONMgt.SetValue('totalAcquisitionsExVAT', "Total Acquisitions Excl. VAT");
            JSONMgt.SetValue('finalised', Finalised);
        END;
        exit(JSONMgt.WriteObjectToString());
    end;

    local procedure GetVATReportBoxValue(VATReportHeader: Record "VAT Report Header"; BoxNo: Text[30]): Decimal
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        WITH VATStatementReportLine DO BEGIN
            SETRANGE("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
            SETRANGE("VAT Report No.", VATReportHeader."No.");
            SETRANGE("Box No.", BoxNo);
            IF FindFirst() THEN
                EXIT(Amount);
        END;
    end;
}

