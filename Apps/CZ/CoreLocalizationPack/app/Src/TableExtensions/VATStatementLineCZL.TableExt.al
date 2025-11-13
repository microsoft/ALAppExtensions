// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;

tableextension 11739 "VAT Statement Line CZL" extends "VAT Statement Line"
{
    fields
    {
        field(11780; "Attribute Code CZL"; Code[20])
        {
            Caption = 'Attribute Code';
            TableRelation = "VAT Attribute Code CZL".Code where("VAT Statement Template Name" = field("Statement Template Name"));
            DataClassification = CustomerContent;
        }
        field(11781; "G/L Amount Type CZL"; Option)
        {
            Caption = 'G/L Amount Type';
            OptionCaption = 'Net Change,Debit,Credit';
            OptionMembers = "Net Change",Debit,Credit;
            DataClassification = CustomerContent;
        }
        field(11782; "Gen. Bus. Posting Group CZL"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(11783; "Gen. Prod. Posting Group CZL"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(11784; "Show CZL"; Option)
        {
            Caption = 'Show';
            OptionCaption = ' ,Zero If Negative,Zero If Positive';
            OptionMembers = " ","Zero If Negative","Zero If Positive";
            DataClassification = CustomerContent;
        }
        field(31072; "EU 3-Party Intermed. Role CZL"; Option)
        {
            Caption = 'EU 3-Party Intermediate Role';
            OptionCaption = ' ,Yes,No';
            OptionMembers = " ",Yes,No;
            DataClassification = CustomerContent;
        }
#if not CLEANSCHEMA27
        field(31073; "EU-3 Party Trade CZL"; Option)
        {
            Caption = 'EU-3 Party Trade';
            OptionCaption = ' ,Yes,No';
            OptionMembers = " ",Yes,No;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '27.0';
            ObsoleteReason = 'Replaced by "EU 3 Party Trade" field in "EU 3-Party Trade Purchase" app.';
        }
#endif
        field(31110; "VAT Ctrl. Report Section CZL"; Code[20])
        {
            Caption = 'VAT Control Report Section Code';
            TableRelation = "VAT Ctrl. Report Section CZL";
            DataClassification = CustomerContent;
        }
        field(31111; "Ignore Simpl. Doc. Limit CZL"; Boolean)
        {
            Caption = 'Ignore Simplified Tax Document Limit';
            DataClassification = CustomerContent;
        }
    }

    var
        VATStatementCalculationCZL: Codeunit "VAT Statement Calculation CZL";

    procedure CalcTotal(VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL"; var TotalAmount: Decimal)
    begin
        VATStatementCalculationCZL.CalcLineTotal(Rec, VATStmtCalcParametersCZL, TotalAmount);
    end;

    procedure CalcTotal(VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL"; var TotalAmount: Decimal; var TotalBase: Decimal)
    begin
        VATStatementCalculationCZL.CalcLineTotal(Rec, VATStmtCalcParametersCZL, TotalAmount, TotalBase);
    end;

    internal procedure DrillDown(VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL")
    begin
        VATStatementCalculationCZL.DrillDownLineTotal(Rec, VATStmtCalcParametersCZL);
    end;

    internal procedure GetVATEntries(VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL"; var OutTempVATEntry: Record "VAT Entry" temporary)
    begin
        VATStatementCalculationCZL.GetVATEntries(Rec, VATStmtCalcParametersCZL, OutTempVATEntry);
    end;

    internal procedure ShowAmountAsZero(Amount: Decimal): Boolean
    begin
        case "Show CZL" of
            "Show CZL"::"Zero If Negative":
                exit(Amount < 0 ? true : false);
            "Show CZL"::"Zero If Positive":
                exit(Amount > 0 ? true : false);
        end;
    end;

    internal procedure PrepareAmountToShow(var Amount: Decimal)
    begin
        if ShowAmountAsZero(Amount) then
            Amount := 0;
    end;

    internal procedure GetCalculateSign(): Integer
    begin
        exit("Calculate with" = "Calculate with"::"Opposite Sign" ? -1 : 1);
    end;

    internal procedure GetPrintSign(): Integer
    begin
        exit("Print with" = "Print with"::"Opposite Sign" ? -1 : 1);
    end;
}