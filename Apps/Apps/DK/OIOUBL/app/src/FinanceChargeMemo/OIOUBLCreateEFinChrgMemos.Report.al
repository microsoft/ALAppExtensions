// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.CRM.Segment;
using Microsoft.Sales.Customer;
using Microsoft.Sales.FinanceCharge;

report 13633 "OIOUBL-Create E-Fin Chrg Memos"
{
    Caption = 'Create Elec. Fin. Chrg. Memos';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Issued Fin. Charge Memo Header"; "Issued Fin. Charge Memo Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Customer No.", "OIOUBL-GLN", "OIOUBL-Elec. Fin. Charge Memo Created";

            trigger OnAfterGetRecord();
            begin
                CODEUNIT.RUN(CODEUNIT::"OIOUBL-Exp. Issued Fin. Chrg", "Issued Fin. Charge Memo Header");

                if LogInteraction then
                    SegManagement.LogDocument(
                      19, "No.", 0, 0, DATABASE::Customer, "Customer No.", '', '', "Posting Description", '');

                COMMIT();
                Counter := Counter + 1;
            end;

            trigger OnPostDataItem();
            begin
                MESSAGE(SuccessMsg, Counter);
            end;

            trigger OnPreDataItem();
            var
                IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
            begin
                Counter := 0;

                // Any electronic finance charges?
                IssuedFinChargeMemoHeader.COPY("Issued Fin. Charge Memo Header");
                IssuedFinChargeMemoHeader.FILTERGROUP(8);
                IssuedFinChargeMemoHeader.SETFILTER("OIOUBL-GLN", '<>%1', '');
                if NOT IssuedFinChargeMemoHeader.FINDFIRST() then
                    ERROR(NothingToCreateErr);

                // All electronic finance charges?
                IssuedFinChargeMemoHeader.SETRANGE("OIOUBL-GLN", '');
                if IssuedFinChargeMemoHeader.FINDFIRST() then
                    if NOT CONFIRM(DocumentsWillBeSkippedQst, TRUE) then
                        CurrReport.QUIT();
                IssuedFinChargeMemoHeader.SETRANGE("OIOUBL-GLN");

                // Some already sent?
                IssuedFinChargeMemoHeader.SETRANGE("OIOUBL-Elec. Fin. Charge Memo Created", TRUE);
                if NOT IssuedFinChargeMemoHeader.IsEmpty() then
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
        SegManagement: Codeunit "SegManagement";
        Counter: Integer;
        LogInteraction: Boolean;
        DocumentsWillBeSkippedQst: Label 'One or more issued finance charges that match your filter criteria are not electronic finance charges and will be skipped.\\Do you want to continue?';
        DocumentAlreadyCreatedQst: Label 'One or more electronic finance charges that match your filter criteria have been created before.\\Do you want to continue?';
        SuccessMsg: Label 'Successfully created %1 electronic finance charges.', Comment = '%1 = amount of electronic finance charges created';
        NothingToCreateErr: Label 'There is nothing to create.';
        [InDataSet]
        LogInteractionEnable: Boolean;

    procedure InitLogInteraction();
    begin
        LogInteraction := SegManagement.FindInteractionTemplateCode(19) <> '';
    end;
}

