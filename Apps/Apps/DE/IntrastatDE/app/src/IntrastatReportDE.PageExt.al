// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 11030 "Intrastat Report DE" extends "Intrastat Report"
{
    layout
    {

        addafter(General)
        {
            group(ExportParamenters)
            {
                Caption = 'Export Parameters';
                field("Test Submission"; Rec."Test Submission")
                {
                    ApplicationArea = BasicEU;
                    Caption = 'Test Submission';
                    ToolTip = 'Specifies if the exported XML will be used for test submission.';
                }
            }
        }
    }
}
