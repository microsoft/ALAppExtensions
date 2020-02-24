// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

report 13632 "OIOUBL-Create Elec. Reminders"
{
    Caption = 'Create Electronic Reminders';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Issued Reminder Header"; "Issued Reminder Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Customer No.", "OIOUBL-GLN", "OIOUBL-Electronic Reminder Created";

            trigger OnAfterGetRecord();
            begin
                CODEUNIT.RUN(CODEUNIT::"OIOUBL-Export Issued Reminder", "Issued Reminder Header");

                if LogInteraction then
                    SegManagement.LogDocument(
                      8, "No.", 0, 0, DATABASE::Customer, "Customer No.", '', '', "Posting Description", '');

                COMMIT();
                Counter := Counter + 1;
            end;

            trigger OnPostDataItem();
            begin
                MESSAGE(SuccessMsg, Counter);
            end;

            trigger OnPreDataItem();
            var
                IssuedReminderHeader: Record 297;
            begin
                Counter := 0;

                // Any electronic reminders?
                IssuedReminderHeader.COPY("Issued Reminder Header");
                IssuedReminderHeader.FILTERGROUP(8);
                IssuedReminderHeader.SETFILTER("OIOUBL-GLN", '<>%1', '');
                if NOT IssuedReminderHeader.FINDFIRST() then
                    ERROR(NothingToCreateErr);

                // All electronic reminders?
                IssuedReminderHeader.SETRANGE("OIOUBL-GLN", '');
                if IssuedReminderHeader.FINDFIRST() then
                    if NOT CONFIRM(DocumentsWillBeSkippedQst, TRUE) then
                        CurrReport.QUIT();
                IssuedReminderHeader.SETRANGE("OIOUBL-GLN");

                // Some already sent?
                IssuedReminderHeader.SETRANGE("OIOUBL-Electronic Reminder Created", TRUE);
                if NOT IssuedReminderHeader.IsEmpty() then
                    if NOT CONFIRM(DocumentAlreadyCreatedQst, TRUE) then
                        CurrReport.QUIT();

                SETFILTER("OIOUBL-GLN", '<>%1', '');
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group("")
                {
                    Caption = 'Options';
                    field(LogInteraction; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        Tooltip = 'Specifies if you want to record the related interactions with the involved contact person in the Interaction Log Entry table.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit();
        begin
            LogInteractionEnable := TRUE;
        end;

        trigger OnOpenPage();
        begin
            InitLogInteraction();
            LogInteractionEnable := LogInteraction;
        end;
    }

    labels
    {
    }

    trigger OnPreReport();
    begin
        if NOT CurrReport.USEREQUESTPAGE() then
            InitLogInteraction();
    end;

    var
        SegManagement: Codeunit 5051;
        Counter: Integer;
        LogInteraction: Boolean;
        DocumentsWillBeSkippedQst: Label 'One or more issued reminders that match your filter criteria are not electronic reminders and will be skipped.\\Do you want to continue?';
        DocumentAlreadyCreatedQst: Label 'One or more electronic reminders that match your filter criteria have been created before.\\Do you want to continue?';
        SuccessMsg: Label 'Successfully created %1 electronic reminders.', Comment = '%1 = amount of electronic reminders';
        NothingToCreateErr: Label 'There is nothing to create.';
        [InDataSet]
        LogInteractionEnable: Boolean;

    procedure InitLogInteraction();
    begin
        LogInteraction := SegManagement.FindInteractTmplCode(8) <> '';
    end;
}

