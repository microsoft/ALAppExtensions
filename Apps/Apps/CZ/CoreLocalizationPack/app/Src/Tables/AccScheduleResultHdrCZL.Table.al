// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using System.Security.AccessControl;

table 31099 "Acc. Schedule Result Hdr. CZL"
{
    Caption = 'Acc. Schedule Result Header';
    LookupPageId = "Acc. Sched. Res. Hdr. List CZL";

    fields
    {
        field(1; "Result Code"; Code[20])
        {
            Caption = 'Result Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Date Filter"; Text[30])
        {
            Caption = 'Date Filter';
            DataClassification = CustomerContent;
        }
        field(4; "Acc. Schedule Name"; Code[10])
        {
            Caption = 'Acc. Schedule Name';
            DataClassification = CustomerContent;
            TableRelation = "Acc. Schedule Name";
        }
        field(5; "Column Layout Name"; Code[10])
        {
            Caption = 'Column Layout Name';
            DataClassification = CustomerContent;
        }
        field(12; "Dimension 1 Filter"; Text[250])
        {
            Caption = 'Dimension 1 Filter';
            DataClassification = CustomerContent;
        }
        field(13; "Dimension 2 Filter"; Text[250])
        {
            Caption = 'Dimension 2 Filter';
            DataClassification = CustomerContent;
        }
        field(14; "Dimension 3 Filter"; Text[250])
        {
            Caption = 'Dimension 3 Filter';
            DataClassification = CustomerContent;
        }
        field(15; "Dimension 4 Filter"; Text[250])
        {
            Caption = 'Dimension 4 Filter';
            DataClassification = CustomerContent;
        }
        field(20; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(21; "Result Date"; Date)
        {
            Caption = 'Result Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(22; "Result Time"; Time)
        {
            Caption = 'Result Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Result Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        AccScheduleResultValueCZL.SetRange("Result Code", "Result Code");
        if not AccScheduleResultValueCZL.IsEmpty() then
            AccScheduleResultValueCZL.DeleteAll();

        AccScheduleResultHistCZL.SetRange("Result Code", "Result Code");
        if not AccScheduleResultHistCZL.IsEmpty() then
            AccScheduleResultHistCZL.DeleteAll();

        AccScheduleResultLineCZL.SetRange("Result Code", "Result Code");
        if not AccScheduleResultLineCZL.IsEmpty() then
            AccScheduleResultLineCZL.DeleteAll();

        AccScheduleResultColCZL.SetRange("Result Code", "Result Code");
        if not AccScheduleResultColCZL.IsEmpty() then
            AccScheduleResultColCZL.DeleteAll();
    end;

    var
        AccScheduleResultValueCZL: Record "Acc. Schedule Result Value CZL";
        AccScheduleResultHistCZL: Record "Acc. Schedule Result Hist. CZL";
        AccScheduleResultLineCZL: Record "Acc. Schedule Result Line CZL";
        AccScheduleResultColCZL: Record "Acc. Schedule Result Col. CZL";
}
