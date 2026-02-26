// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol.BE;

using Microsoft.Peppol;

enumextension 37310 "PEPPOL 3.0 Format BE" extends "PEPPOL 3.0 Format"
{
    value(37310; "PEPPOL 3.0 - BE Sales")
    {
        Caption = 'PEPPOL 3.0 - Belgium Sales Format';
        Implementation = "PEPPOL30 Validation" = "PEPPOL30 BE Sales Validation",
                        "PEPPOL Posted Document Iterator" = "PEPPOL30 Sales Iterator";
    }
    value(37311; "PEPPOL 3.0 - BE Service")
    {
        Caption = 'PEPPOL 3.0 - Belgium Service Format';
        Implementation = "PEPPOL30 Validation" = "PEPPOL30 BE Service Validation",
                        "PEPPOL Posted Document Iterator" = "PEPPOL30 Services Iterator";
    }
}
