// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Assembly.Setup;

pageextension 31252 "Assembly Setup CZA" extends "Assembly Setup"
{
    layout
    {
        addlast(General)
        {
#if not CLEAN26
            field("Default Gen.Bus.Post. Grp. CZA"; Rec."Default Gen.Bus.Post. Grp. CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the default general bussines posting group.';
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';
                ObsoleteReason = 'Replaced by "Default Gen. Bus. Post. Group" field in Assembly Setup Name table.';
                Visible = false;
                Enabled = false;
            }
#endif
        }
    }
}
