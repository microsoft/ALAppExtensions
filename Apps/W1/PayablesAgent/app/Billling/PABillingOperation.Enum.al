// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.PayablesAgent;

enum 3304 "PA Billing Operation"
{
    Extensible = false;
    Access = Internal;

    value(1; "E-Document Processing Started")
    {
        Caption = 'E-Document processing started';
    }
    value(2; "Invoice Data Extracted")
    {
        Caption = 'Invoice data extracted';
    }
    value(3; "Purchase Document Draft Created")
    {
        Caption = 'Purchase document draft created';
    }
    value(4; "Vendor Identified")
    {
        Caption = 'Vendor identified';
    }
    value(5; "Purchase Document Draft Lines Processed")
    {
        Caption = 'Purchase document draft lines processed';
    }
    value(6; "Purchase Document Draft Finalized")
    {
        Caption = 'Purchase document draft finalized';
    }
    value(7; "Invoice Document Processed")
    {
        Caption = 'Invoice document processed';
    }
    value(8; "Invoice Lines Processed")
    {
        Caption = 'Invoice document lines processed';
    }
}