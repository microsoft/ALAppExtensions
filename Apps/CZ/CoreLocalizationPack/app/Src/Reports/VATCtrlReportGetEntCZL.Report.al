// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

report 31102 "VAT Ctrl. Report Get Ent. CZL"
{
    Caption = 'VAT Control Report Get Entries';
    ProcessingOnly = true;

    dataset
    {
        dataitem("VAT Ctrl. Report Header CZL"; "VAT Ctrl. Report Header CZL")
        {
            DataItemTableView = sorting("No.");

            trigger OnAfterGetRecord()
            begin
                TestField("No.");
                TestField("Start Date");
                TestField("End Date");
                TestField("VAT Statement Template Name");
                TestField("VAT Statement Name");

                if (StartDate < "Start Date") or (EndDate > "End Date") then
                    Error(DateMismashErr, "Start Date", "End Date");

                VATCtrlReportMgtCZL.GetVATCtrlReportLines(
                  "VAT Ctrl. Report Header CZL", StartDate, EndDate, VATStatementTemplate, VATStatementName, ProcessEntryType, true, UseMergeVATEntries);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate; StartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        Editable = false;
                        ToolTip = 'Specifies the starting date.';
                    }
                    field(EndingDate; EndDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending Date';
                        Editable = false;
                        ToolTip = 'Specifies the last date in the period.';
                    }
                    field(VATStatementTemplateCZL; VATStatementTemplate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Statement Template Name';
                        Editable = false;
                        TableRelation = "VAT Statement Template";
                        ToolTip = 'Specifies VAT statement template name';

                        trigger OnValidate()
                        begin
                            Clear(VATStatementName);
                        end;
                    }
                    field(VATStatementNameCZL; VATStatementName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Statement Name';
                        Editable = false;
                        ToolTip = 'Specifies VAT statement name';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            VATStmtManagement: Codeunit VATStmtManagement;
                            EntrdStmtName: Text[10];
                        begin
                            EntrdStmtName := CopyStr(Text, 1, 10);
                            if VATStmtManagement.LookupName(VATStatementTemplate, VATStatementName, EntrdStmtName) then begin
                                Text := EntrdStmtName;
                                exit(true);
                            end;
                        end;
                    }
                    field(ProcessEntryTypeCZL; ProcessEntryType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Control Report Lines';
                        OptionCaption = 'Add,Rewrite';
                        ToolTip = 'Specifies if VAT Control Report lines will be added or rewritten';
                    }
                    field(UseMergeVATEntriesCZL; UseMergeVATEntries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Use Merge VAT Entries';
                        ToolTip = 'Specifies the option to optimize performance. Apply in the case of large number of VAT Entries.';
                    }
                }
            }
        }
    }

    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportMgtCZL: Codeunit "VAT Ctrl. Report Mgt. CZL";
        StartDate: Date;
        EndDate: Date;
        VATStatementTemplate: Code[10];
        VATStatementName: Code[10];
        ProcessEntryType: Option Add,Rewrite;
        DateMismashErr: Label 'Starting od Ending Date is not in allowed values range (%1..%2).', Comment = '%1 = "Start Date";%2 = "End Date"';
        UseMergeVATEntries: Boolean;

    procedure SetVATCtrlReportHeader(NewVATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL")
    begin
        VATCtrlReportHeaderCZL := NewVATCtrlReportHeaderCZL;
        InitializeRequest();
    end;

    local procedure InitializeRequest()
    begin
        StartDate := VATCtrlReportHeaderCZL."Start Date";
        EndDate := VATCtrlReportHeaderCZL."End Date";
        VATStatementTemplate := VATCtrlReportHeaderCZL."VAT Statement Template Name";
        VATStatementName := VATCtrlReportHeaderCZL."VAT Statement Name";

        ProcessEntryType := ProcessEntryType::Add;
    end;
}
