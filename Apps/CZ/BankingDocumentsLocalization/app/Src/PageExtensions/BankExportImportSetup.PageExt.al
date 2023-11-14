// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.Setup;

pageextension 31286 "Bank Export/Import Setup CZB" extends "Bank Export/Import Setup"
{
    layout
    {
        addafter("Processing XMLport Name")
        {
            field("Processing Report ID CZB"; Rec."Processing Report ID CZB")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the report that will import the bank statement data.';
            }
            field("Processing Report Name CZB"; Rec."Processing Report Name CZB")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the name of the report that will import the bank statement data.';
            }
            field("Default File Type CZB"; Rec."Default File Type CZB")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies default type of file.';
            }
        }
    }
}
