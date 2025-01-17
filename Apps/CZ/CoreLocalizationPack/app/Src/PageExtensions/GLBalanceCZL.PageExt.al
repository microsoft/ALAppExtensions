// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

pageextension 11709 "G/L Balance CZL" extends "G/L Balance"
{
    layout
    {
        addafter("Debit Amount")
        {
            field("Debit Amount (VAT Date) CZL"; Rec."Debit Amount (VAT Date) CZL")
            {
                BlankNumbers = BlankZero;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the debit in the account balance during the time period in the Date Filter field posted by VAT date';
            }
            field("Debit Amt. ACY (VAT Date) CZL"; Rec."Debit Amt. ACY (VAT Date) CZL")
            {
                BlankNumbers = BlankZero;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the debit in the account balance during the time period in the Date Filter field posted by VAT date. This amount is in additional reporting currency.';
                Visible = false;
            }
        }
        addafter("Credit Amount")
        {
            field("Credit Amount (VAT Date) CZL"; Rec."Credit Amount (VAT Date) CZL")
            {
                BlankNumbers = BlankZero;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the credit in the account balance during the time period in the Date Filter field posted by VAT date';
            }
            field("Credit Amt. ACY (VAT Date) CZL"; Rec."Credit Amt. ACY (VAT Date) CZL")
            {
                BlankNumbers = BlankZero;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the credit in the account balance during the time period in the Date Filter field posted by VAT date. This amount is in additional reporting currency.';
                Visible = false;
            }
        }
        addafter("Net Change")
        {
            field("Net Change (VAT Date) CZL"; Rec."Net Change (VAT Date) CZL")
            {
                BlankNumbers = BlankZero;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the net change in the account balance during the time period in the Date Filter field posted by VAT date.';
                Visible = false;
            }
            field("Net Change ACY (VAT Date) CZL"; Rec."Net Change ACY (VAT Date) CZL")
            {
                BlankNumbers = BlankZero;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the net change in the account balance during the time period in the Date Filter field posted by VAT date. This amount is in additional reporting currency.';
                Visible = false;
            }
        }
    }
}
