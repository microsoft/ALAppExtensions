// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.NoSeries;

report 31250 "Initialize FA History CZF"
{
    Caption = 'Initialize FA History';
    ProcessingOnly = true;
    UsageCategory = Administration;
    ApplicationArea = FixedAssets;

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Classification Code CZF";

            trigger OnPreDataItem()
            begin
                FAHistoryEntryCZF.SetCurrentKey("FA No.");
            end;

            trigger OnAfterGetRecord()
            begin
                if ("FA Location Code" = '') and ("Responsible Employee" = '') then
                    CurrReport.Skip();
                FAHistoryEntryCZF.SetRange("FA No.", "No.");
                if not FAHistoryEntryCZF.IsEmpty() then
                    CurrReport.Skip();

                FAHistoryManagementCZF.InitializeFAHistory("Fixed Asset", InitializeDate, DocumentNo);
                InitializeCounter += 1;
            end;

            trigger OnPostDataItem()
            begin
                Message(FAHistoryInitializedMsg, InitializeCounter);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(InicializeDateCZF; InitializeDate)
                    {
                        Caption = 'Initialize Date';
                        ApplicationArea = FixedAssets;
                        ToolTip = 'Specifies the posting date to create fixed asset history entries.';
                    }
                    field(DocumentNoCZF; DocumentNo)
                    {
                        Caption = 'Document No.';
                        ApplicationArea = FixedAssets;
                        ToolTip = 'Specifies the document no. to create fixed asset history entries.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            InitializeDate := WorkDate();
            DocumentNo := NoSeriesManagement.GetNextNo(FASetup."Fixed Asset History Nos. CZF", WorkDate(), true);
        end;
    }

    var
        FASetup: Record "FA Setup";
        FAHistoryEntryCZF: Record "FA History Entry CZF";
        FAHistoryManagementCZF: Codeunit "FA History Management CZF";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        InitializeDate: Date;
        DocumentNo: Code[20];
        InitializeCounter: Integer;
        FAHistoryInitializedMsg: Label 'Initial FA History Entries were created for %1 Fixed Assets.', Comment = '%1 = Initialized FA Count';
        InitializeValuesRequiredErr: Label 'Initialize Date and Document No. are required.';

    trigger OnInitReport()
    begin
        FASetup.Get();
        FASetup.TestField("Fixed Asset History Nos. CZF");
    end;

    trigger OnPreReport()
    begin
        if (InitializeDate = 0D) or (DocumentNo = '') then
            Error(InitializeValuesRequiredErr);
    end;
}
