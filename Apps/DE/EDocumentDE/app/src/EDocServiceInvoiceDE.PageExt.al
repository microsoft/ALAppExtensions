// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Service.Document;

pageextension 13918 "E-Doc Service Invoice DE" extends "Service Invoice"
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
