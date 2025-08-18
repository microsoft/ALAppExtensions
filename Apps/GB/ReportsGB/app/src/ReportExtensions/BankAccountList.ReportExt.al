// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Reports;

reportextension 10582 "Bank Account - List" extends "Bank Account - List"
{
#if CLEAN27
    RDLCLayout = './src/ReportExtensions/BankAccountList.rdlc';
#endif
    dataset
    {
        add("Bank Account")
        {
            column(Bank_Account__Bank_Branch_No___; "Bank Branch No.")
            {
            }
            column(Bank_Account__Bank_Branch_No___Caption; FieldCaption("Bank Branch No."))
            {
            }
        }
    }

#if not CLEAN27
    rendering
    {
        layout(GBlocalizationLayout)
        {
            Type = RDLC;
            Caption = 'Bank Account List GB localization';
            LayoutFile = './src/ReportExtensions/BankAccountList.rdlc';
            ObsoleteState = Pending;
            ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
            ObsoleteTag = '27.0';
        }
    }
#endif
}
