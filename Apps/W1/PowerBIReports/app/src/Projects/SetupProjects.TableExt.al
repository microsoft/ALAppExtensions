// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.PowerBIReports;

using Microsoft.PowerBIReports;

tableextension 36955 "Setup - Projects" extends "PowerBI Reports Setup"
{
    fields
    {
        field(36962; "Job Ledger Entry Start Date"; Date)
        {
            Caption = 'Project Ledger Entry Start Date';
            DataClassification = CustomerContent;
        }
        field(36963; "Job Ledger Entry End Date"; Date)
        {
            Caption = 'Project Ledger Entry End Date';
            DataClassification = CustomerContent;
        }
        field(36976; "Projects Report Id"; Guid)
        {
            Caption = 'Projects Report ID';
            DataClassification = CustomerContent;
        }
        field(36977; "Projects Report Name"; Text[200])
        {
            Caption = 'Projects Report Name';
            DataClassification = CustomerContent;
        }
    }
}