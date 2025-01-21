// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Payments;

enum 6103 "Payment Status"
{
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Created)
    {
        Caption = 'Created';
    }
    value(2; Sent)
    {
        Caption = 'Sent';
    }
    value(3; Received)
    {
        Caption = 'Received';
    }
    value(4; "Sending Error")
    {
        Caption = 'Sending Error';
    }
}
