// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.Currency;

tableextension 31047 "G/L Account Net Change CZL" extends "G/L Account Net Change"
{
    fields
    {
        field(31001; "Account Type CZL"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
            DataClassification = SystemMetadata;
        }
        field(31002; "Account No. CZL"; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
        }

        field(31005; "Net Change in Jnl. Curr. CZL"; Decimal)
        {
            AutoFormatExpression = "Currency Code CZL";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Net Change in Jnl. (in Currency)';
            DataClassification = SystemMetadata;
        }
        field(31006; "Balance after Posting Curr.CZL"; Decimal)
        {
            AutoFormatExpression = "Currency Code CZL";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Balance after Posting (in Currency)';
            DataClassification = SystemMetadata;
        }
        field(31007; "Currency Code CZL"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(AccountTypeNoCZL; "Account Type CZL", "Account No. CZL")
        {
        }
    }
}
