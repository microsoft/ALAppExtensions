// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Sales.History;

pageextension 13916 "E-Doc Pstd Sales Invoice DE" extends "Posted Sales Invoice"
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
