// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.AuditCodes;

tableextension 18930 "Source Code Setup Ext." extends "Source Code Setup"
{
    fields
    {
        field(18929; "Cash Payment Voucher"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Source Code";
        }

        field(18930; "Bank Receipt Voucher"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Source Code";
        }
        field(18931; "Bank Payment Voucher"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Source Code";
        }
        field(18932; "Contra Voucher"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Source Code";
        }
        field(18933; "Journal Voucher"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Source Code";
        }
        field(18934; "Cash Receipt Voucher"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Source Code";
        }
    }
}
