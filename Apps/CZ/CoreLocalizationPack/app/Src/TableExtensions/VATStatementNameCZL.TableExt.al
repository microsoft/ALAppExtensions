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
        field(11773; "XML Format CZL"; Enum "VAT Statement XML Format CZL")
        {
            Caption = 'XML Format';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ConfirmManagement: Codeunit "Confirm Management";
            begin
                if ("XML Format CZL" <> xRec."XML Format CZL") then
                    if ConfirmManagement.GetResponseOrDefault(StrSubstNo(YouChangedXMLFormatQst, FieldCaption("XML Format CZL"), "XML Format CZL", TableCaption, Name), true) then
                        InitVATAttributesCZL(true);
            end;
        }
    }

    trigger OnAfterInsert()
    begin
        if Rec.IsTemporary() then
            exit;

        InitVATAttributesCZL();
    end;

    var
        VATAttributeCodeMgtCZL: Codeunit "VAT Attribute Code Mgt. CZL";
        VATStmtXMLExportRunnerCZL: Codeunit "VAT Stmt XML Export Runner CZL";
        YouChangedXMLFormatQst: Label 'You have changed XML format.\\Do you want to initialize %1: "%2" default VAT attributes for %3 %4?', Comment = '%1=fieldcaption, %2=VAT statement XML format, %3=tablecaption, %4=VAT statement template name';

    procedure ExportToFileCZL()
    begin
        VATStmtXMLExportRunnerCZL.Run(Rec);
    end;

    procedure ExportToXMLBlobCZL(var TempBlob: Codeunit "Temp Blob")
    begin
        VATStmtXMLExportRunnerCZL.ExportToXMLBlob(Rec, TempBlob);
    end;

    procedure InitVATAttributesCZL();
    begin
        InitVATAttributesCZL(false);
    end;

    procedure InitVATAttributesCZL(OverwriteData: Boolean);
    begin
        VATAttributeCodeMgtCZL.InitVATAttributes(Rec, OverwriteData);
    end;
}
