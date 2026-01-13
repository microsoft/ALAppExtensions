// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Sustainability.Setup;

pageextension 13910 "OIOUBL Sustainability Setup" extends "Sustainability Setup"
{

    layout
    {
        addlast(General)
        {
            field("Use Sustainability in E-Doc."; Rec."Use Sustainability in E-Doc.")
            {
                ApplicationArea = All;
            }
        }
    }
}