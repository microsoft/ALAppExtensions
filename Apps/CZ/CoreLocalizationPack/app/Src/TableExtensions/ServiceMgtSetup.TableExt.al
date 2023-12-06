// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Setup;

using Microsoft.Finance.VAT.Setup;

tableextension 11716 "Service Mgt. Setup CZL" extends "Service Mgt. Setup"
{
    fields
    {
#if not CLEAN22
#pragma warning disable AL0432
#endif
        field(11780; "Default VAT Date CZL"; Enum "Default VAT Date CZL")
#if not CLEAN22
#pragma warning restore AL0432
#endif
        {
            Caption = 'Default VAT Date';
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Replaced by VAT Reporting Date in General Ledger Setup.';
        }
        field(11781; "Allow Alter Posting Groups CZL"; Boolean)
        {
            Caption = 'Allow Alter Posting Groups';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '23.0';
            ObsoleteReason = 'It will be replaced by "Allow Multiple Posting Groups" field.';

        }
    }
}
