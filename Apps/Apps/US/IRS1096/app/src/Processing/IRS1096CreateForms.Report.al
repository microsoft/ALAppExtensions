// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

report 10016 "IRS 1096 Create Forms"
{
    Caption = 'IRS 1096 Create Forms';
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate; StartDate)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the starting date for the forms creation. Only vendor ledger entries with posting date starting from this date will be considered.';
                    }
                    field(EndingDate; EndDate)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the ending date for the forms creation. Only vendor ledger entries with posting date ending on this date will be considered.';
                    }
                    field(ReplaceControl; Replace)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Replace';
                        ToolTip = 'Specifies whether the newly created forms will replace the existing ones. If this option is not selected then only new forms will be created and the existing ones remain the same.';
                    }
                }
            }
        }
    }

    var
        ReplaceFormsQst: Label 'Do you want to replace the existing 1096 forms with the new ones?';
        DateAreNotSpecifiedErr: Label 'Starting and ending dates must be specified.';

    protected var
        StartDate: Date;
        EndDate: Date;
        Replace: Boolean;


    trigger OnPreReport()
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if (StartDate = 0D) or (EndDate = 0D) then
            Error(DateAreNotSpecifiedErr);
        if not Replace then
            exit;

        if not ConfirmManagement.GetResponse(ReplaceFormsQst, false) then
            CurrReport.Break();
    end;

    trigger OnPostReport()
    var
        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
    begin
        IRS1096FormMgt.CreateForms(StartDate, EndDate, Replace);
    end;

    procedure InitializeRequest(NewStartDate: Date; NewEndDate: Date; NewReplace: Boolean)
    begin
        StartDate := NewStartDate;
        EndDate := NewEndDate;
        Replace := NewReplace;
    end;
}
