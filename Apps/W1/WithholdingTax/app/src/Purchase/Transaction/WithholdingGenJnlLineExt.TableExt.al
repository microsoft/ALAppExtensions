// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Vendor;

tableextension 6793 "Withholding Gen. Jnl. Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(6784; "Wthldg. Tax Bus. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Bus. Post. Group';
            TableRelation = "Wthldg. Tax Bus. Post. Group";
            DataClassification = CustomerContent;
        }
        field(6785; "Wthldg. Tax Prod. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Prod. Post. Group';
            TableRelation = "Wthldg. Tax Prod. Post. Group";
            DataClassification = CustomerContent;
        }
        field(6786; "Withholding Tax Absorb Base"; Decimal)
        {
            Caption = 'Withholding Tax Absorb Base';
            DataClassification = CustomerContent;
        }
        field(6787; "Withholding Tax Entry No."; Integer)
        {
            Caption = 'Withholding Tax Entry No.';
            DataClassification = CustomerContent;
        }
        field(6788; "Wthldg. Tax Report Line No."; Code[20])
        {
            Caption = 'Withholding Tax Report Line No.';
            DataClassification = CustomerContent;
        }
        field(6789; "Skip Withholding Tax"; Boolean)
        {
            Caption = 'Skip Withholding Tax';
            DataClassification = CustomerContent;
        }
        field(6790; "WHT Certificate Printed"; Boolean)
        {
            Caption = 'Certificate Printed';
            DataClassification = CustomerContent;
        }
        field(6791; "Withholding Tax Payment"; Boolean)
        {
            Caption = 'Withholding Tax Payment';
            DataClassification = CustomerContent;
        }
        field(6792; "Is Withholding Tax"; Boolean)
        {
            Caption = 'Is Withholding Tax';
            DataClassification = CustomerContent;
        }
        field(6793; "WHT Interest Amount"; Decimal)
        {
            Caption = 'Interest Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Currency Code" = '' then
                    "WHT Interest Amount (LCY)" := "WHT Interest Amount"
                else
                    "WHT Interest Amount (LCY)" := Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          "Posting Date", "Currency Code",
                          "WHT Interest Amount", "Currency Factor"));
            end;
        }
        field(6794; "WHT Interest Amount (LCY)"; Decimal)
        {
            Caption = 'Interest Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(6795; "WHT VAT Base (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Base (ACY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6796; "WHT VAT Amount (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Amount (ACY)';
            DataClassification = CustomerContent;
        }
        field(6797; "WHT Amount Including VAT (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Including VAT (ACY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6798; "WHT Amount (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (ACY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6799; "WHT VAT Difference (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Difference (ACY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6800; "WHT Vendor Exchange Rate (ACY)"; Decimal)
        {
            Caption = 'Vendor Exchange Rate (ACY)';
            DecimalPlaces = 0 : 15;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Currency Code");
            end;
        }
        field(6801; "WHT Line Discount Amt. (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Line Discount Amt. (ACY)';
            DataClassification = CustomerContent;
        }
        field(6802; "WHT Inv. Discount Amt. (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Inv. Discount Amt. (ACY)';
            DataClassification = CustomerContent;
        }
        field(6803; "WHT Actual Vendor No."; Code[20])
        {
            Caption = 'Actual Vendor No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }
    }
}