// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

table 4587 "SOA Billing Task Setup"
{
    DataClassification = SystemMetadata;
    Access = Internal;
    InherentEntitlements = rimX;
    InherentPermissions = rimX;
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            ToolTip = 'Specifies the code for the billing task. This is a setup table, the field should be blank.';
            AllowInCustomizations = Never;
        }

        field(10; "Billing Task ID"; Guid)
        {
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the ID of the billing task.';
        }
        field(11; "Billing Task Start DateTime"; DateTime)
        {
            Caption = 'Billing Task Start DateTime';
            ToolTip = 'Specifies the date and time the billing task will start.';
            DataClassification = SystemMetadata;
        }
        field(12; "Last Billing Update At"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last Billing Updated at';
            ToolTip = 'Specifies the date and time the last billing task was run.';
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}