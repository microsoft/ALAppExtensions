// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Sales.Document;

pageextension 11042 "E-Doc Sales Order DE" extends "Sales Order"
{
    layout
    {
        addafter("Your Reference")
        {
            field("Buyer Reference"; Rec."Buyer Reference")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
            }
        }
    }
}
