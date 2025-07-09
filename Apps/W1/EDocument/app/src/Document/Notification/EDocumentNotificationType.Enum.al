// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

enum 6126 "E-Document Notification Type"
{
    Access = Internal;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Vendor Matched By Name Not Address")
    {
        Caption = 'Vendor Matched By Name Not Address';
    }
}