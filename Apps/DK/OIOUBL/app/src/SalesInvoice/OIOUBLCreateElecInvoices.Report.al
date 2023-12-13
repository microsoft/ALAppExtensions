// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.CRM.Segment;
using Microsoft.Sales.History;

report 13630 "OIOUBL-Create Elec. Invoices"
{
    Caption = 'Create Electronic Invoices';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Sell-to Customer No.", "Bill-to Customer No.", "OIOUBL-GLN", "OIOUBL-Electronic Invoice Created";

            trigger OnAfterGetRecord();
            var
                OIOUBLExportSalesInvoice: Codeunit "OIOUBL-Export Sales Invoice";
                OIOUBLManagement: Codeunit "OIOUBL-Management";
            begin
                OIOUBLExportSalesInvoice.ExportXML("Sales Invoice Header");

                if LogInteraction then
                    OIOUBLManagement.WriteLogSalesInvoice("Sales Invoice Header");

                Commit();
                Counter := Counter + 1;
            end;

            trigger OnPostDataItem();
            begin
                MESSAGE(SuccessMsg, Counter);
            end;

            trigger OnPreDataItem();
            var
                SalesInvHeader: Record "Sales Invoice Header";
            begin
                Counter := 0;

                // Any electronic invoices?
                SalesInvHeader.COPY("Sales Invoice Header");
                SalesInvHeader.FILTERGROUP(8);
                SalesInvHeader.SETFILTER("OIOUBL-GLN", '<>%1', '');
                if NOT SalesInvHeader.FINDFIRST() then
                    ERROR(NothingToCreateErr);

                // All electronic invoices?
                SalesInvHeader.SETRANGE("OIOUBL-GLN", '');
                if SalesInvHeader.FINDFIRST() then
                    if NOT CONFIRM(InvoicesWillBeSkippedQst, TRUE) then
                        CurrReport.QUIT();
                SalesInvHeader.SETRANGE("OIOUBL-GLN");

                // Some already sent?
                SalesInvHeader.SETRANGE("OIOUBL-Electronic Invoice Created", TRUE);
                if NOT SalesInvHeader.IsEmpty() then
                    if NOT CONFIRM(InvoicesAlreadyCreatedQst, TRUE) then
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
                group("Main")
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
        [InDataSet]
        LogInteractionEnable: Boolean;
        NothingToCreateErr: Label 'There is nothing to create.';
        InvoicesWillBeSkippedQst: Label 'One or more invoices that match your filter criteria are not electronic invoices and will be skipped.\\Do you want to continue?';
        InvoicesAlreadyCreatedQst: Label 'One or more invoices that match your filter criteria have been created before.\\Do you want to continue?';
        SuccessMsg: Label 'Successfully created %1 electronic invoice(s).', Comment = '%1 = amount of electronic invoices created';

    procedure InitLogInteraction();
    begin
        LogInteraction := SegManagement.FindInteractionTemplateCode(4) <> '';
    end;
}

