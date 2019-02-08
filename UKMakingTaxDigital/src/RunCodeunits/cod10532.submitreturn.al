// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10532 "MTD Submit Return"
{
    TableNo = "VAT Report Header";

    trigger OnRun()
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Record TempBlob;
        VATReturnPeriod: Record "VAT Return Period";
        MTDMgt: Codeunit "MTD Mgt.";
        VATReportMediator: Codeunit "VAT Report Mediator";
        DummyGUID: Guid;
        RequestJson: Text;
        ResponseJson: Text;
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
        SubmitSuccess: Boolean;
    begin
        if not Confirm(ConfirmSubmitQst) then
            Error('');

        // Read Request Json from Archive
        VATReportArchive.GET("VAT Report Config. Code", "No.", DummyGUID);
        VATReportArchive.CALCFIELDS("Submission Message BLOB");
        TempBlob.Init();
        TempBlob.Blob := VATReportArchive."Submission Message BLOB";
        RequestJson := TempBlob.ReadAsText('', TEXTENCODING::UTF8);

        // Perform POST request for VAT Return submission
        SubmitSuccess := MTDMgt.SubmitVATReturn(RequestJson, ResponseJson);

        // Combine Submission Request\Response into one Submission Archive
        CLEAR(TempBlob.Blob);
        TempBlob.WriteAsText(CombineSubmissionRequestResponse(RequestJson, ResponseJson), TEXTENCODING::UTF8);
        VATReportArchive.Delete();
        VATReportArchive.ArchiveSubmissionMessage("VAT Report Config. Code", "No.", TempBlob, DummyGUID);

        if SubmitSuccess then begin
            // Mark as Submitted
            VATReportMediator.Submit(Rec);
            Commit(); // prevent rollback to save Submit status

            // Perform GET request for VAT Return submission. Write Response Json into Response Archive
            if VATReturnPeriod.GET("Return Period No.") then
                if MTDMgt.RetrieveVATReturns(VATReturnPeriod, ResponseJson, TotalCount, NewCount, ModifiedCount, FALSE) then
                    MTDMgt.ArchiveResponseMessage(Rec, ResponseJson);
        end;
    end;

    var
        ConfirmSubmitQst: Label 'When you submit this VAT information you are making a legal declaration that the information is true and complete. A false declaration can result in prosecution. Do you want to continue?';

    local procedure CombineSubmissionRequestResponse(RequestJson: Text; ResponseJson: Text): Text
    var
        JSONMgt: Codeunit "JSON Management";
    begin
        JSONMgt.AddJson('SubmissionRequest', RequestJson);
        JSONMgt.AddJson('SubmissionResponse', ResponseJson);
        EXIT(JSONMgt.WriteObjectToString())
    end;

}

