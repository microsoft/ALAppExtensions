// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using System.Text;

page 31202 "Save Acc. Schedule Result CZL"
{
    Caption = 'Save Acc. Schedule Result';
    PageType = Card;

    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(AccSchedName; AccSchedName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Acc. Schedule Name';
                    Lookup = true;
                    TableRelation = "Acc. Schedule Name";
                    ToolTip = 'Specifies the name of account schedule.';
                    Editable = false;
                }
                field(ColumnLayoutName; ColumnLayoutName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Column Layout Name';
                    Lookup = true;
                    TableRelation = "Column Layout Name".Name;
                    ToolTip = 'Specifies the name of the column layout that you want to use in the window.';
                    Editable = false;
                }
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Date Filter';
                    ToolTip = 'Specifies the date filter for G/L accounts entries.';

                    trigger OnValidate()
                    var
                        FilterTokens: Codeunit "Filter Tokens";
                    begin
                        FilterTokens.MakeDateFilter(DateFilter);
                        AccScheduleLine.SetFilter("Date Filter", DateFilter);
                        DateFilter := AccScheduleLine.GetFilter("Date Filter");
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of account schedule result.';
                }
                field(UseAmtsInAddCurr; UseAmtsInAddCurr)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Amounts in Add. Reporting Currency';
                    MultiLine = true;
                    ToolTip = 'Specifies when the amounts in additional reporting currency is to be show';
                }
            }
        }
    }

    var
        AccScheduleLine: Record "Acc. Schedule Line";
        AccSchedName: Code[10];
        ColumnLayoutName: Code[10];
        DateFilter: Text;
        Description: Text[50];
        UseAmtsInAddCurr: Boolean;

    procedure SetParameters(NewAccSchedName: Code[10]; NewColumnLayoutName: Code[10]; NewDateFilter: Text; NewUseAmtsInAddCurr: Boolean)
    begin
        AccSchedName := NewAccSchedName;
        ColumnLayoutName := NewColumnLayoutName;
        DateFilter := NewDateFilter;
        UseAmtsInAddCurr := NewUseAmtsInAddCurr;
    end;

    procedure GetParameters(var NewAccSchedName: Code[10]; var NewColumnLayoutName: Code[10]; var NewDateFilter: Text; var NewDescription: Text[50]; var NewUseAmtsInAddCurr: Boolean)
    begin
        NewAccSchedName := AccSchedName;
        NewColumnLayoutName := ColumnLayoutName;
        NewDateFilter := DateFilter;
        NewDescription := Description;
        NewUseAmtsInAddCurr := UseAmtsInAddCurr;
    end;
}
