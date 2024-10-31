// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.Statement;
using System.IO;

pageextension 20110 "AMC Bank Stmt Line Det. Ext" extends "Bank Statement Line Details"
{

    layout
    {
        modify(Name)
        {
            Visible = (not IsAMCFundamentalsEnabled);
        }

        addbefore(Value)
        {
            field(NameAMC; NameFldAMC)
            {
                Visible = IsAMCFundamentalsEnabled;
                Enabled = false;
                Caption = 'Name xPath';
                ToolTip = 'Specifies the name of a column in the imported bank file.';
                ApplicationArea = Basic, Suite;
            }
        }
    }

    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        IsAMCFundamentalsEnabled: Boolean;
        NameFldAMC: Text;

    trigger OnOpenPage()
    begin
        IsAMCFundamentalsEnabled := AMCBankingMgt.IsAMCFundamentalsEnabled();
        SetCurrentKey("Data Exch. No.", "Line No.", "Column No.", "Node ID");
    end;

    trigger OnAfterGetRecord()
    begin
        NameFldAMC := GetFieldNameAMC();
    end;

    local procedure GetFieldNameAMC(): Text
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExch: Record "Data Exch.";
    begin
        DataExch.Get("Data Exch. No.");
        if DataExchColumnDef.Get(DataExch."Data Exch. Def Code", DataExch."Data Exch. Line Def Code", "Column No.") then
            exit(DataExchColumnDef.Name);

        if rec."Node ID" <> '' then
            exit(rec."Node ID");

        exit('');
    end;
}
