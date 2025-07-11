// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Threading;

report 10033 "IRS 1099 Send Email"
{
    ApplicationArea = BasicUS;
    ProcessingOnly = true;

    dataset
    {
        dataitem(IRS1099FormDocHeader; "IRS 1099 Form Doc. Header")
        {
            DataItemTableView = sorting(ID);
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(ReportTypeGroup)
                {
                    ShowCaption = false;
                    field(ReportTypeField; ReportType)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Report Type';
                        ToolTip = 'Specifies the 1099 report type to send in the email. Note that only documents with status Submitted will be processed.';

                        trigger OnValidate()
                        begin
                            ResendEmail := false;
                        end;
                    }
                    field(ResendEmailField; ResendEmail)
                    {
                        ApplicationArea = BasicUS;
                        Visible = ResendEmailVisible;
                        Caption = 'Resend Email';
#pragma warning disable AA0219
                        ToolTip = 'The selected report type may have been sent to some vendors. Set the flag if you want to resend email to them.';
#pragma warning restore AA0219
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            SetResendEmailVisibility();
        end;
    }

    var
        ReportType: Enum "IRS 1099 Email Report Type";
        ResendEmail: Boolean;
        ResendEmailVisible: Boolean;
        NoDocumentSelectedErr: Label 'No 1099 form documents are selected for sending email. \\Current filters: %1', Comment = '%1 - filter string';

    trigger OnPostReport()
    var
        IRS1099EmailQueue: Record "IRS 1099 Email Queue";
        IRS1099PrintParams: Record "IRS 1099 Print Params";
        IRS1099SendEmail: Codeunit "IRS 1099 Send Email";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
    begin
        if IRS1099FormDocHeader.Count() = 1 then begin
            IRS1099FormDocHeader.FindFirst();
            if not (IRS1099FormDocHeader.Status in ["IRS 1099 Form Doc. Status"::Released, "IRS 1099 Form Doc. Status"::Submitted]) then
                IRS1099FormDocHeader.FieldError(Status);

            IRS1099PrintParams."Report Type" := ReportType;
            IRSFormsFacade.SaveContentForDocument(IRS1099FormDocHeader, IRS1099PrintParams, false);
            IRS1099SendEmail.SendEmailToVendor(IRS1099FormDocHeader, ReportType);
            IRS1099SendEmail.SetEmailStatusSuccess(IRS1099FormDocHeader, ReportType);
            exit;
        end;

        IRS1099FormDocHeader.SetFilter(Status, '%1|%2', "IRS 1099 Form Doc. Status"::Released, "IRS 1099 Form Doc. Status"::Submitted);
        if not ResendEmail then
            case ReportType of
                "IRS 1099 Email Report Type"::"Copy B":
                    IRS1099FormDocHeader.SetRange("Copy B Sent", false);
                "IRS 1099 Email Report Type"::"Copy 2":
                    IRS1099FormDocHeader.SetRange("Copy 2 Sent", false);
            end;
        if not IRS1099FormDocHeader.FindSet() then
            Error(NoDocumentSelectedErr, IRS1099FormDocHeader.GetFilters());

        IRS1099EmailQueue.DeleteAll();
        repeat
            IRS1099EmailQueue."Entry No." := 0;
            IRS1099EmailQueue."Document ID" := IRS1099FormDocHeader.ID;
            IRS1099EmailQueue."Report Type" := ReportType;
            IRS1099EmailQueue.Insert();
        until IRS1099FormDocHeader.Next() = 0;
        ScheduleEmailJobQueue();
    end;

    procedure ScheduleEmailJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Init();
        JobQueueEntry.Validate("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.Validate("Object ID to Run", Codeunit::"IRS 1099 Process Email Queue");
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
    end;

    local procedure SetResendEmailVisibility()
    begin
        if IRS1099FormDocHeader.Count() = 1 then
            ResendEmailVisible := false
        else
            ResendEmailVisible := true;
    end;
}
