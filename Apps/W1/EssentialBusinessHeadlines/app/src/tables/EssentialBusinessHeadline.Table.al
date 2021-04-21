// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1438 "Essential Business Headline"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Should be per user';
    ObsoleteTag = '18.0';

    fields
    {

        field(1; "Headline Name"; Option)
        {
            OptionMembers = MostPopularItem,BusiestResource,LargestSale,LargestOrder,SalesIncrease,TopCustomer;
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
        }

        field(5; "Headline Computation WorkDate"; Date)
        {
            DataClassification = SystemMetadata;
        }

        field(6; "Headline Computation Period"; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Headline Name")
        {
            Clustered = true;
        }
    }

    procedure GetOrCreateHeadline(HeadlineName: Option)
    begin
        if not Get(HeadlineName) then begin
            Init();
            Validate("Headline Name", HeadlineName);
            if not Insert() then exit;
        end;
    end;
}