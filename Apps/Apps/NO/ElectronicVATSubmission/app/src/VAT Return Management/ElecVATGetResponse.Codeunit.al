// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 10690 "Elec. VAT Get Response"
{
    TableNo = "VAT Report Header";

    var
        NoFeedbackProvidedMsg: Label 'The response for your submission is not ready yet.';
        ReportAcceptedMsg: Label 'The report has been successfully accepted.';
        ReportRejectedMsg: Label 'The report was rejected. To find out why, download the response message and check the attached documents.';

    trigger OnRun()
    var
        ElecVATConnectionMgt: Codeunit "Elec. VAT Connection Mgt.";
    begin
        if not ElecVATConnectionMgt.IsFeedbackProvided(Rec) then begin
            message(NoFeedbackProvidedMsg);
            exit;
        end;
        if ElecVATConnectionMgt.IsVATReportAccepted(Rec) then begin
            Validate(Status, Status::Accepted);
            Message(ReportAcceptedMsg);
        end else begin
            Validate(Status, Status::Rejected);
            Message(ReportRejectedMsg);
        end;
        Modify(true);
    end;
}
