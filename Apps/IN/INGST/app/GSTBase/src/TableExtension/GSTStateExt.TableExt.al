// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

tableextension 18013 "GST State Ext." extends State
{
    fields
    {
        field(18000; "State Code (GST Reg. No.)"; code[10])
        {
            Caption = 'State Code (GST Reg. No.)';
            DataClassification = CustomerContent;
            Numeric = true;
        }
    }
}
