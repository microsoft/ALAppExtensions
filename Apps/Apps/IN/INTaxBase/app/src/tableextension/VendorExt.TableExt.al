// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

using Microsoft.Finance.TaxBase;

tableextension 18550 "VendorExt" extends Vendor
{
    fields
    {
        field(18543; "Assessee Code"; Code[10])
        {
            TableRelation = "Assessee Code";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18544; "P.A.N. No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18545; "P.A.N. Status"; Enum "P.A.N.Status")
        {
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                "P.A.N. No." := Format("P.A.N. Status");
            end;
        }
        field(18546; "P.A.N. Reference No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18547; "State Code"; Code[10])
        {
            TableRelation = "State";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18548; "Tax Code"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}
