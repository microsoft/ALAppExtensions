// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

enum 6123 "E-Document Source Type"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; Customer) { Caption = 'Customer'; }
    value(1; Vendor) { Caption = 'Vendor'; }
}
