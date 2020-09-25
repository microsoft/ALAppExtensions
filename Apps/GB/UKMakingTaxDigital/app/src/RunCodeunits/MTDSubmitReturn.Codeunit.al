// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10532 "MTD Submit Return"
{
    TableNo = "VAT Report Header";
    Permissions = tabledata 747 = d;

    trigger OnRun()
    var
        VATReportArchive: Record "VAT Report Archive";
        VATReturnPeriod: Record "VAT Return Period";
        TempBlob: Codeunit "Temp Blob";
        MTDMgt: Codeunit "MTD Mgt.";
        VATReportMediator: Codeunit "VAT Report Mediator";
        InStream: InStream;
        OutStream: OutStream;
        DummyGUID: Guid;
        RequestJson: Text;
        ResponseJson: Text;
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
        SubmitSuccess: Boolean;
    begin
        MTDMgt.CheckReturnPeriodLink(Rec);

        if not Confirm(ConfirmSubmitQst) then
            Error('');

        // Read Request Json from Archive
        VATReportArchive.GET("VAT Report Config. Code", "No.", DummyGUID);
        VATReportArchive.CALCFIELDS("Submission Message BLOB");
        TempBlob.FromRecord(VATReportArchive, VATReportArchive.FieldNo("Submission Message BLOB"));
        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);
        InStream.Read(RequestJson);

        // Perform POST request for VAT Return submission
        SubmitSuccess := MTDMgt.SubmitVATReturn(RequestJson, ResponseJson);

        // Combine Submission Request\Response into one Submission Archive
        CLEAR(TempBlob);
        TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.Write(CombineSubmissionRequestResponse(RequestJson, ResponseJson));
        VATReportArchive.Delete();
        VATReportArchive.ArchiveSubmissionMessage("VAT Report Config. Code", "No.", TempBlob, DummyGUID);

        if SubmitSuccess then begin
            // Mark as Submitted
            VATReportMediator.Submit(Rec);
            Commit(); // prevent rollback to save Submit status

            // Perform GET request for VAT Return submission. Write Response Json into Response Archive
            if VATReturnPeriod.GET("Return Period No.") then
                if MTDMgt.RetrieveVATReturns(VATReturnPeriod, ResponseJson, TotalCount, NewCount, ModifiedCount, false) then
                    MTDMgt.ArchiveResponseMessage(Rec, ResponseJson);
        end;
    end;

    var
        ConfirmSubmitQst: Label 'When you submit this VAT information you are making a legal declaration that the information is true and complete. A false declaration can result in prosecution. Do you want to continue?';

    local procedure CombineSubmissionRequestResponse(RequestJson: Text; ResponseJson: Text) Result: Text
    var
        JObject: JsonObject;
        RequestJObject: JsonObject;
        ResponseJObject: JsonObject;
    begin
        if RequestJObject.ReadFrom(RequestJson) then;
        if ResponseJObject.ReadFrom(ResponseJson) then;
        JObject.Add('SubmissionRequest', RequestJObject);
        JObject.Add('SubmissionResponse', ResponseJObject);
        JObject.WriteTo(Result);
    end;

}

