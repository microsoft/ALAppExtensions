// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.AuditCodes;

tableextension 18012 "GST Source Code Setup Ext" extends "Source Code Setup"
{
    fields
    {
        field(18000; "Service Transfer Shipment"; code[10])
        {
            Caption = 'Service Transfer Shipment';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(18001; "Service Transfer Receipt"; code[10])
        {
            Caption = 'Service Transfer Receipt';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(18002; "GST Credit Adjustment Journal"; code[10])
        {
            Caption = 'GST Credit Adjustment Journal';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(18003; "GST Settlement"; Code[10])
        {
            Caption = 'GST Settlement';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(18004; "GST Distribution"; code[10])
        {
            Caption = 'GST Distribution';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(18005; "GST Liability Adjustment"; Code[10])
        {
            Caption = 'GST Liability Adjustment';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(18006; "GST Adjustment Journal"; Code[10])
        {
            Caption = 'GST Adjustment Journal';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(18007; "GST Liability - Job Work"; Code[10])
        {
            Caption = 'GST Liability - Job Work';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(18008; "GST Receipt - Job Work"; Code[10])
        {
            Caption = 'GST Receipt - Job Work';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
    }
}
