codeunit 4704 "VAT Group Serialization"
{
    internal procedure CreateVATSubmissionJson(VATReportHeader: Record "VAT Report Header"): JsonObject
    var
        VATReportSetup: Record "VAT Report Setup";
        VATSubmissionJson: JsonObject;
        LinesJson: Text;
    begin
        VATReportSetup.Get();

        VATSubmissionJson := FillVATSubmissionHeaderJson(VATReportHeader);
        CASE VATReportSetup."VAT Group BC Version" OF
            VATReportSetup."VAT Group BC Version"::NAV2017:
                begin
                    FillVATSubmissionLinesJson(VATReportHeader).WriteTo(LinesJson);
                    VATSubmissionJson.Add('vatGroupSubmissionLines', LinesJson);
                end;
            VATReportSetup."VAT Group BC Version"::NAV2018,
            VATReportSetup."VAT Group BC Version"::BC:
                VATSubmissionJson.Add('vatGroupSubmissionLines', FillVATSubmissionLinesJson(VATReportHeader));
        END;

        exit(VATSubmissionJson);
    end;

    internal procedure CreateBatchRequestPayload(VATGroupReturnNoList: List of [Text]): Text
    var
        VATReportSetup: Record "VAT Report Setup";
        VATGroupCommunication: Codeunit "VAT Group Communication";
        JsonPayload: JsonObject;
        RequestsJsonArray: JsonArray;
        JsonObj: JsonObject;
        BatchPayloadTxt: Text;
        MemberId: Text;
        VATGroup: Text;
        Counter: Integer;
    begin
        VATReportSetup.Get();
        MemberId := DelChr(VATReportSetup."Group Member ID", '=', '{|}');

        Counter := 1;
        foreach VATGroup in VATGroupReturnNoList do begin
            Clear(JsonObj);
            JsonObj.Add('id', Format(Counter));
            JsonObj.Add('method', 'GET');
            JsonObj.Add('url', VATGroupCommunication.PrepareURI(StrSubstNo(VATGroupCommunication.GetVATGroupSubmissionStatusEndpoint(), VATGroup, MemberId)));
            RequestsJsonArray.Add(JsonObj);
            Counter += 1;
        end;

        JsonPayload.Add('requests', RequestsJsonArray);
        JsonPayload.WriteTo(BatchPayloadTxt);

        exit(BatchPayloadTxt);
    end;

    local procedure FillVATSubmissionHeaderJson(VATReportHeader: Record "VAT Report Header"): JsonObject
    var
        VATReportSetup: Record "VAT Report Setup";
        VATSubmissionHeaderJson: JsonObject;
    begin
        VATReportSetup.Get();
        VATSubmissionHeaderJson.Add('no', VATReportHeader."No.");
        VATSubmissionHeaderJson.Add('groupMemberId', VATReportSetup."Group Member ID");
        VATSubmissionHeaderJson.Add('company', CompanyName());
        VATSubmissionHeaderJson.Add('startDate', VATReportHeader."Start Date");
        VATSubmissionHeaderJson.Add('endDate', VATReportHeader."End Date");

        exit(VATSubmissionHeaderJson);
    end;

    local procedure FillVATSubmissionLinesJson(VATReportHeader: Record "VAT Report Header"): JsonArray
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATSubmissionLinesJson: JsonArray;
    begin
        VATStatementReportLine.SetRange("VAT Report No.", VATReportHeader."No.");
        VATStatementReportLine.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        if VATStatementReportLine.FindSet() then
            repeat
                VATSubmissionLinesJson.Add(FillVATSubmissionLineJson(VATStatementReportLine));
            until VATStatementReportLine.Next() = 0;

        exit(VATSubmissionLinesJson);
    end;

    local procedure FillVATSubmissionLineJson(VATStatementReportLine: Record "VAT Statement Report Line"): JsonObject
    var
        VATSubmissionLineJson: JsonObject;
    begin
        VATSubmissionLineJson.Add('vatGroupSubmissionNo', VATStatementReportLine."VAT Report No.");
        VATSubmissionLineJson.Add('lineNo', VATStatementReportLine."Line No.");
        VATSubmissionLineJson.Add('rowNo', VATStatementReportLine."Row No.");
        VATSubmissionLineJson.Add('description', VATStatementReportLine.Description);
        VATSubmissionLineJson.Add('boxNo', VATStatementReportLine."Box No.");
        VATSubmissionLineJson.Add('amount', VATStatementReportLine.Amount);

        exit(VATSubmissionLineJson);
    end;
}