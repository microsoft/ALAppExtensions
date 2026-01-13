// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;

table 10053 "Transmission Log Line IRIS"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Transmission Log ID"; Integer)
        {
            ToolTip = 'Specifies the ID of the transmission log to which the line is related.';
            Editable = false;
        }
        field(2; "Line ID"; Integer)
        {
            ToolTip = 'Specifies the number of the line.';
            Editable = false;
        }
        field(7; "IRS 1099 Form Document ID"; Integer)
        {
            ToolTip = 'Specifies the ID of the IRS 1099 Form Document to which this line was related.';
            TableRelation = "IRS 1099 Form Doc. Header".ID;
            Editable = false;
        }
        field(13; "Vendor No."; Code[20])
        {
            ToolTip = 'Specifies the vendor number to which the IRS 1099 Form Document was related.';
            TableRelation = Vendor."No.";
            Editable = false;
        }
        field(14; "Vendor Name"; Text[100])
        {
            ToolTip = 'Specifies the name of the vendor to which the IRS 1099 Form Document was related.';
            Editable = false;
        }
        field(15; "Vendor Federal ID No."; Text[30])
        {
            ToolTip = 'Specifies the vendor''s Taxpayer Identification Number (TIN).';
            Editable = false;
        }
        field(20; "Form No."; Code[20])
        {
            ToolTip = 'Specifies the IRS 1099 Form which was set for the IRS 1099 Form Document.';
            TableRelation = "IRS 1099 Form"."No.";
            Editable = false;
        }
        field(62; "Submission ID"; Text[20])
        {
            ToolTip = 'Specifies the unique identifier of a group of 1099 forms of the same type within the transmission.';
            Editable = false;
        }
        field(63; "Record ID"; Text[20])
        {
            ToolTip = 'Specifies the identifier of the 1099 form within the submission.';
            Editable = false;
        }
        field(65; "Submission Status Text"; Text[250])
        {
            ToolTip = 'Specifies the status text returned in the xml response by IRS for the submission.';
            Editable = false;
        }
        field(73; "Correction to Zeros"; Boolean)
        {
            ToolTip = 'Specifies if the selected 1099 form was sent in a correction transmission with all amounts set to zero.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Transmission Log ID", "Line ID")
        {
            Clustered = true;
        }
    }

    internal procedure InitRecord(TransmissionLogID: Integer)
    var
        TransmissionLogLine: Record "Transmission Log Line IRIS";
        LineID: Integer;
    begin
        TransmissionLogLine.SetRange("Transmission Log ID", TransmissionLogID);
        if TransmissionLogLine.FindLast() then
            LineID := TransmissionLogLine."Line ID";
        LineID += 1;

        Rec."Transmission Log ID" := TransmissionLogID;
        Rec."Line ID" := LineID;
    end;
}