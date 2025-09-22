// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Setup;

enum 6232 "Sustainability Document Type"
{
    Caption = 'Document Type';
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "Sales Quote")
    {
        Caption = 'Sales Quote';
    }
    value(1; "Posted Sales Invoice")
    {
        Caption = 'Posted Sales Invoice';
    }
}