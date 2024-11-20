#if not CLEANSCHEMA25
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Setup;

using Microsoft.Finance.VAT.Setup;

tableextension 11715 "Purchases & Payables Setup CZL" extends "Purchases & Payables Setup"
{
    fields
    {
#pragma warning disable AL0842
        field(11780; "Default VAT Date CZL"; Enum "Default VAT Date CZL")
#pragma warning restore AL0842
        {
            Caption = 'Default VAT Date';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Replaced by VAT Reporting Date in General Ledger Setup.';
        }
#if not CLEANSCHEMA23
        field(11781; "Allow Alter Posting Groups CZL"; Boolean)
        {
            Caption = 'Allow Alter Posting Groups';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '23.0';
            ObsoleteReason = 'It will be replaced by "Allow Multiple Posting Groups" field.';
        }
#endif
#if not CLEANSCHEMA25
        field(31110; "Def. Orig. Doc. VAT Date CZL"; Option)
        {
            Caption = 'Default Original Document VAT Date';
            OptionCaption = 'Blank,Posting Date,VAT Date,Document Date';
            OptionMembers = Blank,"Posting Date","VAT Date","Document Date";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Replaced by Def. Orig. Doc. VAT Date CZL in General Ledger Setup.';
        }
#endif
    }
}
#endif
