// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.RoleCenters;

pageextension 6103 "E-Doc. A/P Admin Activities" extends "A/P Admin Activities"
{
    layout
    {
        addafter(OngoingPurchase)
        {
            cuegroup(IncommingEDocuments)
            {
                Caption = 'Incoming E-Documents';

                field("Unprocessed E-Documents"; Rec."Unprocessed E-Documents") { }
                field("Linked Purchase Orders"; Rec."Linked Purchase Orders") { }
                field("E-Documents with Errors"; Rec."E-Documents with Errors") { }
                field("Processed E-Documents TM"; Rec."Processed E-Documents TM") { }
            }
        }
    }
}
