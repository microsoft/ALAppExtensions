// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10531 "MTD Create Return Content"
{
    TableNo = "VAT Report Header";
    Permissions = tabledata 747 = d;

    trigger OnRun()
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Codeunit "Temp Blob";
        MTDMgt: Codeunit "MTD Mgt.";
        OutStream: OutStream;
        DummyGUID: Guid;
        RequestJson: Text;
    begin
        MTDMgt.CheckReturnPeriodLink(Rec);

        if VATReportArchive.GET("VAT Report Config. Code", "No.", DummyGUID) then
            VATReportArchive.Delete();

        RequestJson := CreateReturnContent(Rec);

        TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(RequestJson);
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

    local procedure CreateRequestJson(MTDReturnDetails: Record "MTD Return Details") Result: Text;
    var
        JObject: JsonObject;
    begin
        with MTDReturnDetails do begin
            JObject.Add('periodKey', "Period Key");
            JObject.Add('vatDueSales', "VAT Due Sales");
            JObject.Add('vatDueAcquisitions', "VAT Due Acquisitions");
            JObject.Add('totalVatDue', "Total VAT Due");
            JObject.Add('vatReclaimedCurrPeriod', "VAT Reclaimed Curr Period");
            JObject.Add('netVatDue', Abs("Net VAT Due"));
            JObject.Add('totalValueSalesExVAT', "Total Value Sales Excl. VAT");
            JObject.Add('totalValuePurchasesExVAT', "Total Value Purchases Excl.VAT");
            JObject.Add('totalValueGoodsSuppliedExVAT', "Total Value Goods Suppl. ExVAT");
            JObject.Add('totalAcquisitionsExVAT', "Total Acquisitions Excl. VAT");
            JObject.Add('finalised', Finalised);
        end;
        JObject.WriteTo(Result);
    end;

    local procedure GetVATReportBoxValue(VATReportHeader: Record "VAT Report Header"; BoxNo: Text[30]): Decimal
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        with VATStatementReportLine do begin
            SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
            SetRange("VAT Report No.", VATReportHeader."No.");
            SetRange("Box No.", BoxNo);
            if FindFirst() then
                exit(Amount);
        end;
    end;
}

