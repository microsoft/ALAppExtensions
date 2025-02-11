// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;
using Microsoft.eServices.EDocument;

pageextension 13915 "XRechnung-Edocument Service" extends "E-Document Service"
{
    layout
    {
        addafter(ImportParamenters)
        {
            group(Export)
            {
                field("Buyer Reference Mandatory"; Rec."Buyer Reference Mandatory")
                {
                    ApplicationArea = All;
                }
                field("Buyer Reference"; Rec."Buyer Reference")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}