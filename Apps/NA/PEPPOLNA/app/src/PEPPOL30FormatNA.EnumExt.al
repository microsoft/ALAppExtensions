// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol;

enumextension 37350 "PEPPOL 3.0 Format NA" extends "PEPPOL 3.0 Format"
{
    value(37351; "PEPPOL 3.0 - Sales NA")
    {
        Caption = 'PEPPOL 3.0 - Sales NA';
        Implementation = "PEPPOL30 Validation" = "PEPPOL30 Sales Validation",
                        "PEPPOL Posted Document Iterator" = "PEPPOL30 Sales Iterator",
                        "PEPPOL Line Info Provider" = "PEPPOL30 NA",
                        "PEPPOL Tax Info Provider" = "PEPPOL30 NA";
    }
    value(37352; "PEPPOL 3.0 - Service NA")
    {
        Caption = 'PEPPOL 3.0 - Service NA';
        Implementation = "PEPPOL30 Validation" = "PEPPOL30 Service Validation",
                        "PEPPOL Posted Document Iterator" = "PEPPOL30 Services Iterator",
                        "PEPPOL Line Info Provider" = "PEPPOL30 NA",
                        "PEPPOL Tax Info Provider" = "PEPPOL30 NA";
    }
}
