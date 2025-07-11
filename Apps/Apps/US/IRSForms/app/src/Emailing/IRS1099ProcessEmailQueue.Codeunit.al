// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Utilities;
using System.Telemetry;
using System.Threading;

codeunit 10052 "IRS 1099 Process Email Queue"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    TableNo = "Job Queue Entry";

    var
        EmailFormsTxt: Label 'Email IRS 1099 pdf forms';
        JobCompletedTxt: Label 'Job of sending 1099 pdf forms by email has been completed. Successfully sent %1 forms. Failed to send %2 forms.', Comment = '%1 - forms sent count, %2 - forms not sent count';

    trigger OnRun()
    var
        IRS1099EmailQueue: Record "IRS 1099 Email Queue";
        ActivityLog: Record "Activity Log";
        IRS1099SendEmail: Codeunit "IRS 1099 Send Email";
        IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
        Telemetry: Codeunit Telemetry;
        Success: Boolean;
        SuccessCount: Integer;
        FailCount: Integer;
    begin
        IRS1099EmailQueue.LockTable();
        if IRS1099EmailQueue.FindSet() then
            repeat
                Commit();
                Success := IRS1099SendEmail.Run(IRS1099EmailQueue);
                if Success then begin
                    SuccessCount += 1;
                    IRS1099SendEmail.SetEmailStatusSuccess(IRS1099EmailQueue)
                end else begin
                    FailCount += 1;
                    IRS1099SendEmail.SetEmailStatusFail(IRS1099EmailQueue, GetLastErrorText());
                end;
                Sleep(200);
            until IRS1099EmailQueue.Next() = 0;

        IRS1099EmailQueue.DeleteAll();

        Telemetry.LogMessage('0000MHV', StrSubstNo(JobCompletedTxt, SuccessCount, FailCount), Verbosity::Normal, DataClassification::SystemMetadata);
        ActivityLog.LogActivity(Rec.RecordId(), ActivityLog.Status::Success, IRS1099FormDocument.GetActivityLogContext(), EmailFormsTxt, StrSubstNo(JobCompletedTxt, SuccessCount, FailCount));
    end;

}
