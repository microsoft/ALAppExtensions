// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

using Microsoft.Finance.TaxBase;

tableextension 18544 "CustomerExt" extends Customer
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
        field(18548; "Aggregate Turnover"; Enum "Cust Aggregate Turnover")
        {
            DataClassification = CustomerContent;
        }
    }
}
