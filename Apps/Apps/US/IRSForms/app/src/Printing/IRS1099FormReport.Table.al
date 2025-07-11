// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10043 "IRS 1099 Form Report"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "IRS 1099 Form Reports";
    LookupPageId = "IRS 1099 Form Reports";

    fields
    {
        field(1; "Document ID"; Integer)
        {
        }
        field(2; "Report Type"; Enum "IRS 1099 Form Report Type")
        {
        }
        field(20; "File Content"; Blob)
        {
        }
    }

    keys
    {
        key(PK; "Document ID", "Report Type")
        {
            Clustered = true;
        }
    }

    var
        NoFileErr: Label 'There is no file to download.';
        SaveFileDialogTxt: Label 'Save 1099 form report';
        FileNameTxt: Label 'IRS1099_%1.pdf', Locked = true;

    procedure DownloadReportFile()
    var
        FileInStream: InStream;
        FileName: Text;
    begin
        Rec.CalcFields("File Content");
        if not Rec."File Content".HasValue() then
            Error(NoFileErr);
        Rec."File Content".CreateInStream(FileInStream);
        FileName := StrSubstNo(FileNameTxt, DelChr(Format(Rec."Report Type")));
#pragma warning disable AA0139
        DownloadFromStream(FileInStream, SaveFileDialogTxt, '', '', FileName);
#pragma warning restore
    end;
}
