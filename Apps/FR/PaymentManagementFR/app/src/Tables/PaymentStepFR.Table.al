// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using System.Reflection;

table 10840 "Payment Step FR"
{
    Caption = 'Payment Step';
    LookupPageID = "Payment Steps List FR";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Payment Class"; Text[30])
        {
            Caption = 'Payment Class';
            TableRelation = "Payment Class FR";
        }
        field(2; Line; Integer)
        {
            Caption = 'Line';
        }
        field(3; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(4; "Previous Status"; Integer)
        {
            Caption = 'Previous Status';
            TableRelation = "Payment Status FR".Line where("Payment Class" = field("Payment Class"));
        }
        field(5; "Next Status"; Integer)
        {
            Caption = 'Next Status';
            TableRelation = "Payment Status FR".Line where("Payment Class" = field("Payment Class"));
        }
        field(6; "Action Type"; Enum "Payment Step Action Type FR")
        {
            Caption = 'Action Type';
        }
        field(7; "Report No."; Integer)
        {
            Caption = 'Report No.';
            TableRelation = if ("Action Type" = const(Report)) AllObj."Object ID" where("Object Type" = const(Report));
        }
        field(8; "Export No."; Integer)
        {
            Caption = 'Export No.';
            TableRelation = if ("Action Type" = const(File),
                                "Export Type" = const(Report)) AllObj."Object ID" where("Object Type" = const(Report))
            else
            if ("Action Type" = const(File),
                                         "Export Type" = const(XMLport)) AllObj."Object ID" where("Object Type" = const(XMLport));
        }
        field(9; "Previous Status Name"; Text[50])
        {
            CalcFormula = lookup("Payment Status FR".Name where("Payment Class" = field("Payment Class"),
                                                              Line = field("Previous Status")));
            Caption = 'Previous Status Name';
            FieldClass = FlowField;
        }
        field(10; "Next Status Name"; Text[50])
        {
            CalcFormula = lookup("Payment Status FR".Name where("Payment Class" = field("Payment Class"),
                                                              Line = field("Next Status")));
            Caption = 'Next Status Name';
            FieldClass = FlowField;
        }
        field(11; "Verify Lines RIB"; Boolean)
        {
            Caption = 'Verify Lines RIB';
        }
        field(12; "Header Nos. Series"; Code[20])
        {
            Caption = 'Header Nos. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                NoSeriesLine: Record "No. Series Line";
            begin
                if "Header Nos. Series" <> '' then begin
                    NoSeriesLine.SetRange("Series Code", "Header Nos. Series");
                    if NoSeriesLine.FindLast() then
                        if (StrLen(NoSeriesLine."Starting No.") > 10) or (StrLen(NoSeriesLine."Ending No.") > 10) then
                            Error(Text001Lbl);
                end;
            end;
        }
        field(13; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(14; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = true;
            TableRelation = "Source Code";
        }
        field(15; "Acceptation Code<>No"; Boolean)
        {
            Caption = 'Acceptation Code<>No';
        }
        field(16; Correction; Boolean)
        {
            Caption = 'Correction';
        }
        field(17; "Verify Header RIB"; Boolean)
        {
            Caption = 'Verify Header RIB';
        }
        field(18; "Verify Due Date"; Boolean)
        {
            Caption = 'Verify Due Date';
        }
        field(19; "Realize VAT"; Boolean)
        {
            Caption = 'Realize VAT';
        }
        field(30; "Export Type"; Option)
        {
            Caption = 'Export Type';
            InitValue = "XMLport";
            OptionCaption = ',,,Report,,,XMLport';
            OptionMembers = ,,,"Report",,,"XMLport";

            trigger OnValidate()
            begin
                "Export No." := 0;
            end;
        }
    }

    keys
    {
        key(Key1; "Payment Class", Line)
        {
            Clustered = true;
        }
        key(Key2; Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if Line = 0 then
            Error(Text000Lbl);
    end;

    var
        Text000Lbl: Label 'Deleting the default report is not allowed.';
        Text001Lbl: Label 'You cannot assign a number series with numbers longer than 10 characters.';
}

