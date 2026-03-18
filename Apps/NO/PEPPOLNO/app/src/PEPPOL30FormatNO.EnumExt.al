// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol;

enumextension 37350 "PEPPOL 3.0 Format NO" extends "PEPPOL 3.0 Format"
{
    value(37350; "PEPPOL 3.0 - Sales NO")
    {
        Caption = 'PEPPOL 3.0 - Norway Sales Format';
        Implementation = "PEPPOL30 Validation" = "PEPPOL30 Sales Validation",
                        "PEPPOL Payment Info Provider" = "PEPPOL30 NO Payment",
                        "PEPPOL Posted Document Iterator" = "PEPPOL30 Sales Iterator";
    }
    value(37351; "PEPPOL 3.0 - Service NO")
    {
        Caption = 'PEPPOL 3.0 - Norway Service Format';
        Implementation = "PEPPOL30 Validation" = "PEPPOL30 Service Validation",
                        "PEPPOL Payment Info Provider" = "PEPPOL30 NO Payment",
                        "PEPPOL Posted Document Iterator" = "PEPPOL30 Services Iterator";
    }
}
