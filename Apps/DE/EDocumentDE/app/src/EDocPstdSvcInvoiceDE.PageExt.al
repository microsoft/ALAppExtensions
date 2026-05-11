// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Service.History;

pageextension 13921 "E-Doc Pstd Svc Invoice DE" extends "Posted Service Invoice"
{
    layout
    {
        addafter("Your Reference")
        {
            field("Buyer Reference"; Rec."Buyer Reference")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Importance = Additional;
            }
        }
    }
}
