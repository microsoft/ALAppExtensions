// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Account;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;

#pragma warning disable AA0232
tableextension 11718 "G/L Account CZL" extends "G/L Account"
{
    fields
    {
        field(11770; "G/L Account Group CZL"; Enum "G/L Account Group CZL")
        {
            Caption = 'G/L Account Group';
            DataClassification = CustomerContent;
        }
        field(11780; "Net Change (VAT Date) CZL"; Decimal)
        {
            Caption = 'Net Change (VAT Date)';
            Editable = false;
            FieldClass = Flowfield;
            CalcFormula = sum("G/L Entry".Amount where("G/L Account No." = field("No."),
                                                    "G/L Account No." = field(filter(Totaling)),
                                                    "Business Unit Code" = field("Business Unit Filter"),
                                                    "Global Dimension 1 Code" = field("Global Dimension 1 filter"),
                                                    "Global Dimension 2 Code" = field("Global Dimension 2 filter"),
                                                    "VAT Reporting Date" = field("Date Filter")));
            AutoFormatType = 1;
            BlankZero = true;
        }
        field(11781; "Debit Amount (VAT Date) CZL"; Decimal)
        {
            Caption = 'Debit Amount (VAT Date)';
            Editable = false;
            FieldClass = Flowfield;
            CalcFormula = sum("G/L Entry"."Debit Amount" where("G/L Account No." = field("No."),
                                                            "G/L Account No." = field(filter(Totaling)),
                                                            "Business Unit Code" = field("Business Unit Filter"),
                                                            "Global Dimension 1 Code" = field("Global Dimension 1 filter"),
                                                            "Global Dimension 2 Code" = field("Global Dimension 2 filter"),
                                                            "VAT Reporting Date" = field("Date Filter")));
            AutoFormatType = 1;
            BlankZero = true;
        }
        field(11782; "Credit Amount (VAT Date) CZL"; Decimal)
        {
            Caption = 'Credit Amount (VAT Date)';
            Editable = false;
            FieldClass = Flowfield;
            CalcFormula = sum("G/L Entry"."Credit Amount" where("G/L Account No." = field("No."),
                                                            "G/L Account No." = field(filter(Totaling)),
                                                            "Business Unit Code" = field("Business Unit Filter"),
                                                            "Global Dimension 1 Code" = field("Global Dimension 1 filter"),
                                                            "Global Dimension 2 Code" = field("Global Dimension 2 filter"),
                                                            "VAT Reporting Date" = field("Date Filter")));
            AutoFormatType = 1;
            BlankZero = true;
        }
        field(11783; "Net Change ACY (VAT Date) CZL"; Decimal)
        {
            Caption = 'Net Change ACY (VAT Date)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("G/L Entry"."Additional-Currency Amount" where("G/L Account No." = field("No."),
                                                                              "G/L Account No." = field(filter(Totaling)),
                                                                              "Business Unit Code" = field("Business Unit Filter"),
                                                                              "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                              "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                              "VAT Reporting Date" = field("Date Filter")));
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
        }
        field(11784; "Debit Amt. ACY (VAT Date) CZL"; Decimal)
        {
            Caption = 'Debit Amount ACY (VAT Date)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("G/L Entry"."Add.-Currency Debit Amount" where("G/L Account No." = field("No."),
                                                                              "G/L Account No." = field(filter(Totaling)),
                                                                              "Business Unit Code" = field("Business Unit Filter"),
                                                                              "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                              "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                              "VAT Reporting Date" = field("Date Filter")));
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
        }
        field(11785; "Credit Amt. ACY (VAT Date) CZL"; Decimal)
        {
            Caption = 'Credit Amount ACY (VAT Date)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("G/L Entry"."Add.-Currency Debit Amount" where("G/L Account No." = field("No."),
                                                                              "G/L Account No." = field(filter(Totaling)),
                                                                              "Business Unit Code" = field("Business Unit Filter"),
                                                                              "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                              "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                              "VAT Reporting Date" = field("Date Filter")));

            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
        }
    }
}
