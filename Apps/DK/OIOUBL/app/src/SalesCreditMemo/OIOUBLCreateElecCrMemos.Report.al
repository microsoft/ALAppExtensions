// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.CRM.Segment;
using Microsoft.Sales.History;

report 13631 "OIOUBL-Create Elec. Cr. Memos"
{
    Caption = 'Create Electronic Credit Memos';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Sell-to Customer No.", "Bill-to Customer No.", "OIOUBL-GLN", "OIOUBL-Electronic Credit Memo Created";

            trigger OnAfterGetRecord();
            var
                OIOUBLExportSalesCrMemo: Codeunit "OIOUBL-Export Sales Cr. Memo";
                OIOUBLManagement: Codeunit "OIOUBL-Management";
            begin
                OIOUBLExportSalesCrMemo.ExportXML("Sales Cr.Memo Header");

                if LogInteraction then
                    OIOUBLManagement.WriteLogSalesCrMemo("Sales Cr.Memo Header");

                COMMIT();

                Counter := Counter + 1;
            end;

            trigger OnPostDataItem();
            begin
                MESSAGE(SuccessMsg, Counter);
            end;

            trigger OnPreDataItem();
            var
                SalesCrMemoHeader: Record "Sales Cr.Memo Header";
            begin
                Counter := 0;

                // Any electronic credit memos?
                SalesCrMemoHeader.COPY("Sales Cr.Memo Header");
                SalesCrMemoHeader.FILTERGROUP(8);
                SalesCrMemoHeader.SETFILTER("OIOUBL-GLN", '<>%1', '');
                if NOT SalesCrMemoHeader.FINDFIRST() then
                    ERROR(NothingToCreateErr);

                // All electronic credit memos?
                SalesCrMemoHeader.SETRANGE("OIOUBL-GLN", '');
                if SalesCrMemoHeader.FINDFIRST() then
                    if NOT CONFIRM(DocumentsWillBeSkippedQst, TRUE) then
                        CurrReport.QUIT();
                SalesCrMemoHeader.SETRANGE("OIOUBL-GLN");

                // Some already sent?
                SalesCrMemoHeader.SETRANGE("OIOUBL-Electronic Credit Memo Created", TRUE);
                if NOT SalesCrMemoHeader.IsEmpty() then
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
        SegManagement: Codeunit SegManagement;
        Counter: Integer;
        DocumentsWillBeSkippedQst: Label 'One or more credit memos that match your filter criteria are not electronic credit memos and will be skipped.\\Do you want to continue?';
        DocumentAlreadyCreatedQst: Label 'One or more credit memos that match your filter criteria have been created before.\\Do you want to continue?';
        SuccessMsg: Label 'Successfully created %1 electronic credit memos.', Comment = '%1 = amount of electronic credit memos created';
        NothingToCreateErr: Label 'There is nothing to create.';
        LogInteraction: Boolean;
        [InDataSet]
        LogInteractionEnable: Boolean;

    procedure InitLogInteraction();
    begin
        LogInteraction := SegManagement.FindInteractionTemplateCode(6) <> '';
    end;
}

