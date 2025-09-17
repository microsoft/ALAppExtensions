// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10047 "Transmission Log IRIS"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line ID"; Integer)
        {
            ToolTip = 'Specifies the number of the line.';
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Period No."; Text[4])
        {
            ToolTip = 'Specifies the period number of the transmission.';
            Editable = false;
        }
        field(3; "Transmission Document ID"; Integer)
        {
            ToolTip = 'Specifies the document ID of the transmission to which this log is related.';
            Editable = false;
        }
        field(10; "Transmission Status"; Enum "Transmission Status IRIS")
        {
            ToolTip = 'Specifies the status of the transmission.';
            Editable = false;
        }
        field(11; "Transmission Status Text"; Text[250])
        {
            ToolTip = 'Specifies the status text returned in the xml response by IRS.';
            Editable = false;
        }
        field(12; "Transmission Type"; Enum "Transmission Type IRIS")
        {
            ToolTip = 'Specifies the type of the transmission which determines how the data should be processed and transmitted. The possible values are Original, Correction, and Replacement.';
            Editable = false;
        }
        field(13; "Unique Transmission ID"; Text[100])
        {
            ToolTip = 'Specifies the unique transmission identifier that is defined when the transmission XML file is created. It identifies the group of 1099 forms that are sent to IRS.';
            Editable = false;
        }
        field(14; "Transmission Date/Time"; DateTime)
        {
            ToolTip = 'Specifies the date and time when the transmission was sent to IRS.';
            Editable = false;
        }
        field(20; "Transmission Content"; Blob)
        {
        }
        field(21; "Transmission Size"; Text[20])
        {
            ToolTip = 'Specifies the size of the transmission content.';
            Editable = false;
        }
        field(30; "Acceptance Response Content"; Blob)
        {
        }
        field(31; "Response Http Status Code"; Integer)
        {
            ToolTip = 'Specifies the HTTP status code of the response returned by IRS.';
            Editable = false;
        }
        field(32; "Receipt ID"; Text[100])
        {
            ToolTip = 'Specifies the receipt identifier returned by IRIS.';
            Editable = false;
        }
        field(40; "Acknowledgement Content"; Blob)
        {
        }
        field(41; "Acknowledg. Http Status Code"; Integer)
        {
            ToolTip = 'Specifies the HTTP status code of the acknowledgement returned by IRS.';
            Editable = false;
        }
        field(42; "Transmission Errors"; Text[2048])
        {
            ToolTip = 'Specifies the human-readable errors text created by parsing the acknowledgement XML response from IRS.';
            Editable = false;
        }
        field(43; "Acknowledgement Date/Time"; DateTime)
        {
            ToolTip = 'Specifies the date and time when the acknowledgement was received from IRS.';
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

    internal procedure FindRecordByUTID(UniqueTransmissionId: Text[100]): Boolean
    begin
        Rec.Reset();
        Rec.SetRange("Unique Transmission ID", UniqueTransmissionId);
        exit(Rec.FindFirst());
    end;

    internal procedure FindLastRecByReceiptID(ReceiptID: Text[100]): Boolean
    begin
        Rec.Reset();
        Rec.SetRange("Receipt ID", ReceiptID);
        exit(Rec.FindLast());
    end;
}