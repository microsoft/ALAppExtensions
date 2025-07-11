// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;
using Microsoft.Sales.Customer;

pageextension 13914 "E-Document Customer Card DE" extends "Customer Card"
{
    layout
    {
        addafter("Use GLN in Electronic Document")
        {
#pragma warning disable AS0125
            field("E-Invoice Routing No."; Rec."E-Invoice Routing No.")
            {
                ShowMandatory = true;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies E-Invoice routing number for e-document. The field is used as buyer reference.';
            }
#pragma warning restore AS0125
        }
    }
}