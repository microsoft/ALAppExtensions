// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

using System.Environment;

table 9048 "Custom User Group In Plan"
{
    Caption = 'User Group Plan Assignment';
    Access = Internal;
    DataPerCompany = false;
    ReplicateData = false;
    DataClassification = SystemMetadata;
    ObsoleteState = Removed;
    ObsoleteTag = '25.0';
    ObsoleteReason = '[220_UserGroups] Use custom permission sets in plan instead. To learn more, go to https://go.microsoft.com/fwlink/?linkid=2245709.';


    fields
    {
        field(5; Id; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(1; "Plan ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Plan ID';
        }
        field(2; "User Group Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'User Group Code';
        }
        field(11; "User Group Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'User Group Name';
        }
        field(20; "Company Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Company Name';
            TableRelation = Company;
        }
    }

    keys
    {
        key(PrimaryKey; Id)
        {
            Clustered = true;
        }

        key(UniqueKey; "Plan ID", "User Group Code", "Company Name")
        {
            Unique = true;
        }
    }
}
