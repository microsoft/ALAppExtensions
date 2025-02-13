// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

enum 13914 "E-Document Buyer Reference"
{
    Extensible = true;

    value(1; "Your Reference")
    {
        Caption = 'Your Reference';
    }
    value(2; "Customer Reference")
    {
        Caption = 'Customer Reference';
    }
}
