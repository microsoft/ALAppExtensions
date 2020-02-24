// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

report 13635 "OIOUBL-Create Elec Srv Cr Memo"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("Service Cr.Memo Header"; "Service Cr.Memo Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Customer No.", "Bill-to Customer No.", "OIOUBL-GLN", "OIOUBL-Electronic Credit Memo Created";

            trigger OnAfterGetRecord();
            var
                OIOUBLExportServiceCrMemo: Codeunit "OIOUBL-Export Service Cr.Memo";
            begin
                OIOUBLExportServiceCrMemo.ExportXML("Service Cr.Memo Header");

                Commit();
                Counter := Counter + 1;
            end;

            trigger OnPostDataItem();
            begin
                MESSAGE(SuccessMsg, Counter);
            end;

            trigger OnPreDataItem();
            var
                ServCrMemoHeader: Record 5994;
            begin
                Counter := 0;

                // Any electronic service credit memos?
                ServCrMemoHeader.COPY("Service Cr.Memo Header");
                ServCrMemoHeader.FILTERGROUP(8);
                ServCrMemoHeader.SETFILTER("OIOUBL-GLN", '<>%1', '');
                if NOT ServCrMemoHeader.FINDFIRST() then
                    ERROR(NothingToCreateErr);

                // All electronic service credit memos?
                ServCrMemoHeader.SETRANGE("OIOUBL-GLN", '');
                if ServCrMemoHeader.FINDFIRST() then
                    if NOT CONFIRM(DocumentsWillBeSkippedQst, TRUE) then
                        CurrReport.QUIT();
                ServCrMemoHeader.SETRANGE("OIOUBL-GLN");

                // Some already sent?
                ServCrMemoHeader.SETRANGE("OIOUBL-Electronic Credit Memo Created", TRUE);
                if NOT ServCrMemoHeader.IsEmpty() then
                    if NOT CONFIRM(DocumentAlreadyCreatedQst) then
                        CurrReport.QUIT();

                SETFILTER("OIOUBL-GLN", '<>%1', '');
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        Counter: Integer;
        DocumentsWillBeSkippedQst: Label 'One or more credit memos that match your filter criteria are not electronic credit memos and will be skipped.\\Do you want to continue?';
        DocumentAlreadyCreatedQst: Label 'One or more credit memos that match your filter criteria have been created before.\\Do you want to continue?';
        SuccessMsg: Label 'Successfully created %1 electronic credit memo(s).', Comment = '%1 = amount of electronic credit memos created';
        NothingToCreateErr: Label 'There is nothing to create.';
}