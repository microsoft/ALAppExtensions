// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

pageextension 20600 "Accountant Activities BF" extends "Accountant Activities"
{
    layout
    {
        modify("Document Approvals")
        {
            Visible = false;
        }
    }
}