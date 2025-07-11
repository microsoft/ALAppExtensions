// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

tableextension 20600 "Application Area Setup BF" extends "Application Area Setup"
{
    fields
    {
        field(20600; "BF Basic"; Boolean)
        {
            Caption = 'Basic Ext';
            DataClassification = SystemMetadata;
        }
        field(20601; "BF Orders"; Boolean)
        {
            Caption = 'Orders Ext';
            DataClassification = SystemMetadata;
        }
    }
}
