// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1436 "Ess. Business Headline Per Usr"
{
    fields
    {
        field(1; "Headline Name"; Option)
        {
            OptionMembers = MostPopularItem,BusiestResource,LargestSale,LargestOrder,SalesIncrease,TopCustomer,OpenVATReturn,OverdueVATReturn,RecentlyOverdueInvoices;
            DataClassification = SystemMetadata;
        }
        field(2; "Headline Text"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Headline Visible"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Headline Computation Date"; DateTime)
        {
            DataClassification = SystemMetadata;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced with the Last Computed field on the RC Headlines User Data table';
            ObsoleteTag = '18.0';
        }
        field(5; "Headline Computation WorkDate"; Date)
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Headline Computation Period"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(7; "User Id"; Guid)
        {
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(20; "VAT Return Period Record Id"; RecordId)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Headline Name", "User Id")
        {
            Clustered = true;
        }
    }

    procedure GetOrCreateHeadline(HeadlineName: Option)
    begin

        if not Get(HeadlineName, UserSecurityId()) then begin
            Init();
            Validate("Headline Name", HeadlineName);
            Validate("User Id", UserSecurityId());
            if not Insert() then exit;
        end;
    end;
}
