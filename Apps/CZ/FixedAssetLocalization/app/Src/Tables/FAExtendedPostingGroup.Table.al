// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Maintenance;
using Microsoft.Foundation.AuditCodes;

table 31246 "FA Extended Posting Group CZF"
{
    Caption = 'FA Extended Posting Group';
    LookupPageID = "FA Extended Posting Groups CZF";

    fields
    {
        field(1; "FA Posting Group Code"; Code[20])
        {
            Caption = 'FA Posting Group Code';
            NotBlank = true;
            TableRelation = "FA Posting Group";
            DataClassification = CustomerContent;
        }
        field(2; "FA Posting Type"; Enum "FA Extended Posting Type CZF")
        {
            Caption = 'FA Posting Type';
            DataClassification = CustomerContent;
        }
        field(3; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = if ("FA Posting Type" = const(Disposal)) "Reason Code" else
            if ("FA Posting Type" = const(Maintenance)) Maintenance;
            DataClassification = CustomerContent;
        }
        field(21; "Book Val. Acc. on Disp. (Gain)"; Code[20])
        {
            Caption = 'Book Value Account on Disposal (Gain)';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAccount("Book Val. Acc. on Disp. (Gain)", false);
            end;
        }
        field(22; "Book Val. Acc. on Disp. (Loss)"; Code[20])
        {
            Caption = 'Book Value Account on Disposal (Loss)';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAccount("Book Val. Acc. on Disp. (Loss)", false);
            end;
        }
        field(31; "Maintenance Expense Account"; Code[20])
        {
            Caption = 'Maintenance Expense Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAccount("Maintenance Expense Account", false);
            end;
        }
        field(32; "Maintenance Balance Account"; Code[20])
        {
            Caption = 'Maintenance Balance Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAccount("Maintenance Balance Account", true);
            end;
        }
#pragma warning disable AA0232
        field(41; "Allocated Book Value % (Gain)"; Decimal)
#pragma warning restore AA0232
        {
            CalcFormula = sum("FA Allocation"."Allocation %" where(Code = field("FA Posting Group Code"),
                                                                    "Allocation Type" = const("Book Value (Gain)"),
                                                                    "Reason/Maintenance Code CZF" = field(Code)));
            Caption = 'Allocated Book Value % (Gain)';
            DecimalPlaces = 1 : 1;
            Editable = false;
            FieldClass = FlowField;
        }
        field(42; "Allocated Book Value % (Loss)"; Decimal)
        {
            CalcFormula = sum("FA Allocation"."Allocation %" where(Code = field("FA Posting Group Code"),
                                                                    "Allocation Type" = const("Book Value (Loss)"),
                                                                    "Reason/Maintenance Code CZF" = field(Code)));
            Caption = 'Allocated Book Value % (Loss)';
            DecimalPlaces = 1 : 1;
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Allocated Maintenance %"; Decimal)
        {
            CalcFormula = sum("FA Allocation"."Allocation %" where(Code = field("FA Posting Group Code"),
                                                                    "Allocation Type" = const(Maintenance),
                                                                    "Reason/Maintenance Code CZF" = field(Code)));
            Caption = 'Allocated Maintenance %';
            DecimalPlaces = 1 : 1;
            Editable = false;
            FieldClass = FlowField;
        }
        field(61; "Sales Acc. On Disp. (Gain)"; Code[20])
        {
            Caption = 'Sales Account On Disposal (Gain)';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAccount("Sales Acc. On Disp. (Gain)", false);
            end;
        }
        field(62; "Sales Acc. On Disp. (Loss)"; Code[20])
        {
            Caption = 'Sales Account On Disposal (Loss)';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAccount("Sales Acc. On Disp. (Loss)", false);
            end;
        }
    }

    keys
    {
        key(Key1; "FA Posting Group Code", "FA Posting Type", "Code")
        {
            Clustered = true;
        }
    }

    local procedure CheckGLAccount(AccNo: Code[20]; DirectPosting: Boolean)
    var
        GLAccount: Record "G/L Account";
    begin
        if AccNo <> '' then begin
            GLAccount.Get(AccNo);
            GLAccount.CheckGLAcc();
            if DirectPosting then
                GLAccount.TestField("Direct Posting");
        end;
    end;

    procedure GetBookValueAccountOnDisposalGain(): Code[20]
    begin
        TestField("Book Val. Acc. on Disp. (Gain)");
        exit("Book Val. Acc. on Disp. (Gain)");
    end;

    procedure GetBookValueAccountOnDisposalLoss(): Code[20]
    begin
        TestField("Book Val. Acc. on Disp. (Loss)");
        exit("Book Val. Acc. on Disp. (Loss)");
    end;

    procedure GetMaintenanceExpenseAccount(): Code[20]
    begin
        TestField("Maintenance Expense Account");
        exit("Maintenance Expense Account");
    end;

    procedure GetExtendedMaintenanceBalanceAccount(): Code[20]
    begin
        TestField("Maintenance Balance Account");
        exit("Maintenance Balance Account");
    end;

    procedure GetSalesAccountOnDisposalGain(): Code[20]
    begin
        TestField("Sales Acc. on Disp. (Gain)");
        exit("Sales Acc. on Disp. (Gain)");
    end;

    procedure GetSalesAccountOnDisposalLoss(): Code[20]
    begin
        TestField("Sales Acc. on Disp. (Loss)");
        exit("Sales Acc. on Disp. (Loss)");
    end;
}
