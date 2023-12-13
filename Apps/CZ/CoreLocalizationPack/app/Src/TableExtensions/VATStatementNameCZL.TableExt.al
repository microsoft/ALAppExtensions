// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

tableextension 11749 "VAT Statement Name CZL" extends "VAT Statement Name"
{
    fields
    {
        field(11770; "Comments CZL"; Integer)
        {
            CalcFormula = count("VAT Statement Comment Line CZL" where("VAT Statement Template Name" = field("Statement Template Name"),
                                                                    "VAT Statement Name" = field(Name)));
            Caption = 'Comments';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11771; "Attachments CZL"; Integer)
        {
            CalcFormula = count("VAT Statement Attachment CZL" where("VAT Statement Template Name" = field("Statement Template Name"),
                                                                  "VAT Statement Name" = field(Name)));
            Caption = 'Attachments';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        VATStmtXMLExportRunnerCZL: Codeunit "VAT Stmt XML Export Runner CZL";

    procedure ExportToFileCZL()
    begin
        VATStmtXMLExportRunnerCZL.Run(Rec);
    end;

    procedure ExportToXMLBlobCZL(var TempBlob: Codeunit "Temp Blob")
    begin
        VATStmtXMLExportRunnerCZL.ExportToXMLBlob(Rec, TempBlob);
    end;
}
