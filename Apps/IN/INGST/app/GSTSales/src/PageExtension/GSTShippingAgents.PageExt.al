// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Shipping;

pageextension 18168 "GST Shipping Agents" extends "Shipping Agents"
{
    layout
    {
        addlast(Control1)
        {
            field("GST Registration No."; Rec."GST Registration No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Shipping Agents Tax Registration number issued by authorized body.';

            }
        }
    }
}
