// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10052 "Error Information IRIS"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line ID"; Integer)
        {
            ToolTip = 'Specifies the number of the line.';
            Editable = false;
        }
        field(2; "Transmission Document ID"; Integer)
        {
            Editable = false;
        }
        field(3; "Unique Transmission ID"; Text[100])
        {
            ToolTip = 'Specifies the unique transmission identifier that is defined when the transmission XML file is created. It identifies the group of 1099 forms that are sent to IRS.';
            Editable = false;
        }
        field(10; "Entity Type"; Enum "Entity Type IRIS")
        {
            ToolTip = 'Specifies the type of the entity to which the error is related.';
            Editable = false;
        }
        field(11; "Submission ID"; Text[20])
        {
            ToolTip = 'Specifies the unique identifier of a group of 1099 forms of the same type within the transmission, e.g., 1099-MISC, that are sent to the IRS using IRIS. The submission ID is defined when the transmission XML file is created.';
            Editable = false;
        }
        field(12; "Record ID"; Text[20])
        {
            ToolTip = 'Specifies the identifier of the 1099 form within the submission.';
            Editable = false;
        }
        field(13; "IRS 1099 Form Doc. ID"; Integer)
        {
            Caption = 'IRS 1099 Form Document ID';
            ToolTip = 'Specifies the ID of the 1099 form document to which the error is related.';
            Editable = false;
        }
        field(20; "Error Code"; Text[30])
        {
            ToolTip = 'Specifies the error code returned in the xml response by IRS.';
            Editable = false;
        }
        field(21; "Error Message"; Text[2048])
        {
            ToolTip = 'Specifies the error message returned in the xml response by IRS.';
            Editable = false;
        }
        field(22; "Error Value"; Text[150])
        {
            ToolTip = 'Specifies the value that caused the error.';
            Editable = false;
        }
        field(23; "XML Element Path"; Text[250])
        {
            ToolTip = 'Specifies the XML element path where the error occurred.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Line ID")
        {
            Clustered = true;
        }
    }

    internal procedure InitRecord()
    var
        LineID: Integer;
    begin
        if Rec.FindLast() then
            LineID := Rec."Line ID";
        LineID += 1;
        Rec."Line ID" := LineID;
    end;
}