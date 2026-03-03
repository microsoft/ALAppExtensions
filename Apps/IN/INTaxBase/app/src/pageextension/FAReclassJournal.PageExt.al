// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Journal;

pageextension 18580 "FA Reclass. Journal" extends "FA Reclass. Journal"
{
    layout
    {
        addafter("Insert Bal. Account")
        {
            field("From Location Code"; Rec."From Location Code")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the location code from which the fixed asset is being transferred.';
            }
            field("To Location Code"; Rec."To Location Code")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the location code to which the fixed asset is being transferred.';
            }
        }
    }
}