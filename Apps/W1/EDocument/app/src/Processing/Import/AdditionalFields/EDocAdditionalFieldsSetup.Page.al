// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

page 6100 "EDoc Additional Fields Setup"
{
    Caption = 'E-Document Additional Fields Setup';
    PageType = Card;
    Extensible = false;

    layout
    {
        area(Content)
        {
            part(EDocPurchLineFields; "E-Doc. Purch. Line Fields")
            {
                ApplicationArea = All;
                Caption = 'Invoice Line Fields to Transfer';
            }
        }
    }

}