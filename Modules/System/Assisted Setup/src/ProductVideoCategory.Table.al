// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1471 "Product Video Category"
{
    Access = Internal;
    Caption = 'Product Video Category';
    ObsoleteState = Pending;
    ObsoleteReason = 'Videos are not categorized any more in this way. The Video module handles the full listing.';
    ObsoleteTag = '16.0';

    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            Editable = false;
        }
        field(2; Category; Option)
        {
            Caption = 'Category';
            OptionCaption = ' ,Getting Started,,Finance & Bookkeeping,Sales,Reporting & BI,Inventory Management,Project Management,Workflows,Services & Extensions,Setup,Warehouse Management';
            OptionMembers = " ","Getting Started",,"Finance & Bookkeeping",Sales,"Reporting & BI","Inventory Management","Project Management",Workflows,"Services & Extensions",Setup,"Warehouse Management";
        }
        field(3; "Assisted Setup ID"; Integer)
        {
            Caption = 'Assisted Setup ID';
            TableRelation = "Assisted Setup"."Page ID";
        }
        field(4; "Alternate Title"; Text[250])
        {
            Caption = 'Alternate Title';
        }
    }

    keys
    {
        key(Key1; "Assisted Setup ID", Category)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

