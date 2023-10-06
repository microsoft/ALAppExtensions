// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Contract;

pageextension 18453 "GST Service Contract" extends "Service Contract"
{
    layout
    {
        addafter("No. of Posted Credit Memos")
        {
            field("GST Customer Type"; Rec."GST Customer Type")
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies the type of the customer. For example, Registered/Unregistered/Export/Exempted/SEZ Unit/SEZ Development etc.';
            }
            field("Invoice Type"; Rec."Invoice Type")
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies the invoice type on the service document. For example, Bill of supply, Export, Supplementary, Debit Note, Non-GST and Taxable.';
            }
        }
    }
}
