// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 20102 "AMC Bank Pmt. Types"
{
    Caption = 'AMC Banking Payment Types';
    PageType = List;
    SourceTable = "AMC Bank Pmt. Type";
    UsageCategory = None;
    ContextSensitiveHelpPage = '401';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the payment type. You set up payment types for a payment method so that the AMC Banking 365 Fundamentals extension can identify the payment type when exporting payments. The payment types are displayed in the AMC Banking Pmt. Types window.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the payment type. You set up payment types for a payment method so that the AMC Banking 365 Fundamentals extension can identify the payment type when exporting payments. The payment types are displayed in the AMC Banking Pmt. Types window.';
                }
            }
        }
    }

    actions
    {
    }
}

