// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13690 "VATDK-Intrastat Journal" extends "Intrastat Journal"
{
    layout
    {
        modify("Transport Method") { Visible = false; }
    }
}