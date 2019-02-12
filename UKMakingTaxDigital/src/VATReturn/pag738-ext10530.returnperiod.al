// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 10530 "MTD Return Period Card" extends "VAT Return Period Card"
{
    layout
    {
        addlast(Content)
        {
            part(pageSubmittedVATReturns; "MTD Return Details")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Start Date" = FIELD ("Start Date"),
                              "End Date" = FIELD ("End Date");
            }
        }
    }
}

