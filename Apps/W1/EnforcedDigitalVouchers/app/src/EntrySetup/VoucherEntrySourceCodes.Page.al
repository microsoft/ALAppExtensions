// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

page 5582 "Voucher Entry Source Codes"
{
    PageType = List;
    SourceTable = "Voucher Entry Source Code";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code.';
                }
            }
        }
    }
}
