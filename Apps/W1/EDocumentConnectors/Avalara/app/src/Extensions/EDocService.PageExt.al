// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

using Microsoft.eServices.EDocument;

pageextension 6371 "E-Doc. Service" extends "E-Document Service"
{
    layout
    {
        addafter(General)
        {
            group(Avalara)
            {
                Caption = 'Avalara';
                Visible = Rec."Service Integration" = Rec."Service Integration"::Avalara;

                field("Avalara Mandate"; Rec."Avalara Mandate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the mandate used with Avalara service.';
                }
            }
        }

    }
}