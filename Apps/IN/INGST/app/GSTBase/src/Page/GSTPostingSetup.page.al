// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.TaxEngine.Core;
using System.Integration.Excel;

page 18003 "GST Posting Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "GST Posting Setup";
    Caption = 'GST Posting Setup';
    RefreshOnActivate = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("State Code"; Rec."State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state code.';
                }
                field(GSTGroupCod; ComponentName)
                {
                    Caption = 'GST Component Code';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies GST component code.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GSTSetup: Record "GST Setup";
                    begin
                        if not GSTSetup.Get() then
                            exit;
                        ScriptSymbolMgmt.SetContext(GSTSetup."GST Tax Type", EmptyGuid, EmptyGuid);
                        ScriptSymbolMgmt.OpenSymbolsLookup(
                            SymbolType::Component,
                            Text,
                            Rec."Component ID",
                            ComponentName);
                        Rec.Validate("Component ID");
                        FormatLine();
                    end;

                    trigger OnValidate()
                    var
                        GSTSetup: Record "GST Setup";
                    begin
                        if not GSTSetup.Get() then
                            exit;
                        ScriptSymbolMgmt.SetContext(GSTSetup."GST Tax Type", EmptyGuid, EmptyGuid);
                        ScriptSymbolMgmt.SearchSymbol(SymbolType::Component, Rec."Component ID", ComponentName);
                        Rec.Validate("Component ID");
                        FormatLine();
                    end;
                }
                field("Receivable Account"; Rec."Receivable Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise receivable account for each component. ';
                }
                field("Payable Account"; Rec."Payable Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise payable account for each component. ';
                }
                field("Receivable Account (Interim)"; Rec."Receivable Account (Interim)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise receivable account (interim) for each component. ';
                }
                field("Payables Account (Interim)"; Rec."Payables Account (Interim)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise payable account (interim) for each component. ';
                }
                field("Expense Account"; Rec."Expense Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise expense account for each component. ';
                }
                field("Refund Account"; Rec."Refund Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise refund account for each component. ';
                }
                field("Receivable Acc. Interim (Dist)"; Rec."Receivable Acc. Interim (Dist)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise receivable account interim (Dist) for each component. ';
                }
                field("Receivable Acc. (Dist)"; Rec."Receivable Acc. (Dist)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise receivable account (Dist) for each component. ';
                }
                field("GST Credit Mismatch Account"; Rec."GST Credit Mismatch Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise GST credit mismatch account for each component. ';
                }
                field("GST TDS Receivable Account"; Rec."GST TDS Receivable Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise GST TDS receivable account  for each component. ';
                }
                field("GST TDS Payable Account"; Rec."GST TDS Payable Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise GST TDS payable account for each component. ';
                }
                field("GST TCS Receivable Account"; Rec."GST TCS Receivable Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise GST TCS receivable account for each component. ';
                }
                field("GST TCS Payable Account"; Rec."GST TCS Payable Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise GST TCS payable account for each component. ';
                }
                field("IGST Payable A/c (Import)"; Rec."IGST Payable A/c (Import)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state-wise IGST payable account (import) for each component. ';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(EditInExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Edit in Excel';
                Image = Excel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Send the data in the page to an Excel file for analysis or editing';

                trigger OnAction()
                var
                    EditinExcel: Codeunit "Edit in Excel";
                begin
                    EditinExcel.EditPageInExcel(
                        'GST Posting Setup',
                        Page::"GST Posting Setup");
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if ComponentName = '' then
            Error(GSTComponentErr);
    end;


    var
        ScriptSymbolMgmt: Codeunit "Script Symbols Mgmt.";
        SymbolType: Enum "Symbol Type";
        EmptyGuid: Guid;
        ComponentName: Text[30];
        GSTComponentErr: Label 'GST component code must be selected';

    local procedure FormatLine()
    var
        GSTSetup: Record "GST Setup";
    begin
        Clear(ScriptSymbolMgmt);
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");
        ScriptSymbolMgmt.SetContext(GSTSetup."GST Tax Type", EmptyGuid, EmptyGuid);

        if Rec."Component ID" <> 0 then
            ComponentName := ScriptSymbolMgmt.GetSymbolName(SymbolType::Component, Rec."Component ID")
        else
            ComponentName := '';
    end;
}
